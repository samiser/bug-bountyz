extends Node

const ALL : Array[String] = [
	"Remote Code Execution",
	"Cross-Site Scripting",
	"Path Traversal",
	"Authentication Bypass",
	"Information Disclosure",
]

const SPECIFICS_BY_CLASS : Dictionary = {
	"Authentication Bypass": [
		"Missing Authentication Check",
		"Predictable Session ID",
		"Insecure Direct Object Reference",
	],
	"Information Disclosure": [
		"Sensitive File Exposed",
		"Verbose Error Message",
		"Source Code Disclosure",
	],
	"Cross-Site Scripting": [
		"Reflected XSS",
		"Stored XSS",
	],
	"Path Traversal": [
		"Directory Traversal In URL Parameter",
	],
}
