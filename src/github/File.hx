package github;

typedef File = {
	type: String,
	encoding: String,
	size: Int,
	name: String,
	path: String,
	content: String,
	sha: String,
	url: String,
	git_url: String,
	html_url: String,
	download_url: String,
	_links: {
		git: String,
		self: String,
		html: String
	}
}