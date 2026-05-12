extends HSplitContainer

@export var list : ItemList
@export var detail : RichTextLabel

func _ready() -> void:
	list.item_selected.connect(_on_selected)
	_populate()

func _populate() -> void:
	list.clear()
	for vuln_class in Vulns.ALL:
		if Vulns.HELP.has(vuln_class):
			list.add_item(vuln_class)
	if list.item_count == 0:
		detail.text = "[i]no entries.[/i]"
	else:
		detail.text = "[i]select an entry.[/i]"

func _on_selected(idx: int) -> void:
	var entry : String = list.get_item_text(idx)
	detail.text = Vulns.HELP[entry]
