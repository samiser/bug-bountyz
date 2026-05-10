extends Node

const BOUNTIES_DIR := "res://resources/bounties/"

var _all : Array[Bounty] = []
var _by_id : Dictionary = {}

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir := DirAccess.open(BOUNTIES_DIR)
	if dir == null:
		return
	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var bounty = load(BOUNTIES_DIR + file_name)
		if bounty is Bounty:
			_all.append(bounty)
			_by_id[bounty.id] = bounty

func get_all() -> Array[Bounty]:
	return _all

func get_by_id(id: String) -> Bounty:
	return _by_id.get(id)
