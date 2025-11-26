module executor

// no return fn util that print an error and exit 
@[noreturn]
pub fn exit_error(msg string, code int) {
	eprintln('Error: ${msg}')
	exit(i8(code)) // i8 to make sure i dont use stupid exit code
}