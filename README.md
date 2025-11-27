# lintRunner

A CLI tool that automates the execution of linting scripts for various project types.

## IMPORTANT

I DO NOT RECOMMEND USING THIS TOOL IN PRODUCTION YET. IT IS STILL IN DEVELOPMENT AND MAY NOT WORK AS EXPECTED. USE AT YOUR OWN RISK. IT IS ACTUALLY WORKING WELL ONLY WITH FORMATTING V FILES.

## Overview

lintRunner is a V language tool that automatically detects your project type and runs the appropriate linting commands. It supports multiple languages and configuration formats, making it easy to maintain code quality across different projects.

## Features

- 🎨 **Colored terminal output**: Beautiful, readable output with color-coded messages
- 🔍 **Auto-detection**: Automatically detects project type from config files or file extensions
- 🎯 **Multi-language support**: V, JavaScript/TypeScript, Python, Go, Rust, JSON, YAML, TOML
- ⚙️ **Two execution modes**: Auto and Semi-auto
- 🔧 **Lint & Format**: Support for both linting and formatting operations
- 📝 **Flexible configuration**: Use auto-detection, specify config file, or target specific files
- ⚡ **Auto-format flag**: Skip confirmation prompts for CI/CD pipelines
- 📄 **File-specific operations**: Target individual files with simple syntax

## Installation

### From Source

1. Clone the repository:
```bash
git clone <repository-url>
cd lintRunner
```

2. Build the binary:
```bash
v -o lintRunner .
```

3. (Optional) Move to PATH:
```bash
sudo mv lintRunner /usr/local/bin/
```

## Usage

### Simplest Usage - Target a Specific File

The easiest way to use lintRunner is to pass a filename directly:

```bash
lintRunner main.v
lintRunner src/utils.js
lintRunner config.py
```

This automatically:
- Detects file type from extension
- Runs appropriate linting command
- Shows colored, easy-to-read output

### Basic Project-Wide Usage

Run lintRunner in your project directory:

```bash
lintRunner
```

This will:
1. Auto-detect the config file in the current directory
2. Determine the project type
3. Run the appropriate linting command
4. Display results with colored output

### Command Line Options

```bash
lintRunner [filename] [options]
```

**Positional Arguments:**
- `filename` - Optional. Specific file to lint/format (e.g., `main.v`, `src/app.js`)

**Options:**
- `-m, --mode <string>` - Execution mode: `auto` or `semi-auto` (default: `auto`)
- `-c, --config <string>` - Path to config file (auto-detects if not specified)
- `-o, --operation <string>` - Operation: `lint` or `format` (default: `lint`)
- `-f, --auto-format` - Automatically format without prompting (for format operation)
- `-h, --help` - Display help information
- `--version` - Show version information

### Examples

#### Lint a Specific File

```bash
lintRunner main.v
lintRunner executor/color_utils.v
```

Output:
```
═══ LINTRUNNER ═══
ℹ Target file: main.v
ℹ Detected file type: v
Running in AUTO MODE
ℹ Running linting automatically on file: main.v for type: v
✓ Changed directory to: /home/user/project
$ v fmt -l main.v
✓ linting passed for type v
```

#### Format a Specific File

```bash
lintRunner main.v -o format
```

When files need formatting, you'll see:
```
────────────────────────────────────────────────────────────
⚠ The following files need formatting:
  main.v
  
ℹ Found 1 file(s) with formatting issues.
────────────────────────────────────────────────────────────
❯ Would you like to auto-format these files? (y/n):
```

#### Auto-Format Without Prompts

Perfect for CI/CD pipelines:

```bash
lintRunner main.v -o format --auto-format
# or short form
lintRunner main.v -o format -f
```

#### Project-Wide Linting

Auto mode (default):
```bash
lintRunner
```

With explicit config file:
```bash
lintRunner --config path/to/package.json
```

#### Semi-Auto Mode

Shows preview and prompts for confirmation:
```bash
lintRunner --mode semi-auto
# or with a file
lintRunner main.v -m semi-auto
```

Output:
```
────────────────────────────────────────────────────────────
ℹ Operation: linting
ℹ Target: main.v
ℹ Type: v
────────────────────────────────────────────────────────────
❯ Proceed with linting? (y/n):
```

## Supported Project Types

lintRunner automatically detects and handles the following project types:

### V Language Projects
- **Config file**: `v.mod`
- **File extension**: `.v`
- **Lint command**: `v fmt -l .` or `v fmt -l <file>`
- **Format command**: `v fmt -w .` or `v fmt -w <file>`

### JavaScript/Node.js Projects
- **Config file**: `package.json`
- **File extensions**: `.js`, `.jsx`
- **Lint command**: `npm run lint`
- **Format command**: `prettier --write .` or `prettier --write <file>`

### TypeScript Projects
- **Config file**: Any TypeScript config
- **File extensions**: `.ts`, `.tsx`
- **Lint command**: `tsc --noEmit`
- **Format command**: `prettier --write .` or `prettier --write <file>`

### Python Projects
- **File extension**: `.py`
- **Format command**: `black .` or `black <file>`

### Go Projects
- **File extension**: `.go`
- **Format command**: `gofmt -w .` or `gofmt -w <file>`

### Rust Projects
- **Config file**: `Cargo.toml`
- **File extension**: `.rs`
- **Lint command**: `cargo check`
- **Format command**: `cargo fmt`

### JSON Projects
- **Config file**: `*.json`
- **File extension**: `.json`
- **Format command**: `prettier --write .` or `prettier --write <file>`

### YAML Projects
- **File extensions**: `.yaml`, `.yml`
- **Format command**: `prettier --write .` or `prettier --write <file>`

### TOML Projects
- **File extension**: `.toml`
- **Lint command**: `cargo check`
- **Format command**: `cargo fmt`

## Supported Config File Extensions

lintRunner recognizes the following config file extensions:
- `.json`
- `.yaml`
- `.yml`
- `.toml`
- `.mod`

## Color Scheme

lintRunner uses colored output for better readability:

| Message Type | Color | Symbol |
|--------------|-------|--------|
| Success | Green | ✓ |
| Error | Red | ✗ |
| Warning | Yellow | ⚠ |
| Info | Cyan | ℹ |
| Prompt | Bright Blue | ❯ |
| Header | Bold Bright Blue | - |
| File Paths | Bright White | - |
| Commands | Bright Magenta | $ |
| Separators | Gray | ─ |

## Execution Modes

### Auto Mode

In auto mode, lintRunner:
1. Detects the config file or file type
2. Determines the project/file type
3. Immediately runs the appropriate lint/format command
4. For formatting: shows preview and prompts for confirmation (unless `--auto-format` is used)

### Semi-Auto Mode

In semi-auto mode, lintRunner:
1. Detects the config file or file type
2. Shows a formatted preview with operation details
3. Prompts for confirmation: `Proceed with <operation>? (y/n):`
4. Runs lint/format only if confirmed

## How It Works

1. **Config Detection**: Scans the current directory for supported config files
2. **Type Analysis**: Analyzes the config file to determine project type
3. **Command Selection**: Chooses the appropriate linting command
4. **Execution**: Runs the command and reports results

## Exit Codes

- `0` - Success
- `1` - General error (invalid flags, linting failed, etc.)
- `2` - Directory change failed

## Examples by Project Type

### V Project

```bash
# In a directory with v.mod
./lintRunner
# Output: Runs 'v fmt --check .'
```

### Node.js Project

```bash
# In a directory with package.json
./lintRunner
# Output: Runs 'npm run lint'
```

### Explicit Config

```bash
# Specify a config file in a subdirectory
./lintRunner --config ./backend/package.json
```

## Troubleshooting

### No config file found

**Error**: `No config file found. Linting cannot proceed.`

**Solution**: Ensure you're in a project directory with a supported config file, or specify one with `--config`.

### Unsupported extension

**Error**: `Unsupported config file extension`

**Solution**: Use one of the supported extensions: `.json`, `.yaml`, `.yml`, `.toml`, `.mod`

### Invalid mode

**Error**: `Invalid mode "xyz". Use "auto" or "semi-auto".`

**Solution**: Use either `--mode auto` or `--mode semi-auto`

## Development

### Project Structure

```
lintRunner/
├── main.v                    # Entry point and CLI parsing
├── executor/                 # Core execution logic
│   ├── executor.v           # Main executor and mode handling
│   ├── auto_mode_command_runner.v
│   ├── semiauto_mode_command_runner.v
│   └── error_fn.v           # Error handling utilities
├── config_analyzer/         # Config file detection
│   └── detect_typ_project.v
└── v.mod                    # Module definition
```

### Running Tests

```bash
v test .
```

### Building for Release

```bash
v -prod -o lintRunner .
```

## Contributing

Contributions are welcome! Feel free to:
- Add support for more languages
- Improve config detection
- Add new features
- Fix bugs

## License

MIT

## Version

Current version: 0.0.1
