#!/usr/bin/env bash
set -e

echo "🔧 Setting up Frappe Bench environment..."
echo "----------------------------------------"

OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
    echo "Detected macOS"

    # Xcode CLI tools
    if ! xcode-select -p &>/dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install || true
    fi

    # Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
    fi

    echo "Installing core dependencies..."
    brew install python@3.12 git redis mariadb@10.6 node@18 postgresql pkg-config mariadb-connector-c

    echo "Installing wkhtmltopdf..."
    curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-2/wkhtmltox-0.12.6-2.macos-cocoa.pkg -o wkhtmltopdf.pkg
    sudo installer -pkg wkhtmltopdf.pkg -target /

    echo "Restarting MariaDB..."
    brew services restart mariadb@10.6

    echo "Installing Yarn..."
    npm install -g yarn

elif [[ -f "/etc/debian_version" ]]; then
    echo "Detected Debian/Ubuntu"

    echo "Updating system..."
    sudo apt update -y

    echo "Installing core dependencies..."
    sudo apt install -y git python3 python3-dev python3-pip redis-server libmariadb-dev mariadb-server mariadb-client pkg-config curl xvfb libfontconfig

    echo "Setting up MariaDB..."
    sudo systemctl enable mariadb
    sudo systemctl start mariadb

    if ! sudo grep -q "utf8mb4" /etc/mysql/my.cnf 2>/dev/null; then
        echo "Configuring MariaDB charset..."
        sudo tee -a /etc/mysql/my.cnf >/dev/null <<EOF

[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOF
        sudo systemctl restart mariadb
    fi

    echo "Installing NVM + Node 18..."
    export NVM_DIR="$HOME/.nvm"
    if [ ! -d "$NVM_DIR" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi
    source "$NVM_DIR/nvm.sh"
    nvm install 18
    nvm use 18

    echo "Installing Yarn..."
    npm install -g yarn

    echo "Installing wkhtmltopdf..."
    TMP_DEB=$(mktemp)
    curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bullseye_amd64.deb -o "$TMP_DEB"
    sudo dpkg -i "$TMP_DEB" || sudo apt -f install -y
    rm "$TMP_DEB"

else
    echo "❌ Unsupported OS. Only macOS and Debian/Ubuntu are supported."
    exit 1
fi

echo "Installing Bench CLI..."
pip3 install frappe-bench --break-system-packages || pip install frappe-bench --break-system-packages

if ! command -v bench &>/dev/null; then
    echo "Adding Bench to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

echo "✅ Installation complete!"
echo "Run 'bench --version' to verify."
echo "To create your first bench:  bench init my-bench"
