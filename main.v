module main

import os
import flag
import executor

fn main() {
	// init CLI program with a parser from flag lib
	mut fp := flag.new_flag_parser(os.args)
	fp.application('lintRunner')
	fp.description('a CLI tool that automate the execution of linting and formatting scripts')
	fp.version('0.0.0')

	// init the actual configs
	mut mode_str := fp.string('mode', `m`, 'auto', 'Specify the execution mode: auto or semi-auto')
	mut config_path := fp.string('config', `c`, '', 'Path to the config file. If empty, will auto-detect from current directory')
	mut operation := fp.string('operation', `o`, 'lint', 'Specify the operation: lint or format')

	// Finalize the flag parser (this handles --help, --version, validates flags)
	_ := fp.finalize() or {
		executor.exit_error(err.msg(), 1)
		return
	}

	opts := executor.parse_and_validate_options(mode_str, config_path, operation) or {
		executor.exit_error(err.msg(), err.code())
	}

	println('=== LINTRUNNER executed ===')

	// switch from entry point to executor logic
	executor.execute_operation(opts) or {
		operation_str := if opts.operation == .lint { 'linting' } else { 'formatting' }
		executor.exit_error('${operation_str} failed: ${err.msg()}', err.code())
	}
}
