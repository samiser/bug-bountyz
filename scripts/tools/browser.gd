extends Control

var current_page : Page

@export var homepage : Page

@onready var page_panel: Control = $VBoxContainer/page_panel
@onready var content_label: RichTextLabel = $VBoxContainer/page_panel/content_label
@onready var background_image: TextureRect = $VBoxContainer/page_panel/background_image
@onready var background_colour: ColorRect = $VBoxContainer/page_panel/background_colour
@onready var page_scene_container: Control = $VBoxContainer/page_panel/page_scene_container

@onready var prev_button: Button = $VBoxContainer/control_panel/HBoxContainer/PrevButton
@onready var next_button: Button = $VBoxContainer/control_panel/HBoxContainer/NextButton
@onready var home_button: Button = $VBoxContainer/control_panel/HBoxContainer/HomeButton
@onready var history_button: Button = $VBoxContainer/control_panel/HBoxContainer/HistoryButton
@onready var refresh_button: Button = $VBoxContainer/control_panel/HBoxContainer/RefreshButton
@onready var url_input: LineEdit = $VBoxContainer/control_panel/HBoxContainer/ColorRect/url_label

@onready var page_music: AudioStreamPlayer = $page_music

@onready var source_panel: Control = $VBoxContainer/source_panel
@onready var source_content_label: RichTextLabel = $VBoxContainer/source_panel/content_label
@onready var source_button: Button = $VBoxContainer/control_panel/HBoxContainer/SourceButton
@onready var source_capture_button: Button = $CaptureButton

var current_history_index : int = 0
var history : Array[String]

func _ready() -> void:
	content_label.meta_clicked.connect(_on_meta_clicked)
	
	prev_button.button_down.connect(_back)
	next_button.button_down.connect(_next)
	home_button.button_down.connect(func() : _load_page(homepage))
	history_button.button_down.connect(_view_history)
	refresh_button.button_down.connect(_refresh)
	source_button.button_down.connect(_toggle_source)
	source_capture_button.pressed.connect(_capture_source)
	url_input.text_submitted.connect(_on_url_submitted)
	Engagement.capture_added.connect(_on_capture_added)
	Engagement.action_invoked.connect(_on_action)
	Engagement.tool_unlocked.connect(_on_tool_unlocked)

	source_panel.visible = false
	source_content_label.bbcode_enabled = false

	var window := get_parent() as Window
	if window != null:
		window.visibility_changed.connect(_on_window_visibility_changed)

	_load_page(homepage, true, false)

func _back() -> void:
	if history.size() <= 1 or current_history_index == 0:
		print("Can't go back!")
		Sound.play_error()
		return

	var last_url : String = history[current_history_index - 1]
	var last_page : Page = load(Url.resolve(last_url))
	current_history_index -= 1
	_load_page(last_page, false)

func _next() -> void:
	if current_history_index >= history.size() - 1:
		print("Can't go forward!")
		Sound.play_error()
		return
	
	var next_url : String = history[current_history_index + 1]
	var next_page : Page = load(Url.resolve(next_url))
	current_history_index += 1
	_load_page(next_page, false)

func _refresh() -> void:
	if current_page:
		_load_page(current_page, false)
	else:
		Sound.play_error()

func _load_page(page : Page, add_history : bool = true, play_sound : bool = true) -> void:
	var url := Url.to_url(page)

	url_input.text = url

	Engagement.discover_page(url)
	Engagement.discover_site(Url.site_of(url))

	var site := Sites.get_by_domain(Url.site_of(url))
	page_panel.theme = site.theme if site != null else null

	Engagement.set_active_bounty(Bounties.find_by_page(page))

	if add_history and page != current_page:
		if history.size() - 1 > current_history_index:
			history.resize(current_history_index + 1)
		history.append(url)
		current_history_index = history.size() - 1

	for child in page_scene_container.get_children():
		child.queue_free()
	if page.scene != null:
		var instance := page.scene.instantiate()
		page_scene_container.add_child(instance)
		page_scene_container.visible = true
		content_label.visible = false
	else:
		page_scene_container.visible = false
		content_label.visible = true
		content_label.text = ""
		content_label.append_text(page.get_content())

	if page.music:
		if page_music.stream != page.music:
			page_music.stream = page.music
			if _is_window_visible():
				page_music.play()
	else:
		page_music.stream = null
		page_music.stop()

	background_image.visible = page.background_img != null
	if page.background_img:
		background_image.texture = page.background_img
	background_colour.color = page.background_colour

	current_page = page

	content_label.scroll_to_line(0)

	if source_panel.visible:
		source_panel.visible = false
		page_panel.visible = true
	_update_source_capture_button()

	if play_sound:
		Sound.play_click()

func _is_window_visible() -> bool:
	var window := get_parent() as Window
	return window != null and window.visible

func _on_window_visibility_changed() -> void:
	var window := get_parent() as Window
	if window == null:
		return
	if window.visible:
		if page_music.stream != null:
			page_music.play()
	else:
		page_music.stop()

func _toggle_source() -> void:
	if current_page == null:
		Sound.play_error()
		return
	if source_panel.visible:
		source_panel.visible = false
		page_panel.visible = true
	else:
		source_content_label.text = current_page.content
		source_panel.visible = true
		page_panel.visible = false
		_update_source_capture_button()
	Sound.play_click()

func _capture_source() -> void:
	if current_page == null:
		Sound.play_error()
		return
	Engagement.add_capture(
		current_page.content,
		"view_source",
		_source_tags(current_page),
	)
	Sound.play_click()

func _source_tags(page: Page) -> Array[String]:
	return ["view-source", Url.to_url(page)]

func _update_source_capture_button() -> void:
	if current_page == null:
		source_capture_button.disabled = true
		source_capture_button.text = "capture page"
		return
	if Engagement.has_capture("view_source", _source_tags(current_page)):
		source_capture_button.disabled = true
		source_capture_button.text = "captured *"
	else:
		source_capture_button.disabled = false
		source_capture_button.text = "capture page"

func _on_capture_added(_capture: Dictionary) -> void:
	_update_source_capture_button()

func _on_tool_unlocked(_id: String) -> void:
	if current_page is ShopPage:
		_load_page(current_page, false, false)

func _on_url_submitted(text: String) -> void:
	if text.is_empty():
		return
	var current_site := Url.site_of(history[history.size() - 1]) if not history.is_empty() else ""
	var page : Page = load(Url.resolve(text, current_site))
	if page == null:
		Sound.play_error()
		return
	_load_page(page)

func _on_action(name: String, args: Array) -> void:
	if name != "navigate" or args.is_empty():
		return
	var url : String = "/".join(args)
	var page : Page = load(Url.resolve(url))
	if page == null:
		Sound.play_error()
		return
	_load_page(page)
	var window := get_parent() as Window
	if window != null:
		window.show()
		window.move_to_foreground()

func _view_history() -> void:
	var history_page : Page = Page.new()
		
	history_page.content = "[color=BLACK]History:\n"
	
	var url_index : int = 0
	for url in history:
		if url_index == current_history_index:
			history_page.content += "- [color=BLUE]" + url + "[/color]\n"
		else:
			history_page.content += "- " + url + "\n"
		url_index += 1
		
	history_page.content += "[/color]"
	
	_load_page(history_page, false)

func _on_meta_clicked(meta: String) -> void:
	if meta.begins_with("action://"):
		_invoke_action(meta.substr("action://".length()))
		Sound.play_click()
		return

	var current_site := Url.site_of(history[history.size() - 1]) if not history.is_empty() else ""
	var resolved := Url.resolve(meta, current_site)
	var new_page : Page = load(resolved)
	if new_page == null:
		print("broken link: %s" % meta)
		Sound.play_error()
		return

	_load_page(new_page)

func _invoke_action(action_str: String) -> void:
	var parts := action_str.split("/", false)
	if parts.is_empty():
		return
	var name : String = parts[0]
	var args : Array = parts.slice(1)
	Engagement.action_invoked.emit(name, args)
