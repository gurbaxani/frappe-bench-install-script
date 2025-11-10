#!/usr/bin/env bash
# Unofficial community script. Review carefully before running.
# This script is offered as MIT software under no guarantees. 
# Dependent software licenses may differ.
set -e

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🧪 Dry run mode — commands will only be printed, not executed."
fi

# Wrapper for all system commands
run() {
    if $DRY_RUN; then
        echo "[dry-run] $*"
    else
        eval "$@"
    fi
}

echo "🔧 Setting up Frappe Bench environment..."
echo "----------------------------------------"

run sudo -v

OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
    echo "Detected macOS"

    run xcode-select -p &>/dev/null || run xcode-select --install || true

    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        run eval "$(/opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
    fi

    run brew install python@3.12 git redis mariadb@10.6 node postgresql pkg-config mariadb-connector-c
    run curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-2/wkhtmltox-0.12.6-2.macos-cocoa.pkg -o wkhtmltopdf.pkg
    run sudo installer -pkg wkhtmltopdf.pkg -target /
    run rm wkhtmltopdf.pkg

    if brew services list | grep -q mariadb; then
        run brew services restart mariadb@10.6
    fi

    run npm install -g yarn

elif [[ -f "/etc/debian_version" ]]; then
    echo "Detected Debian/Ubuntu"

    run sudo apt update -y
    run sudo apt install -y git python3 python3-dev python3-pip redis-server libmariadb-dev mariadb-server mariadb-client pkg-config curl xvfb libfontconfig

    run sudo systemctl enable mariadb
    run sudo systemctl start mariadb

    if ! sudo grep -q "utf8mb4" /etc/mysql/my.cnf 2>/dev/null; then
        echo "Configuring MariaDB charset..."
        run "sudo tee -a /etc/mysql/my.cnf >/dev/null <<EOF

[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOF"
        run sudo systemctl restart mariadb
    fi

    export NVM_DIR="$HOME/.nvm"
    if [ ! -d "$NVM_DIR" ]; then
        run curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi
    source "$NVM_DIR/nvm.sh"
    run nvm install --lts
    run nvm use --lts
    run npm install -g yarn

    run TMP_DEB=$(mktemp)
    run curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bullseye_amd64.deb -o "$TMP_DEB"
    run sudo dpkg -i "$TMP_DEB" || run sudo apt -f install -y
    run rm "$TMP_DEB"

else
    echo "❌ Unsupported OS. Only macOS and Debian/Ubuntu are supported."
    exit 1
fi

PYTHON_BIN="$(command -v python3 || command -v python)"
if [[ -z "$PYTHON_BIN" ]]; then
    echo "❌ Python not found even after installation."
    exit 1
fi

run "$PYTHON_BIN" -m pip install --user frappe-bench

if ! command -v bench &>/dev/null; then
    echo "Adding Bench to PATH..."
    run "echo 'export PATH=\"$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
    run source ~/.bashrc
fi

echo "✅ Installation complete!"
echo "Run 'bench --version' to verify."
echo "To create your first bench:  bench init my-bench"
