module executor

import os 


// entry point for auto_mode
// takes the file_path as argument and the type of the file given with the param filePath
fn run_auto_mode(dirPath string, fileName string, typ string) ! {
	// cd in the dir
	go_to_path(dirPath)

    // process type to know what data should be executed
    processed_cmd := choose_cmd_by_typ(typ, fileName)

    // execute the lint command
    cmd_result := os.execute(processed_cmd)
    verify_cmd(cmd_result, processed_cmd)

    println('Linting completed for type ${typ}')


}

// FIRST STEP
// cd in the dir
fn go_to_path(dirPath string) {
    os.chdir(dirPath) or {
        exit_error('Failed to change directory to ${dirPath}: ${err}', 2)
    }
    
	// verify if we are in the right dir
    pwd_cmd := os.execute('pwd')
    verify_cmd(pwd_cmd, 'pwd')
    
    println('Successfully executed "cd" command: changed pointer to: ${pwd_cmd.output}')
}

// SECOND STEP
fn choose_cmd_by_typ(typ string, fileName string) string {
    return match typ {
        'v' {
            if fileName != '' {
                'v fmt --check ${fileName}'
            } else {
                'v fmt --check .'
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
        else {
            'echo "Unknown type ${typ}: no linting command available"'
        }
    }
}


// ===================================== CMD ERROR HANDLING =====================================
fn verify_cmd(cmd_result os.Result, cmd string) {
	result_output := cmd_result.output
    exit_code := cmd_result.exit_code

	if exit_code == 2 {
		exit_error('Failed to change directory with command: ${cmd}: ${result_output}. Exited with code ${exit_code}', 2)
	}

    if exit_code != 0 {
        exit_error('command: ${cmd} failed with error code ${exit_code}. Error: ${result_output}', 1)
    }
}
