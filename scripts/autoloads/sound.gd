extends Node

const SFX_CLICK := preload("res://audio/click.mp3")
const SFX_ERROR := preload("res://audio/error.mp3")

var _player : AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)

func play_click() -> void:
	_player.stream = SFX_CLICK
	_player.play()

func play_error() -> void:
	_player.stream = SFX_ERROR
	_player.play()
