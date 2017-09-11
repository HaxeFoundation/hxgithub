package github.api;

import haxe.io.Bytes;

typedef CreateReleaseOptions = {
	?tag_name:String,
	?target_commitish:String,
	?name:String,
	?body:String,
	?draft:Bool,
	?prelease:Bool
}

abstract ReleaseApi(Api) {
	public inline function new(api:Api) {
		this = api;
	}

	public function create(options:CreateReleaseOptions):Release {
		return this.post('releases', options);
	}

	public function byId(id:Int):Release {
		return this.get('releases/$id');
	}

	public function byTag(tag:String):Release {
		return this.get('releases/tags/$tag');
	}

	public function edit(release:Release, options:CreateReleaseOptions):Release {
		return this.patch('releases/${release.id}', options);
	}

	public function latest():Release {
		return this.get('releases/latest');
	}

	public function list():Array<Release> {
		return this.get('releases');
	}

	public function uploadAsset(release:Release, name:String, ?label:String, data:Bytes) {
		var file = new haxe.io.Path(name);
		this.connection.postDirect(new UriTpl(release.upload_url).render({name: name, label:label}), data.toString(), [{name: "Content-Type", value: github.helper.MediaTypesMap.map[file.ext]}]);
	}
}