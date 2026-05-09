extends VBoxContainer

@export var target_dropdown : OptionButton
@export var scan_button : Button
@export var output_label : RichTextLabel
@export var capture_button : Button
@export var detection_label : Label

var _last_output : String = ""
var _last_output_tags : Array[String] = []

func _ready() -> void:
	Engagement.page_discovered.connect(_on_page_discovered)
	scan_button.pressed.connect(_on_scan_pressed)
	capture_button.pressed.connect(_on_capture_pressed)
	capture_button.disabled = true
	capture_button.text = "capture output"
	output_label.text = "[i]select a target and scan.[/i]"
	detection_label.text = ""
	_refresh_targets()

func _refresh_targets() -> void:
	target_dropdown.clear()
	for page_path in Engagement.discovered_pages:
		target_dropdown.add_item(page_path)

func _on_page_discovered(_page_path: String) -> void:
		_refresh_targets()

func _on_scan_pressed() -> void:
	var idx := target_dropdown.selected
	if idx < 0:
		Sound.play_error()
		return

	var page_path := target_dropdown.get_item_text(idx)
	var page : Page = load(page_path)
	print("scanning %s" % page_path)

	if page == null or page.fingerprints.is_empty():
		output_label.text = "[i]no services found.[/i]"
		Sound.play_error()
		return

	var output := _format_scan(page_path, page.fingerprints)
	_last_output = output
	_last_output_tags = ["port-scan", "fingerprint", page_path]

	output_label.text = output
	detection_label.text = "detection: +5%"
	Engagement.add_detection(5)

	capture_button.disabled = false
	capture_button.text = "capture output"
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
	capture_button.disabled = true
	capture_button.text = "captured ✓"
	Sound.play_click()
