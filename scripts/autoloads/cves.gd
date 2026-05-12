extends Node

const ALL : Array[CVE] = [
	preload("res://resources/cves/apache-1.3.27.tres"),
	preload("res://resources/cves/apache-2.0.40.tres"),
	preload("res://resources/cves/openssh-1.2.x.tres"),
]

var _by_id : Dictionary = {}

func _ready() -> void:
	for cve in ALL:
		_by_id[cve.id] = cve

func get_all() -> Array[CVE]:
	return ALL

func get_by_id(id: String) -> CVE:
	return _by_id.get(id)
