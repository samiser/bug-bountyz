class_name ShopPage
extends Page

const PAGE_TEMPLATE := """
[center][rainbow][font_size=24][b]* s h o p *[/b][/font_size][/rainbow][/center]
[center][i]spend your money, hack more stuff[/i][/center]

[color=gray]========================================================[/color]

[center][color=lime]your money: $%d[/color][/center]

[color=hotpink][font_size=16]>> available tools[/font_size][/color]

%s

[color=gray]========================================================[/color]"""

const ENTRY_OWNED := """[b]%s[/b] [color=gray][OWNED][/color]
[i]%s[/i]"""

const ENTRY_BUY := """[b]%s[/b] - $%d
[i]%s[/i]
[url=action://buy/%s][color=cyan]>>> buy <<<[/color][/url]"""

const ENTRY_LOCKED := """[b]%s[/b] - $%d
[i]%s[/i]
[color=gray]>>> can't afford <<<[/color]"""

func get_content() -> String:
	var entries : Array[String] = []
	for tool_id in Tools.ALL.keys():
		var info : Dictionary = Tools.ALL[tool_id]
		if Engagement.is_tool_unlocked(tool_id):
			entries.append(ENTRY_OWNED % [info.name, info.description])
		elif Engagement.money >= info.price:
			entries.append(ENTRY_BUY % [info.name, info.price, info.description, tool_id])
		else:
			entries.append(ENTRY_LOCKED % [info.name, info.price, info.description])
	if entries.is_empty():
		return PAGE_TEMPLATE % [Engagement.money, "[i]no tools available.[/i]"]
	return PAGE_TEMPLATE % [Engagement.money, "\n\n".join(entries)]
