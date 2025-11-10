# Frappe Bench Installer

A simple one-command setup for a full Frappe Bench environment on macOS or Ubuntu/Debian.
This script installs all required dependencies, configures MariaDB, and gets Bench ready to use.

## Quick Install

Run this in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/gurbaxani/frappe-bench-install-script/trunk/install-frappe-bench.sh | bash
```

That’s it. The script will detect your OS, install the required packages, and set up everything automatically.

## What It Does

* Installs Python, Git, Redis, MariaDB, Node, Yarn, and wkhtmltopdf
* Configures MariaDB for utf8mb4
* Installs Frappe Bench via pip
* Works on macOS, Ubuntu 22.04+, and Debian 12+

## Requirements

* A macOS or Linux system
* Internet connection
* sudo access

## Verify Installation

Once the script completes, run:

```bash
bench --version
```

You should see the installed Bench version.

To create your first bench:

```bash
bench init my-bench
```

## Notes

* If you are on macOS, the script uses Homebrew to install dependencies.
* On Ubuntu/Debian, Node is installed using nvm.
* The script will update your PATH automatically if needed.

## Support

If you run into issues, please open an issue on this repo with your OS version and full terminal output.

