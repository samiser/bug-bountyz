extends Node

const ALL : Array[Site] = [
	preload("res://resources/sites/nansrecipes.com/site.tres"),
	preload("res://resources/sites/y2k-crawler.com/site.tres"),
]

var _by_domain : Dictionary = {}

func _ready() -> void:
	for s in ALL:
		_by_domain[s.domain] = s

func get_by_domain(domain: String) -> Site:
	return _by_domain.get(domain)
