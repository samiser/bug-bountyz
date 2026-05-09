extends Node

var captures : Array[Dictionary] = []
var detection : int = 0
var discovered_pages : Array[String] = []

signal detection_changed(new_value: int)
signal capture_added(capture: Dictionary)
signal page_discovered(page_path: String)

func add_detection(amount: int) -> void:
	detection += amount
	detection_changed.emit(detection)

func add_capture(content: String, source_tool: String, tags: Array[String]) -> void:
	var capture := {
		"content": content,
		"source_tool": source_tool,
		"tags": tags,
		"timestamp": Time.get_ticks_msec(),
	}
	captures.append(capture)
	capture_added.emit(capture)
	print("captured: " + source_tool + " " + str(tags))

func discover_page(page_path: String) -> void:
	if not discovered_pages.has(page_path):
		discovered_pages.append(page_path)
		page_discovered.emit(page_path)
