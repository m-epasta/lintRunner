module main

import os

fn main() {
	// Entry point
	println('=== LINTRUNNER executed ===')

	// Ask for the mode of configs
	ask_for_mode()

	
}

fn ask_for_mode() {
	user_requested_mode := os.input("1.AUTO MODE || 2.SEMI AUTO MODE")

	match user_requested_mode {
		"1" {
			println("USING AUTO MODE")
		}
		"2" {
			println("USING SEMI AUTO MODE")
		}
		else {
			println("Invalid input. Make sure to type 1 or 2 according to your request.")
			user_requested_mode
		}
	}
}