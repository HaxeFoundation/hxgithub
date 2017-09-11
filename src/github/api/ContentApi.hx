package github.api;

typedef FileCreationOptions = {
	message: String,
	content: String,
	?branch: String,
	?name: String,
	?email: String
}

typedef FileUpdateOptions = {
	> FileCreationOptions,
	sha: String,
}

abstract ContentApi(Api) {
	public inline function new(api:Api) {
		this = api;
	}

	public function createFile(path:String, content:String, commitMessage:String, ?branch:String) {
		var data:FileCreationOptions = { message: commitMessage, content: haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(content)) };
		if (branch != null) {
			data.branch = branch;
		}
		return this.put('contents/$path', data);
	}

	public function getDirectory(path:String):Array<File> {
		return this.get('contents/$path');
	}

	public function getFile(path:String):File {
		return this.get('contents/$path');
	}

	public function updateFile(file:File, content:String, commitMessage:String, ?branch:String){
		var content = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(content));
		var data:FileUpdateOptions = { content: content, message: commitMessage, sha: file.sha };
		if (branch != null) {
			data.branch = branch;
		}
		return this.put('contents/${file.path}', data);
	}
}