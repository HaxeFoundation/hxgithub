import Sys.*;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import github.*;
import github.api.*;
import SysHelper.*;

using StringTools;

class Main {

	var config:Config;
	var api:Api;

	function new() {
		config = CommandLineParser.parseCommandLine();
		api = createGitHubApi();
		var releaseNotes = getReleaseNotes();
		var release = getRelease();
		if (config.download) {
			download();
		}
		if (config.upload) {
			upload(release);
		}
		if (config.updateRelease || config.updateWebsite) {
			var changelogMd = parseChangelog();
			if (config.updateRelease) {
				updateRelease(release, changelogMd);
			}
			if (config.updateWebsite) {
				updateHaxeOrg(changelogMd, releaseNotes);
			}
		}
		if (config.generateApiDocs) {
			var output = DocumentationGenerator.run(config);
			api.enterRepository("HaxeFoundation", "haxe");
			uploadAsset(release, output);
		}

		println("All tasks finished");
		exit(0);
	}

	function getRelease() {
		print("Fetching GitHub release " + config.haxeVersion + "...");
		var release = try {
			api.releases.byTag(config.haxeVersion);
		} catch(e:Dynamic) {
			stderr("Could not find GitHub release " + config.haxeVersion + ", please create it");
			exit(1);
			null;
		}
		println(" done");
		return release;
	}

	function getReleaseNotes() {
		var path = "./" + config.haxeVersion + "/RELEASE.md";
		if (!FileSystem.exists(path)) {
			if (config.updateWebsite) {
				stderr("File " + path + " not found (required for website update)");
				exit(1);
			}
			return null;
		}
		return File.getContent(path);
	}

	function download() {
		var directory = "./" + config.haxeVersion;
		if (!FileSystem.exists(directory)) {
			FileSystem.createDirectory(directory);
			println("Created output directory " + directory);
		} else {
			println("Found output directory " + directory);
		}
		new BinaryDownloader(config).run();
	}

	function uploadAsset(release:Release, file:String) {
		var path = new haxe.io.Path(file);
		var bytes = sys.io.File.getBytes(file);
		print("Uploading " + file + " to GitHub release " + release.tag_name + "...");
		api.releases.uploadAsset(release, path.file + "." + path.ext, bytes);
		println(" done");
	}

	function upload(release:Release) {
		var directory = "./" + config.haxeVersion;
		if (!sys.FileSystem.exists(directory)) {
			stderr("Output directory " + directory + " does not exists, cannot upload");
			exit(1);
		}

		for (file in sys.FileSystem.readDirectory(directory)) {
			if (!file.startsWith("haxe-" + config.haxeVersion)) {
				continue;
			}
			var path = Path.join([directory, file]);
			uploadAsset(release, path);
		};
	}

	function parseChangelog() {
		var changesTxt = haxe.Http.requestUrl("https://raw.githubusercontent.com/HaxeFoundation/haxe/development/extra/CHANGES.txt");
		print("Parsing changelog...");
		var changelogMd = ChangelogParser.parse(config, changesTxt);
		println(" done");
		return changelogMd;
	}

	function updateRelease(release:Release, changelogMd:String) {
		print("Updating GitHub release...");
		api.releases.edit(release, {
			name: config.haxeVersion,
			body: changelogMd
		});
		println(" done");
	}

	function updateHaxeOrg(changelogMd:String, releaseNotes:String) {
		function update(name:String, content:String) {
			var path = "downloads/" + config.haxeVersion + "/" + name;
			try {
				var file = api.content.getFile(path);
				print("Updating " + path + " in repository...");
				api.content.updateFile(file, content, "release " + config.haxeVersion, "staging");
				println(" done");
			} catch(e:Dynamic) {
				print("Creating " + path + " in repository...");
				api.content.createFile(path, content, "release " + config.haxeVersion, "staging");
				println(" done");
			}
		}
		api.enterRepository("HaxeFoundation", "haxe.org");
		update("CHANGES.md", changelogMd);
		update("RELEASE.md", releaseNotes);
	}

	function createGitHubApi() {
		print("Opening GitHub API connection...");
		var request = new github.api.ApiConnection("https://api.github.com", config.accessToken);
		var api = new Api(request);
		api.enterRepository("HaxeFoundation", "haxe");
		println("done");
		return api;
	}

	static public function main() {
		new Main();
	}
}