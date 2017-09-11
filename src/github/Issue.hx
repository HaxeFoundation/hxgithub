package github;

typedef Issue = {
	url: String,
	html_url: String,
	number: Int,
	state: String,
	title: String,
	body: String,
	user: User,
	labels: Array<Label>,
	assignee: User,
	milestone: Milestone,
	comments: Int,
	pull_request: { html_url:String, diff_url:String, patch_url:String },
	closed_at: Null<String>,
	created_at: String,
	updated_at: String
}