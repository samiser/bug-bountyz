extends HSplitContainer

@export var list : ItemList
@export var detail : RichTextLabel

func _ready() -> void:
	Engagement.capture_added.connect(_on_capture_added)
	list.item_selected.connect(_on_selected)
	_refresh()

func _refresh() -> void:
	list.clear()
	for capture in Engagement.captures:
		list.add_item("[%s] %s" % [capture.source_tool, ", ".join(capture.tags)])
	if Engagement.captures.is_empty():
		detail.text = "[i]no captures yet. use a tool's 'capture output' button.[/i]"

func _on_capture_added(_capture: Dictionary) -> void:
	_refresh()

func _on_selected(idx: int) -> void:
	var capture : Dictionary = Engagement.captures[idx]
	detail.text = "[b]source:[/b] %s\n[b]tags:[/b] %s\n\n%s" % [
		capture.source_tool,
		", ".join(capture.tags),
		capture.content,
	]
