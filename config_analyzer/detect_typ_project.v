module config_analyzer

import os

// const for supported extensions — goal is to avoid repetition of this helper variable
const supported_extensions = ['.json', '.yaml', '.yml', '.toml', '.mod']

pub struct FileMetadata {
	file_name string
	file_ext string
}


// if a path is provided, use it to detect what types of config file is provided
// for now: get the extension of the given path
pub fn get_config_file_typ(filePath string) !string {
	// clean the file path to have something like:
	// ORIGINAL: /home/m-epasta/vlang_devTools/lintRunner/config_analyzer/v.mod
	// PROCESSED: v.mod
	file_info := process_file_path_as_str(filePath)!

	return detect_config_type(file_info)
}

fn process_file_path_as_str(filePath string) !FileMetadata {
	validate_input(filePath)!

	// now get the file extension with the help of os lib — a tuple get retrieved containing tup.0 = fileName tup.1 = fileExt

	file_name := os.base(filePath)
	file_ext := os.file_ext(filePath)

	return FileMetadata{ file_name, file_ext }
}

// input = filePath
fn validate_input(input string) ! {
	// get the extension' input — maybe optimize the code to get one usage of ```v os.file_ext``` ?
	input_extension := os.file_ext(input)

	if input_extension !in supported_extensions {
		return error('actual extension not supported by the tool.')
	}
}

fn detect_config_type(fi FileMetadata) string {
	if fi.file_name == 'v.mod' && fi.file_ext == '.mod' {
		return 'v_language_module'
	} else if fi.file_ext == '.json' {
		if fi.file_name.starts_with('package') {
			return 'package_config'
		} else if fi.file_name.contains('config') || fi.file_name.contains('settings') {
			return 'app_config'
		} else {
			return 'generic_json'
		}
	} else {
		return 'unknown_${fi.file_ext}'
	}
}
