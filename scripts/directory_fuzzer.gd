extends VBoxContainer

@export var target_dropdown : OptionButton
@export var fuzz_button : Button
@export var output_label : RichTextLabel
@export var capture_button : Button

var _last_output : String = ""
var _last_output_tags : Array[String] = []

func _ready() -> void:
	Engagement.site_discovered.connect(_on_site_discovered)
	Engagement.capture_added.connect(_on_capture_added)
	fuzz_button.pressed.connect(_on_fuzz_pressed)
	capture_button.pressed.connect(_on_capture_pressed)
	output_label.meta_clicked.connect(_on_url_clicked)
	output_label.text = "[i]select a target and fuzz.[/i]"
	_refresh_targets()
	_update_capture_button()

func _refresh_targets() -> void:
	target_dropdown.clear()
	for domain in Engagement.discovered_sites:
		target_dropdown.add_item(domain)

func _on_site_discovered(_domain: String) -> void:
	_refresh_targets()

func _on_fuzz_pressed() -> void:
	var idx := target_dropdown.selected
	if idx < 0:
		Sound.play_error()
		return

	var domain := target_dropdown.get_item_text(idx)
	var site : Site = Sites.get_by_domain(domain)
	var found : Array[String] = []
	if site != null:
		for page in site.pages:
			if page != null:
				found.append(Url.to_url(page))

	if found.is_empty():
		output_label.text = "[i]no paths found.[/i]"
		_last_output = ""
		_last_output_tags = []
		_update_capture_button()
		Sound.play_error()
		return

	var output := _format_output(domain, found)
	_last_output = output
	_last_output_tags = ["fuzz", domain]

	output_label.text = output
	var bounty := Bounties.find_by_site(domain)
	if bounty != null:
		Engagement.add_detection(bounty.id, 10)
	_update_capture_button()
	Sound.play_click()

func _format_output(target: String, paths: Array[String]) -> String:
	var lines := ["[code]> fuzzing " + target + "...", ""]
	for url in paths:
		lines.append("[color=lime]200[/color] [url=%s]%s[/url]" % [url, url])
	lines.append("")
	lines.append("scan complete. %d paths found.[/code]" % paths.size())
	return "\n".join(lines)

func _on_capture_pressed() -> void:
	Engagement.add_capture(_last_output, "directory_fuzzer", _last_output_tags)
	_update_capture_button()
	Sound.play_click()

func _update_capture_button() -> void:
	if _last_output.is_empty():
		capture_button.disabled = true
		capture_button.text = "capture output"
		return
	if Engagement.has_capture("directory_fuzzer", _last_output_tags):
		capture_button.disabled = true
		capture_button.text = "captured *"
	else:
		capture_button.disabled = false
		capture_button.text = "capture output"

func _on_capture_added(_capture: Dictionary) -> void:
	_update_capture_button()

func _on_url_clicked(meta: String) -> void:
	Engagement.action_invoked.emit("navigate", [meta])
