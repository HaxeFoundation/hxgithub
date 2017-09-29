class Config {
	public var buildServerUrl:String;
	public var fileName:String;
	public var targets:Array<String>;
	public var haxeVersion:String;
	public var targetFileNameMap:Map<String, String>;
	public var targetFileExtensionMap:Map<String, String>;
	public var changelogVersions:Array<String>;
	public var accessToken:String;
	public var download:Bool;
	public var upload:Bool;
	public var updateRelease:Bool;
	public var updateWebsite:Bool;
	public var generateApiDocs:Bool;
	public var dry:Bool;

	public function new() {
		changelogVersions = [];
		download = false;
		upload = false;
		updateRelease = false;
		updateWebsite = false;
		generateApiDocs = false;
		buildServerUrl = "http://hxbuilds.s3-website-us-east-1.amazonaws.com/builds/haxe/";
		targets = ["linux64", "mac-installer", "mac", "windows-installer", "windows"];
		targetFileNameMap = [
			"linux64" => "linux64",
			"mac-installer" => "osx-installer",
			"mac" => "osx",
			"windows-installer" => "win",
			"windows" => "win"
		];
		targetFileExtensionMap = [
			"linux64" => "tar.gz",
			"mac-installer" => "pkg",
			"mac" => "tar.gz",
			"windows-installer" => "exe",
			"windows" => "zip"
		];
		dry = false;
	}
}