import Sys.*;
import github.api.*;

class Main {

	var config:Config;
	var api:Api;

	function new() {
		config = CommandLineParser.parseCommandLine();
		api = createGitHubApi();

		for (user in config.users) {
			println("");
			println('## $user');
			println("");
			var issues = api.issues.list({ assignee: Some(user), per_page: 200 });
			var number = config.numberOfSelections > issues.length ? issues.length : config.numberOfSelections;
			for (_ in 0...number) {
				var index = Std.random(issues.length);
				var issue = issues[index];
				issues.splice(index, 1);
				println('* [${issue.title}](${issue.html_url})');
			}
		}
	}

	function createGitHubApi() {
		print("Opening GitHub API connection...");
		var request = new github.api.ApiConnection("https://api.github.com", config.accessToken);
		var api = new Api(request);
		api.enterRepository(config.repoOwner, config.repoName);
		println("done");
		return api;
	}

	static public function main() {
		new Main();
	}
}