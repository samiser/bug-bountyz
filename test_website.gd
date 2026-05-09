extends RichTextLabel

@export var homepage : Page

func _ready() -> void:
	_load_page(homepage)

func _load_page(page : Page) -> void:
	print("Loaded page: " + page.path)
	
	text = ""
	append_text(page.content)

func _on_meta_clicked(meta: String) -> void:
	if meta.begins_with("res://pages/"):
		var new_page : Page = load(meta)
		_load_page(new_page)
	else:
		print("WTF IS THIS: " + meta)
