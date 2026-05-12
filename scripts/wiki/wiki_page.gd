extends HSplitContainer

@export var list : ItemList
@export var detail : RichTextLabel
@export_enum("vulns", "tools") var source : String = "vulns"

func _ready() -> void:
	list.item_selected.connect(_on_selected)
	_populate()
	if source == "tools":
		Engagement.tool_unlocked.connect(_on_tool_unlocked)

func _on_tool_unlocked(tool_id: String) -> void:
	if not Tools.ALL.has(tool_id):
		return
	var entry_name : String = Tools.ALL[tool_id].name
	for i in list.item_count:
		if list.get_item_text(i) == entry_name:
			list.select(i)
			_on_selected(i)
			return

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
