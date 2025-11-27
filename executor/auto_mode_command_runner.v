module executor

import os

// entry point for auto_mode
// takes the file_path as argument and the type of the file given with the param filePath
fn run_auto_mode(dirPath string, fileName string, typ string, op Operation) ! {
	// cd in the dir
	go_to_path(dirPath)

	operation_str := if op == .lint { 'linting' } else { 'formatting' }

	// process type to know what data should be executed
	processed_cmd := choose_cmd_by_op_and_typ(op, typ, fileName)

	println('Executing: ${processed_cmd}')

	// execute the lint/format command
	cmd_result := os.execute(processed_cmd)

	// Special handling for V formatting
	if typ == 'v' && op == .format {
		handle_v_formatting(cmd_result, fileName)!
	} else if op == .format {
		// For other types, check if formatting is needed and prompt
		handle_generic_formatting(cmd_result, typ, fileName)!
	} else {
		// For linting other types, use standard error handling
		if cmd_result.exit_code != 0 {
			if cmd_result.output.len > 0 {
				eprintln('\n${operation_str} errors found:')
				eprintln(cmd_result.output)
			}
			verify_cmd(cmd_result, processed_cmd)
		} else {
			println('✓ ${operation_str} passed for type ${typ}')
		}
	}
}

// Handle V formatting with file listing and auto-fix prompt
fn handle_v_formatting(cmd_result os.Result, fileName string) ! {
	files_to_fix := cmd_result.output.trim_space()

	if files_to_fix.len == 0 {
		println('✓ All V files are properly formatted')
		return
	}

	// Show which files need formatting
	println('\n⚠ The following files need formatting:')
	println(files_to_fix)

	// Count files
	file_list := files_to_fix.split('\n').filter(it.len > 0)
	file_count := file_list.len
	println('\nFound ${file_count} file(s) with formatting issues.')

	// Prompt user to fix
	mut confirm := ''
	for {
		confirm = os.input('Would you like to auto-format these files? (y/n): ').to_lower()
		if confirm in ['y', 'n'] {
			break
		}
		println('Please enter "y" or "n".')
	}

	if confirm == 'n' {
		println('Skipped auto-formatting.')
		return error('Files need formatting but auto-fix was declined')
	}

	// Auto-fix the files
	fix_cmd := if fileName != '' {
		'v fmt -w ${fileName}'
	} else {
		'v fmt -w .'
	}

	println('\nExecuting: ${fix_cmd}')
	fix_result := os.execute(fix_cmd)

	if fix_result.exit_code != 0 {
		return error('Auto-formatting failed: ${fix_result.output}')
	}

	println('✓ Successfully formatted ${file_count} file(s)')
}

// FIRST STEP
// cd in the dir
fn go_to_path(dirPath string) {
	os.chdir(dirPath) or { exit_error('Failed to change directory to ${dirPath}: ${err}', 2) }

	// verify if we are in the right dir
	pwd_cmd := os.execute('pwd')
	verify_cmd(pwd_cmd, 'pwd')

	println('Successfully executed "cd" command: changed pointer to: ${pwd_cmd.output}')
}

// SECOND STEP
fn choose_cmd_by_op_and_typ(op Operation, typ string, fileName string) string {
	return match op {
		.lint {
			match typ {
				'v' {
					if fileName != '' {
						'v fmt -l ${fileName}'
					} else {
						'v fmt -l .'
					}
				}
				'js' {
					'npm run lint'
				}
				'ts' {
					'tsc --noEmit'
				}
				'json' {
					'echo "JSON linting: no standard command available - consider installing prettier"'
				}
				'toml' {
					'cargo check'
				}
				else {
					'echo "Unknown type ${typ}: no linting command available"'
				}
			}
		}
		.format {
			match typ {
				'v' {
					if fileName != '' {
						'v fmt -l ${fileName}'
					} else {
						'v fmt -l .'
					}
				}
				'js', 'ts', 'json' {
					// Use Prettier for formatting JS/TS/JSON
					if fileName != '' {
						'prettier --check ${fileName}'
					} else {
						'prettier --check .'
					}
				}
				'yaml' {
					if fileName != '' {
						'prettier --check ${fileName}'
					} else {
						'prettier --check .'
					}
				}
				'toml' {
					// Rust/Cargo projects - check formatting
					'cargo fmt -- --check'
				}
				'python' {
					// Python - check with black
					if fileName != '' {
						'black --check --diff ${fileName}'
					} else {
						'black --check --diff .'
					}
				}
				'go' {
					// Go - check formatting
					'gofmt -d .'
				}
				else {
					'echo "Unknown type ${typ}: no formatting command available"'
				}
			}
		}
	}
}

// Handle generic formatting for other languages
fn handle_generic_formatting(cmd_result os.Result, typ string, fileName string) ! {
	if cmd_result.exit_code == 0 {
		println('✓ All ${typ} files are properly formatted')
		return
	}

	// For most formatters, non-zero exit means formatting needed
	needs_formatting := cmd_result.exit_code != 0

	if !needs_formatting {
		println('✓ All ${typ} files are properly formatted')
		return
	}

	// Show what would be changed (if available)
	if cmd_result.output.len > 0 {
		println('\n⚠ Formatting differences found:')
		println(cmd_result.output)
	}

	println('\nFiles need ${typ} formatting.')

	// Prompt user to fix
	mut confirm := ''
	for {
		confirm = os.input('Would you like to auto-format these files? (y/n): ').to_lower()
		if confirm in ['y', 'n'] {
			break
		}
		println('Please enter "y" or "n".')
	}

	if confirm == 'n' {
		println('Skipped auto-formatting.')
		return error('Files need formatting but auto-fix was declined')
	}

	// Generate fix command
	fix_cmd := match typ {
		'js', 'ts', 'json', 'yaml' {
			if fileName != '' {
				'prettier --write ${fileName}'
			} else {
				'prettier --write .'
			}
		}
		'python' {
			if fileName != '' {
				'black ${fileName}'
			} else {
				'black .'
			}
		}
		'go' {
			if fileName != '' {
				'gofmt -w ${fileName}'
			} else {
				'gofmt -w .'
			}
		}
		'toml' {
			'cargo fmt'
		}
		else {
			return error('No formatting fix command available for ${typ}')
		}
	}

	println('\nExecuting formatting: ${fix_cmd}')
	fix_result := os.execute(fix_cmd)

	if fix_result.exit_code != 0 {
		return error('Formatting failed: ${fix_result.output}')
	}

	println('✓ Successfully formatted ${typ} files')
}

// ===================================== CMD ERROR HANDLING =====================================
fn verify_cmd(cmd_result os.Result, cmd string) {
	result_output := cmd_result.output
	exit_code := cmd_result.exit_code

	if exit_code == 2 {
		exit_error('Failed to change directory with command: ${cmd}: ${result_output}. Exited with code ${exit_code}',
			2)
	}

	if exit_code != 0 {
		exit_error('command: ${cmd} failed with error code ${exit_code}. Error: ${result_output}',
			1)
	}
}
