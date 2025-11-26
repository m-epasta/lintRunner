module executor

// no return fn util that print an error and exit
@[noreturn]
pub fn exit_error(msg string, code int) {
	eprintln('Error: ${msg}')
	exit(i8(code)) // i8 to make sure i dont use stupid exit code
}

// STRUCT FOR main;v error handling
pub struct LintError {
	msg  string
	code int
}

pub fn main_file_err_handler(l LintError) {
	eprintln('Error: ${l.msg}')
	exit(i8(l.code))
}
