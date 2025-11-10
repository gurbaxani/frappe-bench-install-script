# Frappe Bench Installer

> ⚠️ Unofficial community script. Review carefully before running.

A simple one-command setup for a full Frappe Bench environment on macOS or Ubuntu/Debian.  
This script installs all required dependencies, configures MariaDB, and gets Bench ready to use.

## Quick Install

### Dry Run (Recommended)
To verify that this works on your system without making changes, use the `--dry-run` flag:

```bash
curl -fsSL https://raw.githubusercontent.com/gurbaxani/frappe-bench-install-script/trunk/install-frappe-bench.sh | bash --dry-run
````

### Full Installation

Once satisfied, run:

```bash
curl -fsSL https://raw.githubusercontent.com/gurbaxani/frappe-bench-install-script/trunk/install-frappe-bench.sh | bash
```

The script will detect your OS, install required packages, and set up everything automatically.

## What It Does

* Installs Python, Git, Redis, MariaDB, Node, Yarn, and wkhtmltopdf
* Configures MariaDB for utf8mb4
* Installs Frappe Bench via pip
* Works on macOS, Ubuntu 22.04+, and Debian 12+

## Requirements

* A macOS or Linux system
* Internet connection
* sudo access

## Notes

* If you are on macOS, the script uses Homebrew to install dependencies. On Apple Silicon (M1/M2), Homebrew installs under `/opt/homebrew`; the script handles PATH automatically.
* On Ubuntu/Debian, Node is installed using nvm.
* The script will update your PATH automatically if needed.
* You can use the `--dry-run` flag at any time to see what commands will execute without making changes.

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

## Support

If you run into issues, please open an issue on this repo with your OS version and full terminal output.


## License

This script is offered under an MIT license. Dependent software licenses may differ.
