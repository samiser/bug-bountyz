extends HSplitContainer

@export var list : ItemList
@export var detail : RichTextLabel
@export_enum("vulns", "tools") var source : String = "vulns"

func _ready() -> void:
	list.item_selected.connect(_on_selected)
	_populate()

func _populate() -> void:
	list.clear()
	for entry in _ordering():
		if _data().has(entry):
			list.add_item(entry)
	if list.item_count == 0:
		detail.text = "[i]no entries.[/i]"
	else:
		detail.text = "[i]select an entry.[/i]"

func _on_selected(idx: int) -> void:
	var entry : String = list.get_item_text(idx)
	detail.text = _data()[entry]

func _data() -> Dictionary:
	match source:
		"vulns": return Vulns.HELP
		"tools": return Tools.HELP
	return {}

func _ordering() -> Array:
	match source:
		"vulns": return Vulns.ALL
		"tools": return Tools.HELP.keys()
	return []
