# lintRunner

A CLI tool that automates the execution of linting scripts for various project types.

## Overview

lintRunner is a V language tool that automatically detects your project type and runs the appropriate linting commands. It supports multiple languages and configuration formats, making it easy to maintain code quality across different projects.

## Features

- 🔍 **Auto-detection**: Automatically detects project type from config files
- 🎯 **Multi-language support**: V, JavaScript/TypeScript, JSON, TOML
- ⚙️ **Two execution modes**: Auto and Semi-auto
- 📝 **Flexible configuration**: Use auto-detection or specify config file manually

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

### Basic Usage

Run lintRunner in your project directory:

```bash
lintRunner
```

This will:
1. Auto-detect the config file in the current directory
2. Determine the project type
3. Run the appropriate linting command

### Command Line Options

```bash
lintRunner [options]
```

**Options:**
- `-m, --mode <string>` - Execution mode: `auto` or `semi-auto` (default: `auto`)
- `-c, --config <string>` - Path to config file (auto-detects if not specified)
- `-h, --help` - Display help information
- `--version` - Show version information

### Examples

#### Auto Mode (Default)

Automatically detect and lint:
```bash
lintRunner
```

With explicit config file:
```bash
lintRunner --config path/to/package.json
```

#### Semi-Auto Mode

Prompts for confirmation before running:
```bash
lintRunner --mode semi-auto
```

Or using short form:
```bash
lintRunner -m semi-auto
```

## Supported Project Types

lintRunner automatically detects and handles the following project types:

### V Language Projects
- **Config file**: `v.mod`
- **Lint command**: `v fmt --check .`

### JavaScript/Node.js Projects
- **Config file**: `package.json`
- **Lint command**: `npm run lint`

### TypeScript Projects
- **Config file**: Any TypeScript config
- **Lint command**: `tsc --noEmit`

### JSON Projects
- **Config file**: `*.json`
- **Lint command**: Suggests using Prettier

### Rust Projects
- **Config file**: `Cargo.toml`
- **Lint command**: `cargo check`

## Supported Config File Extensions

lintRunner recognizes the following config file extensions:
- `.json`
- `.yaml`
- `.yml`
- `.toml`
- `.mod`

## Execution Modes

### Auto Mode

In auto mode, lintRunner:
1. Detects the config file
2. Determines the project type
3. Immediately runs the appropriate linting command

### Semi-Auto Mode

In semi-auto mode, lintRunner:
1. Detects the config file
2. Prompts for confirmation: `Proceed with linting? (y/n):`
3. Runs linting only if confirmed

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
