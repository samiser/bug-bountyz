extends Control

@export var valid_username : String
@export var valid_password : String
@export var success_url : String

@onready var username_input: LineEdit = $VBoxContainer/UsernameRow/UsernameInput
@onready var password_input: LineEdit = $VBoxContainer/PasswordRow/PasswordInput
@onready var submit_button: Button = $VBoxContainer/SubmitButton
@onready var status_label: RichTextLabel = $VBoxContainer/StatusLabel

func _ready() -> void:
	password_input.secret = true
	submit_button.pressed.connect(_on_submit)
	username_input.text_submitted.connect(func(_t): _on_submit())
	password_input.text_submitted.connect(func(_t): _on_submit())
	status_label.text = ""

func _on_submit() -> void:
	if username_input.text == valid_username and password_input.text == valid_password:
		status_label.text = "[color=lime]access granted...[/color]"
		Sound.play_click()
		Engagement.action_invoked.emit("navigate", [success_url])
	else:
		status_label.text = "[color=red]invalid username or password[/color]"
		Sound.play_error()
