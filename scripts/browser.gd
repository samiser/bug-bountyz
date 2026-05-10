extends Control

@export var homepage : Page
@export var history_label : RichTextLabel

@onready var content_label: RichTextLabel = $content_label
@onready var background_image: TextureRect = $background_image
@onready var background_colour: ColorRect = $background_colour

@onready var page_music: AudioStreamPlayer = $page_music

var history : Array[String]

func _ready() -> void:
	content_label.meta_clicked.connect(_on_meta_clicked)
	_load_page(homepage)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_back()

func _back() -> void:
	if history.size() <= 1:
		print("Can't go back!")
		Sound.play_error()
		return

	var last_url : String = history[history.size() - 2]
	var last_page : Page = load(Url.resolve(last_url))
	history.remove_at(history.size() - 1)
	_load_page(last_page, false)
	Sound.play_click()

func _load_page(page : Page, add_history : bool = true) -> void:
	var url := Url.to_url(page)
	print("Loaded page: " + url)

	Engagement.discover_page(url)
	Engagement.discover_site(Url.site_of(url))

	if add_history: history.append(url)
	_display_history()

	content_label.text = ""
	content_label.append_text(page.get_content())
	
	if page.music:
		if page_music.stream != page.music:
			page_music.stream = page.music
			page_music.play()
	else:
		page_music.stream = null
		page_music.stop()
	
	background_image.visible = page.background_img != null
	if page.background_img:
		background_image.texture = page.background_img
	background_colour.color = page.background_colour

func _display_history() -> void:
	history_label.text = ""
	for url in history:
		history_label.append_text(url + "\n")

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
	Sound.play_click()

func _invoke_action(action_str: String) -> void:
	var parts := action_str.split("/", false)
	if parts.is_empty():
		return
	var name : String = parts[0]
	var args : Array = parts.slice(1)
	Engagement.action_invoked.emit(name, args)
