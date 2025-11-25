module main

import os
import flag
import config_analyzer



fn main() {
	// Entry point
	mut fp := flag.new_flag_parser(os.args)
	fp.application("lintRunner")
	fp.description("a CLI tool that automate the execution of linting scripts")
	fp.version("0.0.0")

	mut mode := fp.string('mode', `m`, 'auto', 'Specify the execution mode: auto or semi-auto')
	mut config_path := fp.string('config', `c`, '', 'Path to the config file. If empty, will auto-detect from current directory')

	println('=== LINTRUNNER executed ===')
	// calls 	
	run_mode(mode, config_path)


}

fn run_mode(mode string, config_path string) {
	target_path := if config_path != '' { config_path } else { detect_config_file() }

	if target_path == '' {
		println('No config file found. Unable to proceed.')
		return
	}

    println('Using config file: ${target_path}')

	match mode {
		'auto' {
			println('Running in AUTO MODE')
			run_auto_mode(target_path)
		}
		'semi-auto' {
			println('Running in SEMI AUTO MODE')
			run_semi_auto_mode(target_path)
		}
		else {
			eprintln('Invalid mode. Use "auto" or "semi-auto".')
			return
		}
	}
}

const supported_extensions = ['.json', '.yaml', '.yml', '.toml', '.mod']

fn detect_config_file() string {
	files := os.ls('.') or { return '' }
	for file in files {
		ext := os.file_ext(file)
		if ext in supported_extensions {
			return file
		}
	}
	return ''
}

fn run_auto_mode(path string) {
	config_type := config_analyzer.get_config_file_typ(path) or {
		println('Error detecting config type: ${err}')
		return
	}
	println('Detected config type: ${config_type}')
	println('Running lint automatically...')
	// TODO: implement actual linting logic based on config_type
}

fn run_semi_auto_mode(path string) {
	config_type := config_analyzer.get_config_file_typ(path) or {
		println('Error detecting config type: ${err}')
		return
	}
	println('Detected config type: ${config_type}')
	confirm := os.input('Proceed with linting? (y/n): ')
	if confirm == 'y' {
		println('Running lint in semi-auto mode...')
		// TODO: implement actual linting logic based on config_type
	} else {
		println('Linting cancelled.')
	}
}
