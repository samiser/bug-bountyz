class_name Page
extends Resource

@export var path: String
@export_multiline var content: String

func get_content() -> String:
	return content
