class_name PlatformPage
extends Page

@export var bounties : Array[Bounty]

const PAGE_TEMPLATE := """ 
[center][rainbow][font_size=28][b]* b u g - b o u n t y z *[/b][/font_size][/rainbow][/center]
[center][i]the premier vulnerability disclosure platform on the world wide web[/i][/center]

[color=gray]========================================================[/color]

[center][color=yellow]level: %d[/color][/center]
[center][color=lime]bounties paid: $%d[/color][/center]
[center][url=/shop.html][color=yellow]>>> shop <<<[/color][/url][/center]

[color=hotpink][font_size=18]>> available programs[/font_size][/color]

%s

[color=gray]========================================================[/color]
[center][color=gray][i]updated 11/14/2001 | best viewed in netscape navigator 4[/i][/color][/center]

"""

const ENTRY_TEMPLATE := """[b]%s[/b] [color=yellow](level %d)[/color]
payout: $%d-$%d | difficulty: %s
detection: %d%%
[i]%s[/i]
[url=%s][color=cyan]>>> go to engagement <<<[/color][/url] [url=%s][color=red]>>> report finding <<<[/color][/url]"""

const BURNED_TEMPLATE := """[b]%s[/b] [color=red][BURNED][/color]
[i]engagement closed by detection. no further submissions.[/i]"""

func get_content() -> String:
	if bounties.is_empty():
		return PAGE_TEMPLATE % [Engagement.level, Engagement.money, "[i]no programs available.[/i]"]

	var entries : Array[String] = []
	for b in bounties:
		if b.required_level > Engagement.level:
			continue
		if Engagement.is_burned(b.id):
			entries.append(BURNED_TEMPLATE % b.program_name)
			continue
		var stars := "*".repeat(b.difficulty) + "-".repeat(5 - b.difficulty)
		entries.append(ENTRY_TEMPLATE % [
			b.program_name,
			b.required_level,
			b.payout_min,
			b.payout_max,
			stars,
			Engagement.get_detection(b.id),
			b.scope,
			Url.to_url(b.target_page),
			"action://report/" + b.id,
		])
	return PAGE_TEMPLATE % [Engagement.level, Engagement.money, "\n\n".join(entries)]
