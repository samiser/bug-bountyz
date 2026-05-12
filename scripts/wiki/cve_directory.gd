extends HSplitContainer

@export var list : ItemList
@export var detail : RichTextLabel

func _ready() -> void:
	list.item_selected.connect(_on_selected)
	_refresh()

func _refresh() -> void:
	list.clear()
	for cve in Cves.get_all():
		list.add_item(cve.id)
	if Cves.get_all().is_empty():
		detail.text = "[i]no entries.[/i]"
	else:
		detail.text = "[i]select an entry.[/i]"

func _on_selected(idx: int) -> void:
	var cve : CVE = Cves.get_all()[idx]
	detail.text = _format(cve)

func _format(cve: CVE) -> String:
	return "[b]%s[/b]\n[b]class:[/b] %s\n[b]severity:[/b] %s\n[b]affects:[/b] %s\n\n%s" % [
		cve.id, cve.vuln_class, cve.severity, cve.affected_fingerprint, cve.description,
	]
