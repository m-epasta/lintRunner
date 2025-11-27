module executor

import os

// entry point for auto_mode
// takes the file_path as argument and the type of the file given with the param filePath
fn run_auto_mode(dirPath string, fileName string, typ string, op Operation, auto_format bool) ! {
	// cd in the dir
	go_to_path(dirPath)

	operation_str := if op == .lint { 'linting' } else { 'formatting' }

	// process type to know what data should be executed
	processed_cmd := choose_cmd_by_op_and_typ(op, typ, fileName)

	print_command(processed_cmd)

	// execute the lint/format command
	cmd_result := os.execute(processed_cmd)

	// Special handling for V formatting
	if typ == 'v' && op == .format {
		handle_v_formatting(cmd_result, fileName, auto_format)!
	} else if op == .format {
		// For other types, check if formatting is needed and prompt
		handle_generic_formatting(cmd_result, typ, fileName, auto_format)!
	} else {
		// For linting other types, use standard error handling
		if cmd_result.exit_code != 0 {
			if cmd_result.output.len > 0 {
				print_error('${operation_str} errors found:')
				eprintln(cmd_result.output)
			}
			verify_cmd(cmd_result, processed_cmd)
		} else {
			print_success('${operation_str} passed for type ${typ}')
		}
	}
}

// Handle V formatting with file listing and auto-fix prompt
fn handle_v_formatting(cmd_result os.Result, fileName string, auto_format bool) ! {
	files_to_fix := cmd_result.output.trim_space()

	if files_to_fix.len == 0 {
		print_success('All V files are properly formatted')
		return
	}

	// Show which files need formatting
	print_separator()
	print_warning('The following files need formatting:')
	println('')
	for line in files_to_fix.split('\n') {
		if line.len > 0 {
			println('  ${format_path(line)}')
		}
	}

	// Count files
	file_list := files_to_fix.split('\n').filter(it.len > 0)
	file_count := file_list.len
	println('')
	print_info('Found ${format_count(file_count)} file(s) with formatting issues.')
	print_separator()

	// Skip prompt if auto_format is enabled
	if auto_format {
		print_info('Auto-format enabled, proceeding without prompt...')
	} else {
		// Prompt user to fix
		mut confirm := ''
		for {
			print_prompt('Would you like to auto-format these files? (y/n): ')
			confirm = os.input('').to_lower()
			if confirm in ['y', 'n'] {
				break
			}
			print_warning('Please enter "y" or "n".')
		}

		if confirm == 'n' {
			print_info('Skipped auto-formatting.')
			return error('Files need formatting but auto-fix was declined')
		}
	}

	// Auto-fix the files
	fix_cmd := if fileName != '' {
		'v fmt -w ${fileName}'
	} else {
		'v fmt -w .'
	}

	print_command(fix_cmd)
	fix_result := os.execute(fix_cmd)

	if fix_result.exit_code != 0 {
		return error('Auto-formatting failed: ${fix_result.output}')
	}

	print_success('Successfully formatted ${format_count(file_count)} file(s)')
}

// FIRST STEP
// cd in the dir
fn go_to_path(dirPath string) {
	os.chdir(dirPath) or { exit_error('Failed to change directory to ${dirPath}: ${err}', 2) }

	// verify if we are in the right dir
	pwd_cmd := os.execute('pwd')
	verify_cmd(pwd_cmd, 'pwd')

	print_success('Changed directory to: ${format_path(pwd_cmd.output.trim_space())}')
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
fn handle_generic_formatting(cmd_result os.Result, typ string, fileName string, auto_format bool) ! {
	if cmd_result.exit_code == 0 {
		print_success('All ${typ} files are properly formatted')
		return
	}

	// For most formatters, non-zero exit means formatting needed
	needs_formatting := cmd_result.exit_code != 0

	if !needs_formatting {
		print_success('All ${typ} files are properly formatted')
		return
	}

	// Show what would be changed (if available)
	print_separator()
	if cmd_result.output.len > 0 {
		print_warning('Formatting differences found:')
		println('')
		println(cmd_result.output)
		println('')
	}
	print_info('Files need ${typ} formatting.')
	print_separator()

	// Skip prompt if auto_format is enabled
	if auto_format {
		print_info('Auto-format enabled, proceeding without prompt...')
	} else {
		// Prompt user to fix
		mut confirm := ''
		for {
			print_prompt('Would you like to auto-format these files? (y/n): ')
			confirm = os.input('').to_lower()
			if confirm in ['y', 'n'] {
				break
			}
			print_warning('Please enter "y" or "n".')
		}

		if confirm == 'n' {
			print_info('Skipped auto-formatting.')
			return error('Files need formatting but auto-fix was declined')
		}
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

	print_command(fix_cmd)
	fix_result := os.execute(fix_cmd)

	if fix_result.exit_code != 0 {
		return error('Formatting failed: ${fix_result.output}')
	}

	print_success('Successfully formatted ${typ} files')
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
