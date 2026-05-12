extends Node

# if we don't reference the resources somewhere they don't get included in
# the release build
const ALL : Array[Bounty] = [
	preload("res://resources/bounties/bug_bountyz_onboarding.tres"),
	preload("res://resources/bounties/nans_bounty.tres"),
	preload("res://resources/bounties/y2k_bounty.tres"),
	preload("res://resources/bounties/pyrapals_bounty.tres"),
]

var _by_id : Dictionary = {}

func _ready() -> void:
	for b in ALL:
		_by_id[b.id] = b

func get_all() -> Array[Bounty]:
	return ALL

func get_by_id(id: String) -> Bounty:
	return _by_id.get(id)

func find_by_site(domain: String) -> Bounty:
	for b in ALL:
		if b.target_page == null:
			continue
		if Url.site_of(Url.to_url(b.target_page)) == domain:
			return b
	return null

func find_by_page(page: Page) -> Bounty:
	if page == null:
		return null
	for b in ALL:
		if b.target_page == null:
			continue
		if not b.engagement_pages.is_empty():
			if b.engagement_pages.has(page):
				return b
			continue
		if Url.site_of(Url.to_url(b.target_page)) == Url.site_of(Url.to_url(page)):
			return b
	return null
