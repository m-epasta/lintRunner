module main

import os
import flag
import executor

fn main() {
	// init CLI program with a parser from flag lib
	mut fp := flag.new_flag_parser(os.args)
	fp.application("lintRunner")
	fp.description("a CLI tool that automate the execution of linting scripts")
	fp.version("0.0.0")

	// init the 2 actual needed configs
	mut mode_str := fp.string('mode', `m`, 'auto', 'Specify the execution mode: auto or semi-auto')
	mut config_path := fp.string('config', `c`, '', 'Path to the config file. If empty, will auto-detect from current directory')

	opts := executor.parse_and_validate_options(mode_str, config_path) or { executor.exit_error(err.msg(), err.code()) }

	println('=== LINTRUNNER executed ===')

	// switch from entry point to executor logic
	executor.execute_linting(opts) or { executor.exit_error('Linting failed: ${err.msg()}', err.code()) }



}
