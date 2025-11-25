module executor

import os
import config_analyzer

// set an enum to save what mode has actually been choose
pub enum Mode {
	auto
	semi_auto
}

// struct of the 2 configs
pub struct Options {
	mode        Mode
	config_path ?string
}

@[noreturn]
pub fn exit_error(msg string) {
	eprintln('Error: ${msg}')
	exit(1)
}

pub fn parse_and_validate_options(mode_str string, config_path string) !Options {
	mode := match mode_str {
		'auto' { Mode.auto }
		'semi-auto' { Mode.semi_auto }
		else { return error('Invalid mode "${mode_str}". Use "auto" or "semi-auto".') }
	}

	final_config_path := if config_path != '' {
		if !os.exists(config_path) {
			return error('Specified config file "${config_path}" does not exist.')
		}
		if !os.is_file(config_path) {
			return error('Specified config path "${config_path}" is not a file.')
		}
		ext := os.file_ext(config_path)
		if ext !in config_analyzer.supported_extensions {
			return error('Unsupported config file extension "${ext}". Supported: ${config_analyzer.supported_extensions}')
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
		mode: mode,
		config_path: if final_config_path != '' { final_config_path } else { none }
	}
}

fn detect_config_file() string {
	files := os.ls('.') or { return '' }
	for file in files {
		ext := os.file_ext(file)
		if ext in config_analyzer.supported_extensions {
			return file
		}
	}
	return ''
}

pub fn execute_linting(opts Options) ! {
	if config_path := opts.config_path {
		config_type := config_analyzer.get_config_file_typ(config_path)!

		println('Using config file: ${config_path}')
		println('Detected config type: ${config_type}')

		match opts.mode {
			.auto {
				println('Running in AUTO MODE')
				run_auto_lint(config_type)
			}
			.semi_auto {
				println('Running in SEMI AUTO MODE')
				run_semi_auto_lint(config_type)
			}
		}
	} else {
		println('No config file found. Linting cannot proceed.')
		return
	}
}

fn run_auto_lint(config_type string) {
	println('Running lint automatically...')
	// TODO: implement actual linting logic based on config_type
}

fn run_semi_auto_lint(config_type string) {
	mut confirm := ''
	for {
		confirm = os.input('Proceed with linting? (y/n): ').to_lower()
		if confirm in ['y', 'n'] { break }
		println('Please enter "y" or "n".')
	}
	if confirm == 'n' {
		println('Linting cancelled.')
		return
	}
	println('Running lint in semi-auto mode...')
	// TODO: implement actual linting logic based on config_type
}
