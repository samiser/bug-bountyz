extends Control

@export var window: Window
@export var icon: Texture2D

@onready var icon_rect: TextureRect = $VBoxContainer/IconRect
@onready var name_label: RichTextLabel = $VBoxContainer/NameLabel

func _ready() -> void:
	name_label.text = "[i]%s[/i]" % window.name
	icon_rect.texture = icon

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Sound.play_click()
		window.show()
