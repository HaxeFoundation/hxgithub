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
			@doc("Comma separated list of GitHub users to handle")
			["-u", "--users"] => function(s:String) {
				var users = s.split(",");
				for (user in users) {
					config.users.push(user);
				}
			},
			@doc("The GitHub repository to explore")
			["-r", "--repository"] => function(owner:String, name:String) {
				config.repoOwner = owner;
				config.repoName = name;
			},
			@doc("The number of issues to select")
			["-n", "--number"] => function(number:Int) {
				config.numberOfSelections = number;
			},
		]);

		argParser.parse(args());

		if (config.accessToken == null) {
			stderr("Required argument --token is missing");
			stderr(argParser.getDoc());
			exit(1);
		}
		if (config.users.length == 0) {
			stderr("Required argument --users is missing");
			stderr(argParser.getDoc());
			exit(1);
		}
		if (config.repoOwner == null) {
			stderr("Required argument --repository is missing");
			stderr(argParser.getDoc());
			exit(1);
		}

		return config;
	}
}