class_name PlatformPage
extends Page

@export var bounties : Array[Bounty]

const PAGE_TEMPLATE := """[center][rainbow][font_size=28]★ b u g - b o u n t y z ★[/font_size][/rainbow][/center]
[center][i]the premier vulnerability disclosure platform on the world wide web[/i][/center]

[color=gray]─────────────────────────────────────────────────────────────────────[/color]

[center][color=lime]bounties paid: $%d[/color][/center]

[color=hotpink][font_size=18]>> open programs[/font_size][/color]

%s

[color=gray]─────────────────────────────────────────────────────────────────────[/color]
[center][color=gray][i]last updated 11/14/2001 · best viewed in netscape navigator 4[/i][/color][/center]"""

const ENTRY_TEMPLATE := """[b]%s[/b]
payout: $%d–$%d - difficulty: %s
[i]%s[/i]
[url=%s][color=cyan]>>> go to engagement <<<[/color][/url]"""

func get_content() -> String:
	if bounties.is_empty():
		return PAGE_TEMPLATE % [Engagement.money, "[i]no programs available.[/i]"]

	var entries : Array[String] = []
	for b in bounties:
		var stars := "★".repeat(b.difficulty) + "☆".repeat(5 - b.difficulty)
		entries.append(ENTRY_TEMPLATE % [
			b.program_name,
			b.payout_min,
			b.payout_max,
			stars,
			b.scope,
			Url.to_url(b.target_page),
		])
	return PAGE_TEMPLATE % [Engagement.money, "\n\n".join(entries)]
