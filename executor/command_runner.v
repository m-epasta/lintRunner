module executor

import os 


// entry point for auto_mode
// takes the file_path as argument and the type of the file given with the param filePath
fn run_auto_mode(dirPath string, fileName string, typ string) ! {
	// cd in the dir
	go_to_path(dirPath)

}

fn go_to_path(dirPath string) {
    os.chdir(dirPath) or {
        exit_error('Failed to change directory to ${dirPath}: ${err}', 2)
    }
    
	// verify if we are in the right dir
    pwd_cmd := os.execute('pwd')
    verify_cmd(pwd_cmd, 'pwd')
    
    println('Successfully executed "cd" command: changed pointer to: ${pwd_cmd.output}')
}

// TODO: implement specific check and a bool that affect if the result is returned
fn verify_cmd(cmd_result os.Result, cmd string) {
	result_output := cmd_result.output
    exit_code := cmd_result.exit_code

	if exit_code == 2 {
		exit_error('Failed to change directory with command: ${cmd}: ${result_output}. Exited with code ${exit_code}', 2)
	}

    if exit_code != 0 {
        exit_error('command: ${cmd} failed with error code ${exit_code}', 1)
    }
}