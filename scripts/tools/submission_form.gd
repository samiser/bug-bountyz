extends VBoxContainer

@export var bounty_dropdown : OptionButton
@export var class_dropdown : OptionButton
@export var specifics_dropdown : OptionButton
@export var poc_list : ItemList
@export var submit_button : Button
@export var form_view : Control
@export var outcome_view : Control
@export var outcome_label : RichTextLabel
@export var close_button : Button

func _ready() -> void:
	bounty_dropdown.item_selected.connect(_on_bounty_selected)
	class_dropdown.item_selected.connect(_on_class_selected)
	specifics_dropdown.item_selected.connect(_on_specifics_selected)
	poc_list.multi_selected.connect(_on_poc_changed)
	submit_button.pressed.connect(_on_submit)
	close_button.pressed.connect(get_parent().hide)
	Engagement.capture_added.connect(_on_capture_added)
	Engagement.action_invoked.connect(_on_action)
	poc_list.select_mode = ItemList.SELECT_MULTI
	_show_form()

func _on_action(name: String, args: Array) -> void:
	if name != "report":
		return
	_show_form()
	if args.size() > 0:
		_select_bounty_by_id(args[0])
	var window := get_parent() as Window
	if window != null:
		window.show()
		window.move_to_foreground()

func _select_bounty_by_id(bounty_id: String) -> void:
	var bounties := Bounties.get_all()
	for i in bounties.size():
		if bounties[i].id == bounty_id:
			bounty_dropdown.selected = i + 1
			_on_bounty_selected(i + 1)
			return

func _show_form() -> void:
	form_view.visible = true
	outcome_view.visible = false
	_refresh_bounties()
	_refresh_classes()
	_refresh_specifics()
	_refresh_poc()
	_refresh_submit_state()

func _refresh_bounties() -> void:
	bounty_dropdown.clear()
	bounty_dropdown.add_item("(select bounty)")
	bounty_dropdown.set_item_disabled(0, true)
	for b in Bounties.get_all():
		bounty_dropdown.add_item(b.program_name)
	bounty_dropdown.selected = 0

func _refresh_classes() -> void:
	class_dropdown.clear()
	class_dropdown.add_item("(select class)")
	class_dropdown.set_item_disabled(0, true)
	for v in Vulns.ALL:
		class_dropdown.add_item(v)
	class_dropdown.selected = 0
	class_dropdown.disabled = bounty_dropdown.selected <= 0

func _refresh_specifics() -> void:
	specifics_dropdown.clear()
	specifics_dropdown.add_item("(select specifics)")
	specifics_dropdown.set_item_disabled(0, true)
	if class_dropdown.selected > 0:
		var picked_class : String = class_dropdown.get_item_text(class_dropdown.selected)
		for cve in Cves.get_all():
			if cve.vuln_class == picked_class:
				specifics_dropdown.add_item(cve.id)
		if Vulns.SPECIFICS_BY_CLASS.has(picked_class):
			for spec in Vulns.SPECIFICS_BY_CLASS[picked_class]:
				specifics_dropdown.add_item(spec)
	specifics_dropdown.selected = 0
	specifics_dropdown.disabled = class_dropdown.selected <= 0

func _refresh_poc() -> void:
	poc_list.clear()
	for capture in Engagement.captures:
		poc_list.add_item("[%s] %s" % [capture.source_tool, ", ".join(capture.tags)])

func _refresh_submit_state() -> void:
	submit_button.disabled = not _is_form_complete()

func _is_form_complete() -> bool:
	return (
		bounty_dropdown.selected > 0
		and class_dropdown.selected > 0
		and specifics_dropdown.selected > 0
		and poc_list.get_selected_items().size() > 0
	)

func _on_bounty_selected(_idx: int) -> void:
	_refresh_classes()
	_refresh_specifics()
	_refresh_submit_state()

func _on_class_selected(_idx: int) -> void:
	_refresh_specifics()
	_refresh_submit_state()

func _on_specifics_selected(_idx: int) -> void:
	_refresh_submit_state()

func _on_poc_changed(_index: int, _selected: bool) -> void:
	_refresh_submit_state()

func _on_capture_added(_capture: Dictionary) -> void:
	if form_view.visible:
		_refresh_poc()
		_refresh_submit_state()

func _on_submit() -> void:
	var bounty : Bounty = Bounties.get_all()[bounty_dropdown.selected - 1]
	var poc_captures : Array = []
	for i in poc_list.get_selected_items():
		poc_captures.append(Engagement.captures[i])

	var submission := {
		"bounty": bounty,
		"vuln_class": class_dropdown.get_item_text(class_dropdown.selected),
		"specifics": specifics_dropdown.get_item_text(specifics_dropdown.selected),
		"poc_captures": poc_captures,
	}
	var result := _grade(submission)
	_show_outcome(result)
	if result.accepted:
		Sound.play_click()
	else:
		Sound.play_error()

func _grade(submission: Dictionary) -> Dictionary:
	var bounty : Bounty = submission.bounty
	for i in bounty.findings.size():
		var f : Finding = bounty.findings[i]
		var key := "%s::%d" % [bounty.id, i]
		if Engagement.is_finding_claimed(key):
			continue
		if f.vuln_class != submission.vuln_class:
			continue
		if f.specifics != submission.specifics:
			continue
		if not _poc_matches(f.required_poc, submission.poc_captures):
			continue
		Engagement.claim_finding(key)
		Engagement.add_money(f.payout)
		return {"accepted": true, "finding": f}
	return {"accepted": false, "finding": null}

func _poc_matches(required: Array[String], poc_captures: Array) -> bool:
	if required.is_empty():
		return true
	for capture in poc_captures:
		var all_present := true
		for tag in required:
			if not capture.tags.has(tag):
				all_present = false
				break
		if all_present:
			return true
	return false

func _show_outcome(result: Dictionary) -> void:
	form_view.visible = false
	outcome_view.visible = true
	if result.accepted:
		var f : Finding = result.finding
		outcome_label.text = "[b]ACCEPTED[/b]\nseverity: %s\npayout: $%d\n\n[i]thanks for the report. payment processed.[/i]" % [f.severity, f.payout]
	else:
		outcome_label.text = "[b]REJECTED[/b]\n\n[i]this submission did not match a known finding.[/i]"
