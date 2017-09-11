package github;

typedef Asset = {
	url: String,
	browser_download_url: String,
	id: Int,
	name: String,
	label: String,
	state: String,
	content_type: String,
	size: Int,
	download_count: Int,
	created_at: String,
	updated_at: String,
	uploader: User
}