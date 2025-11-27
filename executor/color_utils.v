module executor

import term

// Color utility functions for better CLI readability

// Success messages (green with checkmark)
pub fn print_success(msg string) {
	println(term.green('✓ ${msg}'))
}

// Error messages (red with cross)
pub fn print_error(msg string) {
	eprintln(term.red('✗ ${msg}'))
}

// Warning messages (yellow with warning symbol)
pub fn print_warning(msg string) {
	println(term.yellow('⚠ ${msg}'))
}

// Info messages (cyan)
pub fn print_info(msg string) {
	println(term.cyan('ℹ ${msg}'))
}

// Highlighted/emphasized text (bright white/bold)
pub fn print_highlight(msg string) {
	println(term.bright_white(term.bold(msg)))
}

// Command text (bright magenta)
pub fn print_command(msg string) {
	println(term.bright_magenta('$ ${msg}'))
}

// Prompt text (bright blue with prompt symbol)
pub fn print_prompt(msg string) {
	print(term.bright_blue('❯ ${msg}'))
}

// File path (bright white)
pub fn format_path(path string) string {
	return term.bright_white(path)
}

// Format a number/count (bright cyan)
pub fn format_count(count int) string {
	return term.bright_cyan('${count}')
}

// Section header (bold bright blue)
pub fn print_header(msg string) {
	println(term.bright_blue(term.bold(msg)))
}

// Separator line
pub fn print_separator() {
	println(term.gray('─'.repeat(60)))
}
