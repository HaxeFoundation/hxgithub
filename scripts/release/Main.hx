import Sys.*;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import github.*;
import github.api.*;
import SysHelper.*;

class Main {

	var config:Config;
	var api:Api;

	function new() {
		config = CommandLineParser.parseCommandLine();
		api = createGitHubApi();
		var releaseNotes = getReleaseNotes();
		var release = getRelease();
		if (config.download || config.updateRelease) {
			createDownloadDirectory();
		}
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
			if (config.dry) {
				var changelogName = "./" + config.haxeVersion + "/CHANGES.md";
				println("saving changelog to " + changelogName + " because this is a dry run");
				File.saveContent(changelogName, changelogMd);
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

	function createDownloadDirectory() {
		var directory = "./" + config.haxeVersion;
		if (!FileSystem.exists(directory)) {
			FileSystem.createDirectory(directory);
			println("Created output directory " + directory);
		} else {
			println("Found output directory " + directory);
		}
	}

	function getReleaseNotes() {
		var path = "./" + config.haxeVersion + "/RELEASE.md";
		if (!FileSystem.exists(path)) {
			if (config.updateWebsite) {
				if (config.dry) {
					createDownloadDirectory();
					File.saveContent(path, "");
					println("File " + path + " not found (created it because this is a dry run)");
				}
				else {
					stderr("File " + path + " not found (required for website update)");
					exit(1);
				}
			}
			return null;
		}
		return File.getContent(path);
	}

	function download() {
		new BinaryDownloader(config).run();
	}

	function uploadAsset(release:Release, file:String) {
		var path = new haxe.io.Path(file);
		var bytes = sys.io.File.getBytes(file);
		print("Uploading " + file + " to GitHub release " + release.tag_name + "...");
		if (!config.dry) {
			api.releases.uploadAsset(release, path.file + "." + path.ext, bytes);
		}
		println(" done");
	}

	function upload(release:Release) {
		var directory = "./" + config.haxeVersion;
		if (!sys.FileSystem.exists(directory)) {
			stderr("Output directory " + directory + " does not exists, cannot upload");
			exit(1);
		}

		var fileNameBase = "haxe-" + config.haxeVersion + "-";
		for (target in config.targets) {
			var fileName = fileNameBase + config.getFileName(target) + "." + config.getFileExtension(target);
			var path = Path.join([directory, fileName]);
			if (!sys.FileSystem.exists(path)) {
				stderr("Could not find file " + path);
				exit(1);
			}
			uploadAsset(release, path);
		}
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
		if (!config.dry) {
			api.releases.edit(release, {
				name: config.haxeVersion,
				body: changelogMd
			});
		}
		println(" done");
	}

	function updateHaxeOrg(changelogMd:String, releaseNotes:String) {
		function update(name:String, content:String) {
			var path = "downloads/" + config.haxeVersion + "/" + name;
			try {
				var file = api.content.getFile(path);
				print("Updating " + path + " in repository...");
				if (!config.dry) {
					api.content.updateFile(file, content, "release " + config.haxeVersion, "staging");
				}
				println(" done");
			} catch(e:Dynamic) {
				print("Creating " + path + " in repository...");
				if (!config.dry) {
					api.content.createFile(path, content, "release " + config.haxeVersion, "staging");
				}
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