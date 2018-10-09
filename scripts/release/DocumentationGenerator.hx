import Sys.*;
import SysHelper.*;

class DocumentationGenerator {

	static public function run(config:Config) {
		var path = "./" + config.haxeVersion + "/haxe-" + config.haxeVersion + "-";
		switch (Sys.systemName()) {
			case "Windows":
				path += "win.zip";
			case platform:
				stderr("Unsupported platform: " + platform);
				exit(1);
		}
		if (!sys.FileSystem.exists(path)) {
			stderr("Binary " + path + " does not exist (required for documentation generation)");
			exit(1);
		}
		print("Unzipping " + path + "...");
		var input = sys.io.File.read(path);
		var zip = new haxe.zip.Reader(input);
		var baseDir = "./" + config.haxeVersion + "/doc/";
		for (elt in zip.read()) {
			if (elt.fileSize == 0) {
				continue;
			}
			var file = haxe.io.Path.join([baseDir, elt.fileName]);
			var path = new haxe.io.Path(file);
			if (!sys.FileSystem.exists(path.dir)) {
				sys.FileSystem.createDirectory(path.dir);
			}
			sys.io.File.saveBytes(file, haxe.zip.Reader.unzip(elt));
		}
		println(" done");

		var unzipPath = config.haxeVersion + "/doc/haxe-" + config.haxeVersion;
		var path = config.haxeVersion + "/api-" + config.haxeVersion + ".zip";
		print("Generating documentation XML...");
		var failed = 0 != command("cd " + unzipPath + " && haxe --cwd extra doc.hxml");
		if (failed) {
			stderr("Could not generate documentation XML files");
			exit(1);
		}
		println(" done");
		print("Generating documentation .zip...");
		command('haxelib run dox -D website "http://haxe.org/" --title "Haxe API" -o $path -D version "${config.haxeVersion}" -i $unzipPath/extra/doc -ex microsoft -ex javax -ex cs.internal -D source-path https://github.com/HaxeFoundation/haxe/blob/master/std/');
		println(" done");
		return path;
	}
}