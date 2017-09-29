using StringTools;

import Sys.*;
import SysHelper.*;

class CommandLineParser {
	static public function parseCommandLine() {
		var config = new Config();

		var argParser = hxargs.Args.generate([
			@doc("The GitHub auth token")
			["-t", "--token"] => function(token:String) {
				config.accessToken = token;
			},
			@doc("Comma separated list of what targets to handle: linux64 mac-installer mac windows-installer windows")
			["-ts", "--targets"] => function(s:String) {
				var targets = s.split(",");
				for (target in targets) {
					if (!config.targetFileNameMap.exists(target)) {
						stderr('Unknown target: $target');
						exit(1);
					}
				}
				config.targets = targets;
			},
			@doc("The base server URL to fetch builds from")
			["-s", "--server-url"] => function(url:String) {
				config.buildServerUrl = haxe.io.Path.addTrailingSlash(url);
			},
			@doc("Which Haxe version to generate, e.g. 3.1.0")
			["-h", "--haxe-version"] => function(version:String) {
				config.haxeVersion = version;
			},
			@doc("The file name to fetch")
			["-f", "--filename"] => function(fileName:String) {
				config.fileName = fileName;
			},
			@doc("Comma separated list of changelog versions")
			["-c", "--changelog"] => function(versions:String) {
				var versions = versions.split(",");
				for (version in versions) {
					config.changelogVersions.push(version.trim());
				}
			},
			@doc("Download binaries from build server")
			["-d", "--download"] => function() {
				config.download = true;
			},
			@doc("Upload binaries to GitHub release")
			["-u", "--upload"] => function() {
				config.upload = true;
			},
			@doc("Update GitHub release changelog")
			["-ur", "--update-release"] => function() {
				config.updateRelease = true;
			},
			@doc("Push release information to haxe.org")
			["-uw", "--update-website"] => function() {
				config.updateWebsite = true;
			},
			@doc("Generate API documentation")
			["-doc", "--documentation"] => function() {
				config.generateApiDocs = true;
			},
			@doc("Don't change anything")
			["--dry"] => function() {
				config.dry = true;
			}
		]);

		argParser.parse(args());

		if (config.accessToken == null) {
			stderr("Required argument --token is missing");
			stderr(argParser.getDoc());
			exit(1);
		} else if (config.haxeVersion == null) {
			stderr("Required argument --haxe-version is missing");
			stderr(argParser.getDoc());
			exit(1);
		}
		if (config.download && config.fileName == null) {
			stderr("Required argument --filename is missing");
			stderr(argParser.getDoc());
			exit(1);
		}

		if (config.changelogVersions.length == 0) {
			config.changelogVersions.push(config.haxeVersion);
		}

		return config;
	}
}