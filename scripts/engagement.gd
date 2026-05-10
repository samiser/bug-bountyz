extends Node

const DECAY_PER_ACTION : int = 2
const BURN_THRESHOLD : int = 100

var captures : Array[Dictionary] = []
var money : int = 0
var detection_by_bounty : Dictionary = {}
var burned_bounties : Array[String] = []
var discovered_pages : Array[String] = []
var discovered_sites : Array[String] = []
var claimed_findings : Array[String] = []

signal detection_changed(bounty_id: String, new_value: int)
signal money_changed(new_value: int)
signal capture_added(capture: Dictionary)
signal page_discovered(url: String)
signal site_discovered(domain: String)
signal action_invoked(name: String, args: Array)
signal bounty_burned(bounty_id: String)

func add_detection(bounty_id: String, amount: int) -> void:
	if bounty_id.is_empty() or burned_bounties.has(bounty_id):
		return

	var current : int = detection_by_bounty.get(bounty_id, 0)
	var new_value : int = clamp(current + amount, 0, BURN_THRESHOLD)
	detection_by_bounty[bounty_id] = new_value
	detection_changed.emit(bounty_id, new_value)

	if new_value >= BURN_THRESHOLD:
		burned_bounties.append(bounty_id)
		bounty_burned.emit(bounty_id)

	for other_id in detection_by_bounty.keys():
		if other_id == bounty_id or burned_bounties.has(other_id):
			continue
		var other_current : int = detection_by_bounty[other_id]
		var other_new : int = max(0, other_current - DECAY_PER_ACTION)
		if other_new != other_current:
			detection_by_bounty[other_id] = other_new
			detection_changed.emit(other_id, other_new)

func get_detection(bounty_id: String) -> int:
	return detection_by_bounty.get(bounty_id, 0)

func is_burned(bounty_id: String) -> bool:
	return burned_bounties.has(bounty_id)

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

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func claim_finding(key: String) -> bool:
	if claimed_findings.has(key):
		return false
	claimed_findings.append(key)
	return true

func is_finding_claimed(key: String) -> bool:
	return claimed_findings.has(key)
