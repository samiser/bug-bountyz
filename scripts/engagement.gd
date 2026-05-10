extends Node

var captures : Array[Dictionary] = []
var detection : int = 0
var discovered_pages : Array[String] = []
var discovered_sites : Array[String] = []
var read_cves : Array[String] = []

signal detection_changed(new_value: int)
signal capture_added(capture: Dictionary)
signal page_discovered(url: String)
signal site_discovered(domain: String)
signal cve_read(id: String)

func add_detection(amount: int) -> void:
	detection += amount
	detection_changed.emit(detection)

func add_capture(content: String, source_tool: String, tags: Array[String]) -> bool:
	if has_capture(source_tool, tags):
		return false
	var capture := {
		"content": content,
		"source_tool": source_tool,
		"tags": tags,
		"timestamp": Time.get_ticks_msec(),
	}
	captures.append(capture)
	capture_added.emit(capture)
	print("captured: " + source_tool + " " + str(tags))
	return true

func has_capture(source_tool: String, tags: Array[String]) -> bool:
	for c in captures:
		if c.source_tool == source_tool and c.tags == tags:
			return true
	return false

func discover_page(url: String) -> void:
	if not discovered_pages.has(url):
		discovered_pages.append(url)
		page_discovered.emit(url)

func discover_site(domain: String) -> void:
	if domain.is_empty():
		return
	if not discovered_sites.has(domain):
		discovered_sites.append(domain)
		site_discovered.emit(domain)

func read_cve(id: String) -> void:
	if id.is_empty():
		return
	if not read_cves.has(id):
		read_cves.append(id)
		cve_read.emit(id)
