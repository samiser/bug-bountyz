extends Button

func _ready() -> void:
	pressed.connect(_unlock_everything)

func _unlock_everything() -> void:
	Engagement.add_money(99999)
	for tool in Tools.ALL:
		Engagement.unlock_tool(tool)
