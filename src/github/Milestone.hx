package github;

typedef Milestone = {
	url: String,
	number: Int,
	state: String,
	title: String,
	description: String,
	creator: User,
	open_issues: Int,
	closed_issues: Int,
	created_at: String,
	due_on: Null<String>
}