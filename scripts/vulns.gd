extends Node

const ALL : Array[String] = [
	"Remote Code Execution",
	"Authentication Bypass",
	"Information Disclosure",
]

const SPECIFICS_BY_CLASS : Dictionary = {
	"Authentication Bypass": [
		"Missing Authentication Check",
	],
	"Information Disclosure": [
		"Verbose Error Message",
		"Internal Service Exposed",
	],
}

const HELP : Dictionary = {
	"Remote Code Execution": """[b]Remote Code Execution[/b]

An attacker can run arbitrary code on the target. Very bad news.

[b]Relevant tools:[/b] Port Scanner

[b]How to find it:[/b] Match a fingerprint from your port scanner to a CVE in your CVE Directory.""",

	"Authentication Bypass": """[b]Authentication Bypass[/b]

Accessing something that should require a login without logging in.

[b]Relevant tools:[/b] Browser, Directory Fuzzer

[b]How to find it:[/b] A page that's indicated to be protected by authentication but actually isn't.""",

	"Information Disclosure": """[b]Information Disclosure[/b]

Revealing data unintentionally, could be internal details, sensitive files, software versions, etc.

[b]Relevant tools:[/b] Browser, Directory Fuzzer

[b]How to find it:[/b] A page that tells you more than it should, or services unintentionally exposed to the internet.""",
}
