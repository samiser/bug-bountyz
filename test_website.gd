extends RichTextLabel

@export var homepage : Page
@onready var window: Window = $".."

@onready var os_sounds: AudioStreamPlayer2D = $"../../OS-Sounds"
@onready var sfx_click : AudioStreamMP3 = load("res://audio/click.mp3")
@onready var sfx_error : AudioStreamMP3 = load("res://audio/error.mp3")

var history : Array[String]

func _ready() -> void:
	_load_page(homepage)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_back()
@onready var history_label: RichTextLabel = $"../../Window2/HistoryLabel"

func _back() -> void:
	if history.size() <= 1:
		print("Can't go back!")
		os_sounds.stream = sfx_error
	else:
		os_sounds.stream = sfx_click
		
		var last_page_path : String = history.get(history.size() - 2)
		var last_page : Page = load(last_page_path)
		history.remove_at(history.size() - 1)
		_load_page(last_page, false)
	
	os_sounds.play()

func _load_page(page : Page, add_history : bool = true) -> void:
	print("Loaded page: " + page.resource_path)
	
	if add_history: history.append(page.resource_path)
	_display_history()
	
	text = ""
	append_text(page.content)

func _display_history() -> void:
	history_label.text = ""
	print("history size:" + str(history.size()))
	for url in history:
		history_label.append_text(url + "\n")

func _on_meta_clicked(meta: String) -> void:
	if meta.begins_with("res://pages/"):
		var new_page : Page = load(meta)
		_load_page(new_page)
		os_sounds.stream = sfx_click
	else:
		print("WTF IS THIS: " + meta)
		os_sounds.stream = sfx_error
	
	os_sounds.play()
