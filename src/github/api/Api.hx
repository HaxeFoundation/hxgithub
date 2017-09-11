package github.api;

import haxe.Json;

class Api {

	public var connection:ApiConnection;
	public var repository(default, null):String;
	public var owner(default, null):String;

	public var commits(default, null):CommitApi;
	public var content(default, null):ContentApi;
	public var issues(default, null):IssueApi;
	public var references(default, null):ReferenceApi;
	public var releases(default, null):ReleaseApi;

	public function new(connection:ApiConnection) {
		this.connection = connection;
		commits = new CommitApi(this);
		issues = new IssueApi(this);
		content = new ContentApi(this);
		releases = new ReleaseApi(this);
		references = new ReferenceApi(this);
	}

	public function enterRepository(owner:String, repository:String) {
		this.owner = owner;
		this.repository = repository;
	}

	public function delete<T>(s:String):T {
		return connection.delete('/repos/${this.owner}/${this.repository}/$s');
	}

	public function get<T>(s:String):T {
		return connection.get('/repos/${this.owner}/${this.repository}/$s');
	}

	public function patch<T>(url:String, data:{}):T {
		return connection.patch('/repos/${this.owner}/${this.repository}/$url', Json.stringify(data));
	}

	public function post<T>(url:String, data:{}):T {
		return connection.post('/repos/${this.owner}/${this.repository}/$url', Json.stringify(data));
	}

	public function put<T>(url:String, data:{}):T {
		return connection.put('/repos/${this.owner}/${this.repository}/$url', Json.stringify(data));
	}
}