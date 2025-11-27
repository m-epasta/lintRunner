module executor

import os
import config_analyzer

const supported_extensions_instance = config_analyzer.supported_extensions

// set an enum to save what mode has actually been choose
pub enum Mode {
	auto
	semi_auto
}

pub enum Operation {
	lint
	format
}

// struct of the configs
pub struct Options {
	mode Mode
pub:
	operation   Operation
	config_path ?string
	auto_format bool
	file_name   string
}

pub fn parse_and_validate_options(mode_str string, config_path string, operation_str string, auto_format bool, file_name string) !Options {
	mode := match mode_str {
		'auto' { Mode.auto }
		'semi-auto' { Mode.semi_auto }
		else { return error('Invalid mode "${mode_str}". Use "auto" or "semi-auto".') }
	}

	operation := match operation_str {
		'lint' { Operation.lint }
		'format' { Operation.format }
		else { return error('Invalid operation "${operation_str}". Use "lint" or "format".') }
	}

	final_config_path := if config_path != '' {
		if !os.exists(config_path) {
			return error('Specified config file "${config_path}" does not exist.')
		}
		if !os.is_file(config_path) {
			return error('Specified config path "${config_path}" is not a file.')
		}
		ext := os.file_ext(config_path)
		if ext !in supported_extensions_instance {
			return error('Unsupported config file extension "${ext}". Supported: ${supported_extensions_instance}')
		}
		config_path
	} else {
		path := detect_config_file()
		if path == '' {
			''
		} else {
			path
		}
	}

	return Options{
		mode:        mode
		operation:   operation
		config_path: if final_config_path != '' { final_config_path } else { none }
		auto_format: auto_format
		file_name:   file_name
	}
}

fn detect_config_file() string {
	files := os.ls('.') or { return '' }
	for file in files {
		ext := os.file_ext(file)
		if ext in supported_extensions_instance {
			return file
		}
	}
	return ''
}

pub fn execute_operation(opts Options) ! {
	// If filename is provided, use it to determine config and directory
	if opts.file_name != '' {
		// Validate file exists
		if !os.exists(opts.file_name) {
			print_error('File "${opts.file_name}" does not exist.')
			return error('File not found')
		}

		// Get directory and file info
		file_dir := if opts.file_name.contains('/') {
			os.dir(opts.file_name)
		} else {
			'.'
		}
		file_base := os.base(opts.file_name)
		file_ext := os.file_ext(opts.file_name)

		// Determine type from file extension
		typ := match file_ext {
			'.v' { 'v' }
			'.js', '.jsx' { 'js' }
			'.ts', '.tsx' { 'ts' }
			'.json' { 'json' }
			'.py' { 'python' }
			'.go' { 'go' }
			'.rs' { 'rust' }
			'.toml' { 'toml' }
			'.yaml', '.yml' { 'yaml' }
			else { 'unknown' }
		}

		if typ == 'unknown' {
			print_warning('Unknown file type for "${opts.file_name}"')
			return error('Unsupported file type')
		}

		print_info('Target file: ${format_path(opts.file_name)}')
		print_info('Detected file type: ${typ}')

		match opts.mode {
			.auto {
				print_header('Running in AUTO MODE')
				run_auto_operation(file_dir, typ, opts.operation, opts.auto_format, file_base)!
			}
			.semi_auto {
				print_header('Running in SEMI AUTO MODE')
				run_semi_auto_operation(file_dir, typ, opts.operation, opts.auto_format,
					file_base)!
			}
		}
		return
	}

	// Original logic for config-based detection
	if config_path := opts.config_path {
		config_type := config_analyzer.get_config_file_typ(config_path)!

		print_info('Using config file: ${format_path(config_path)}')
		print_info('Detected config type: ${config_type}')

		dir_path := os.dir(config_path)
		typ := map_config_to_typ(config_type)

		match opts.mode {
			.auto {
				print_header('Running in AUTO MODE')
				run_auto_operation(dir_path, typ, opts.operation, opts.auto_format, '')!
			}
			.semi_auto {
				print_header('Running in SEMI AUTO MODE')
				run_semi_auto_operation(dir_path, typ, opts.operation, opts.auto_format,
					'')!
			}
		}
	} else {
		print_warning('No config file found. Cannot proceed.')
		return
	}
}

fn map_config_to_typ(config_type string) string {
	match config_type {
		'v_language_module' {
			return 'v'
		}
		'package_config' {
			return 'js'
		}
		'app_config' {
			return 'json'
		}
		'generic_json' {
			return 'json'
		}
		else {
			if config_type.starts_with('unknown_') {
				ext := config_type['unknown_'.len..]
				lang := ext.trim_left('.')
				return match lang {
					'py' { 'python' }
					'go' { 'go' }
					'rs' { 'rust' }
					'toml' { 'toml' }
					'yaml', 'yml' { 'yaml' }
					else { lang }
				}
			}
			return 'unknown'
		}
	}
}

fn run_auto_operation(dirPath string, typ string, op Operation, auto_format bool, file_name string) ! {
	operation_str := if op == .lint { 'linting' } else { 'formatting' }
	target_desc := if file_name != '' {
		'file: ${format_path(file_name)}'
	} else {
		'directory: ${format_path(dirPath)}'
	}
	print_info('Running ${operation_str} automatically on ${target_desc} for type: ${typ}')
	run_auto_mode(dirPath, file_name, typ, op, auto_format)!
}

fn run_semi_auto_operation(dirPath string, typ string, op Operation, auto_format bool, file_name string) ! {
	operation_str := if op == .lint { 'linting' } else { 'formatting' }
	target_desc := if file_name != '' { file_name } else { dirPath }
	print_separator()
	print_info('Operation: ${operation_str}')
	print_info('Target: ${format_path(target_desc)}')
	print_info('Type: ${typ}')
	print_separator()

	mut confirm := ''
	for {
		print_prompt('Proceed with ${operation_str}? (y/n): ')
		confirm = os.input('').to_lower()
		if confirm in ['y', 'n'] {
			break
		}
		print_warning('Please enter "y" or "n".')
	}
	if confirm == 'n' {
		print_info('${operation_str} cancelled.')
		return
	}
	run_auto_mode(dirPath, file_name, typ, op, auto_format)!
}
