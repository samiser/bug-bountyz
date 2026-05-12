extends Control

@onready var browser: Button = $HBoxContainer/Browser
@onready var toolbox: Button = $HBoxContainer/Toolbox
@onready var wiki: Button = $HBoxContainer/Wiki

@onready var money_label: Label = $HBoxContainer/MoneyLabel
@onready var engagement_label: Label = $HBoxContainer/EngagementLabel
@onready var detection_label: Label = $HBoxContainer/DetectionLabel

func _ready() -> void:
	_setup_button(browser)
	_setup_button(toolbox)
	_setup_button(wiki)

	Engagement.money_changed.connect(_on_money_changed)
	Engagement.detection_changed.connect(_on_detection_changed)
	Engagement.active_bounty_changed.connect(_on_active_bounty_changed)

	money_label.text = "money: $%d" % Engagement.money
	_refresh_engagement_labels(Engagement.active_bounty)

func _setup_button(button: Button) -> void:
	var window : Window = get_parent().get_node(NodePath(button.name))
	button.visible = false
	button.pressed.connect(_toggle_window.bind(window))
	window.visibility_changed.connect(_show_button.bind(button, window))

func _show_button(button: Button, window: Window) -> void:
	if window.visible:
		button.visible = true

func _toggle_window(window: Window) -> void:
	window.show()
	window.move_to_foreground()

func _on_money_changed(new_value: int) -> void:
	money_label.text = "money: $%d" % new_value

func _on_active_bounty_changed(bounty: Bounty) -> void:
	_refresh_engagement_labels(bounty)

func _on_detection_changed(bounty_id: String, new_value: int) -> void:
	if Engagement.active_bounty != null and Engagement.active_bounty.id == bounty_id:
		detection_label.text = "detection: %d%%" % new_value

func _refresh_engagement_labels(bounty: Bounty) -> void:
	if bounty == null:
		engagement_label.text = "current engagement: none"
		detection_label.text = "detection: 0%"
	else:
		engagement_label.text = "current engagement: %s" % bounty.program_name
		detection_label.text = "detection: %d%%" % Engagement.get_detection(bounty.id)
