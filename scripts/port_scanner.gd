extends VBoxContainer

@export var target_dropdown : OptionButton
@export var scan_button : Button
@export var output_label : RichTextLabel
@export var capture_button : Button
@export var detection_label : Label

var _last_output : String = ""
var _last_output_tags : Array[String] = []

func _ready() -> void:
	Engagement.site_discovered.connect(_on_site_discovered)
	scan_button.pressed.connect(_on_scan_pressed)
	capture_button.pressed.connect(_on_capture_pressed)
	capture_button.disabled = true
	capture_button.text = "capture output"
	output_label.text = "[i]select a target and scan.[/i]"
	detection_label.text = ""
	_refresh_targets()

func _refresh_targets() -> void:
	target_dropdown.clear()
	for domain in Engagement.discovered_sites:
		target_dropdown.add_item(domain)

func _on_site_discovered(_domain: String) -> void:
	_refresh_targets()

func _on_scan_pressed() -> void:
	var idx := target_dropdown.selected
	if idx < 0:
		Sound.play_error()
		return

	var domain := target_dropdown.get_item_text(idx)
	var site_path := Url.site_resource_path(domain)
	var site : Site = load(site_path) if ResourceLoader.exists(site_path) else null
	print("scanning %s" % domain)

	if site == null or site.fingerprints.is_empty():
		output_label.text = "[i]no services found.[/i]"
		_last_output = ""
		_last_output_tags = []
		_update_capture_button()
		Sound.play_error()
		return

	var output := _format_scan(domain, site.fingerprints)
	_last_output = output
	_last_output_tags = ["port-scan", domain]

	output_label.text = output
	detection_label.text = "detection: +5%"
	Engagement.add_detection(5)
	_update_capture_button()
	Sound.play_click()

func _format_scan(target: String, fingerprints: Array[String]) -> String:
	var lines := ["[code]> scanning " + target + "...", ""]
	lines.append("PORT     SERVICE  VERSION")
	for fp in fingerprints:
		lines.append(fp)
	lines.append("")
	lines.append("scan complete.[/code]")
	return "\n".join(lines)

func _on_capture_pressed() -> void:
	Engagement.add_capture(_last_output, "port_scanner", _last_output_tags)
	_update_capture_button()
	Sound.play_click()

func _update_capture_button() -> void:
	if _last_output.is_empty():
		capture_button.disabled = true
		capture_button.text = "capture output"
		return
	if Engagement.has_capture("port_scanner", _last_output_tags):
		capture_button.disabled = true
		capture_button.text = "captured ✓"
	else:
		capture_button.disabled = false
		capture_button.text = "capture output"
