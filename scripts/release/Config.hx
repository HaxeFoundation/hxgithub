@:enum abstract Target(String) to String {
	var Linux64 = "linux64";
	var MacInstaller = "mac-installer";
	var Mac = "mac";
	var Windows32Installer = "windows-installer";
	var Windows32 = "windows";
	var Windows64Installer = "windows64-installer";
	var Windows64 = "windows64";

	@:from static function fromString(s:String) {
		return switch (s) {
			case "linux64": Linux64;
			case "mac-installer": MacInstaller;
			case "mac": Mac;
			case "windows-installer": Windows32Installer;
			case "windows": Windows32;
			case "windows64-installer": Windows64Installer;
			case "windows64": Windows64;
			case _: throw "Unknown target";
		}
	}
}

class Config {
	public var buildServerUrl:String;
	public var fileName:String;
	public var targets:Array<Target>;
	public var haxeVersion:String;
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
		targets = [Linux64, MacInstaller, Mac, Windows32Installer, Windows32, Windows64Installer, Windows64];
		dry = false;
	}

	public function getFileName(target:Target) {
		return switch (target) {
			case Linux64: "linux64";
			case MacInstaller: "osx-installer";
			case Mac: "osx";
			case Windows32Installer: "win";
			case Windows32: "win";
			case Windows64Installer: "win64";
			case Windows64: "win64";
		}
	}

	public function getFileExtension(target:Target) {
		return switch (target) {
			case Linux64: "tar.gz";
			case MacInstaller: "pkg";
			case Mac: "tar.gz";
			case Windows32Installer | Windows64Installer: "exe";
			case Windows32 | Windows64: "zip";
		}
	}
}