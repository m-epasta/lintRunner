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
	mode        Mode
pub:
	operation   Operation
	config_path ?string
}

pub fn parse_and_validate_options(mode_str string, config_path string, operation_str string) !Options {
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
	if config_path := opts.config_path {
		config_type := config_analyzer.get_config_file_typ(config_path)!

		println('Using config file: ${config_path}')
		println('Detected config type: ${config_type}')

		dir_path := os.dir(config_path)
		typ := map_config_to_typ(config_type)

		match opts.mode {
			.auto {
				println('Running in AUTO MODE')
				run_auto_operation(dir_path, typ, opts.operation)!
			}
			.semi_auto {
				println('Running in SEMI AUTO MODE')
				run_semi_auto_operation(config_type, opts.operation)
			}
		}
	} else {
		println('No config file found. Cannot proceed.')
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

fn run_auto_operation(dirPath string, typ string, op Operation) ! {
	operation_str := if op == .lint { 'linting' } else { 'formatting' }
	println('Running ${operation_str} automatically in directory: ${dirPath} for type: ${typ}')
	run_auto_mode(dirPath, '', typ, op)! // Cd to the project's directory and run auto lint/format for the specified typ (language/format)
}

fn run_semi_auto_operation(config_type string, op Operation) {
	operation_str := if op == .lint { 'linting' } else { 'formatting' }
	mut confirm := ''
	for {
		confirm = os.input('Proceed with ${operation_str}? (y/n): ').to_lower()
		if confirm in ['y', 'n'] {
			break
		}
		println('Please enter "y" or "n".')
	}
	if confirm == 'n' {
		println('${operation_str} cancelled.')
		return
	}
	println('Running in semi-auto mode...')
	// TODO: implement actual linting/formatting logic based on config_type
}
