extends Node

const ALL : Dictionary = {
	"port_scanner": {
		"name": "Port Scanner",
		"price": 100,
		"description": "scans a host for open ports and the services running on them",
	},
	"directory_fuzzer": {
		"name": "Directory Fuzzer",
		"price": 300,
		"description": "discovers pages on a host that aren't linked from anywhere",
	},
}

const HELP : Dictionary = {
	"Browser": """[b]Browser[/b]
Your window to the world wide web. navigate by clicking links, or type a url directly into the address bar.

[b]View Source[/b]
Shows the source code of the current page. Developers sometimes leave comments, debug notes, or references to hidden pages in the source.""",
	"Port Scanner": """[b]Port Scanner[/b]

Scans a host for open network ports and identifies the services running on each port and its version. \
You can cross-reference with the CVE Directory to find vulnerable software.

[b]How to use:[/b] Pick a discovered site from the dropdown menu and click scan. Each open port and its service are listed. Click capture output to save the scan as evidence.

[b][color=red]Warning:[/color][/b] Port scanning is noisy and raises the engagement's detection meter. If your detection level reaches 100, the engagement will be closed.""",

	"Directory Fuzzer": """[b]Directory Fuzzer[/b]

Discovers pages on a host that aren't linked from anywhere else by brute force guessing potential pages. Great for finding pages you're not supposed to access or pages in development.

[b]How to use:[/b] pick a target site and click fuzz. discovered paths are shown as clickable links. click capture output to save the results as evidence.

[b][color=red]Warning:[/color][/b] fuzzing is louder than port scanning and raises detection more aggressively.""",

	"CVE Directory": """[b]CVE Directory[/b]

A database of publicly known vulnerabilities. Each entry describes a flaw in a specific piece of software, as well as what versions are affected.

[b]How to use:[/b] If you see a specific version of any software being used (port scanning or through other means), you can look through CVEs and cross-reference the [b]affected version[/b] field with what you found. if a target runs the affected version, that CVE is a viable finding.""",
}
