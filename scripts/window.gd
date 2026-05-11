extends Window

func _ready() -> void:
	close_requested.connect(_close)

func _close() -> void:
	Sound.play_click()
	hide()
