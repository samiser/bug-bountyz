extends Node

const CVES_DIR := "res://resources/cves/"

var _all : Array[CVE] = []
var _by_id : Dictionary = {}

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir := DirAccess.open(CVES_DIR)
	if dir == null:
		return
	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var cve = load(CVES_DIR + file_name)
		if cve is CVE:
			_all.append(cve)
			_by_id[cve.id] = cve
	_all.sort_custom(func(a, b): return a.id < b.id)

func get_all() -> Array[CVE]:
	return _all

func get_by_id(id: String) -> CVE:
	return _by_id.get(id)
