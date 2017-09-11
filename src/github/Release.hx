package github;

typedef Release = {
	url: String,
	html_url: String,
	assets_url: String,
	upload_url: String,
	tarball_url: String,
	zipball_url: String,
	id: Int,
	tag_name: String,
	target_commitish: String,
	name: String,
	body: String,
	draft: Bool,
	prelease: Bool,
	created_at: String,
	published_at: String,
	author: User,
	assets: Array<Asset>
}