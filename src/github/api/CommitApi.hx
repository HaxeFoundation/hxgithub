package github.api;

typedef CommitOptions = {
	?sha: String,
	?path: String,
	?author: String,
	?since: String,
	?until: String
}

abstract CommitApi(Api) {
	public inline function new(api:Api) {
		this = api;
	}

	public function list(options:CommitOptions) {
		return this.get('commits');
	}
}