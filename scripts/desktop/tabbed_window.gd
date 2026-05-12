extends TabContainer

@export var action_name : String

func _ready() -> void:
	Engagement.action_invoked.connect(_on_action)

func _on_action(name: String, args: Array) -> void:
	if name != action_name:
		return

	if args.size() > 0:
		var tab_name : String = args[0]
		for i in get_tab_count():
			if get_tab_title(i).to_lower() == tab_name.to_lower():
				current_tab = i
				break

	var window := _find_window()
	if window != null:
		window.show()
		window.move_to_foreground()

func _find_window() -> Window:
	var node : Node = get_parent()
	while node != null:
		if node is Window:
			return node
		node = node.get_parent()
	return null
