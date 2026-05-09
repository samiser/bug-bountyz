extends Node

const SITES_ROOT := "res://resources/sites/"

# "/x.html" → current_site/x.tres · "d.com/x.html" → d.com/x.tres · "d.com" → d.com/index.tres
func resolve(url: String, current_site: String = "") -> String:
	var domain : String
	var path : String

	if url.begins_with("/"):
		domain = current_site
		path = url.substr(1)
	else:
		var slash := url.find("/")
		if slash == -1:
			domain = url
			path = ""
		else:
			domain = url.substr(0, slash)
			path = url.substr(slash + 1)

	if path.is_empty():
		path = "index.tres"
	elif path.ends_with(".html"):
		path = path.trim_suffix(".html") + ".tres"
	elif not path.ends_with(".tres"):
		path += ".tres"

	return SITES_ROOT + domain + "/" + path

func to_url(page: Page) -> String:
	if page == null:
		return ""
	var p := page.resource_path
	if not p.begins_with(SITES_ROOT):
		return ""
	return p.substr(SITES_ROOT.length()).trim_suffix(".tres") + ".html"

func site_of(url: String) -> String:
	if url.is_empty():
		return ""
	var slash := url.find("/")
	return url.substr(0, slash) if slash != -1 else url

func site_resource_path(domain: String) -> String:
	return SITES_ROOT + domain + "/site.tres"
