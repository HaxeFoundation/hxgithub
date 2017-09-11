package github.api;

abstract ReferenceApi(Api) {
	public inline function new(api:Api) {
		this = api;
	}

	public function create(ref:String, sha:String) {
		return this.post('git/refs', { ref: ref, sha: sha });
	}

	public function delete(ref:String) {
		return this.delete('git/refs/$ref');
	}

	public function get(ref:String) {
		return this.get('git/refs/$ref');
	}

	public function getAll() {
		return this.get('git/refs');
	}

	public function update(ref:String, sha:String, ?force:Bool = false) {
		return this.patch('git/refs/$ref', { sha: sha, force: force });
	}
}