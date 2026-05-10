class_name Page
extends Resource

@export_multiline var content: String
@export var background_img : Texture2D
@export var background_colour : Color = Color.WHITE
@export var music : AudioStream
func get_content() -> String:
	return content
