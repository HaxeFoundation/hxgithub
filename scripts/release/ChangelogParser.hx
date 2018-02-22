using StringTools;
using Lambda;

class ChangelogParser {
	static public function parse(config: Config, s:String) {
		var changelog = new StringBuf();
		var active = false;
		var lines = s.replace("\r", "").split("\n");
		lines = lines.filter(function(line) return line != "");
		for (line in lines) {
			if (line.startsWith("\t")) {
				if (!active) {
					continue;
				}
				if (line.endsWith(":")) {
					changelog.add("\n__" + line.trim().substr(0, -1) + "__:\n\n");
				} else {
					line = ~/\(#(([0-9][0-9][0-9][0-9]))\)/.map(line, function(r) return "([#" + r.matched(1) + "](https://github.com/HaxeFoundation/haxe/issues/" + r.matched(1) +"))");
					changelog.add("* " + line.trim() + "\n");
				}
			} else {
				var regex = ~/[0-9]+-[0-9][0-9]-[0-9][0-9]: (.*)/;
				if (regex.match(line)) {
					var version = regex.matched(1);
					if (config.changelogVersions.has(version)) {
						changelog.add("\n## " + line.trim() + "\n");
						active = true;
					} else {
						active = false;
					}
				}
			}
		}
		return changelog.toString();
	}
}