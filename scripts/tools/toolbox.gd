extends Control

const TOOL_TABS : Dictionary = {
	"Port Scanner": "port_scanner",
	"Directory Fuzzer": "directory_fuzzer",
}

@onready var tab_container : TabContainer = $TabContainer

func _ready() -> void:
	Engagement.tool_unlocked.connect(_on_tool_unlocked)
	_refresh_tabs()

func _refresh_tabs() -> void:
	for i in tab_container.get_tab_count():
		var tab_name := tab_container.get_tab_title(i)
		if TOOL_TABS.has(tab_name):
			var tool_id : String = TOOL_TABS[tab_name]
			tab_container.set_tab_hidden(i, not Engagement.is_tool_unlocked(tool_id))

func _on_tool_unlocked(_id: String) -> void:
	_refresh_tabs()
