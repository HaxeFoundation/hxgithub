import haxe.io.*;
import sys.io.*;
import Config.Target;

using StringTools;

class BinaryDownloader {

	var config:Config;
	var handledTargets:Int;
	var failed:Bool;

	public function new(config:Config) {
		this.config = config;
	}

	public function run() {
		handledTargets = 0;
		failed = false;

		Sys.println("Downloading files");

		for (target in config.targets) {
			neko.vm.Thread.create(handleTarget.bind(target));
		}

		while(handledTargets < config.targets.length) { }

		if (failed) {
			Sys.println("Command " + Sys.args().join(" ") + " failed");
			Sys.exit(1);
		} else {
			Sys.println("Done downloading " + handledTargets + " files");
		}
	}

	function handleTarget(target:Target) {
		try {
			var fileName = switch (target) {
				case Windows32 | Windows32Installer | Windows64 | Windows64Installer: config.fileName.replace(".tar.gz", ".zip");
				case Linux | Mac | MacInstaller: config.fileName.replace(".zip", ".tar.gz");
			}
			var url = Path.join([config.buildServerUrl, target, fileName]);
			Sys.println('Requesting $url');
			var request = new haxe.Http(url);
			request.onData = onData.bind(target);
			request.onError = onError.bind(target);
			request.request();
		} catch(e:Dynamic) {
			failed = true;
			handledTargets++;
			throw e;
		}
	}

	function unpack(s:String) {
		var gzReader = new format.gz.Reader(new StringInput(s));
		var out = new BytesOutput();
		gzReader.readHeader();
		gzReader.readData(out);
		var tarReader = new format.tar.Reader(new BytesInput(out.getBytes()));
		return tarReader.read();
	}

	function zip(data:List<format.tar.Data.Entry>) {
		var entries = new List();
		for (file in data) {
			var entry = {
				fileName: file.fileName,
				fileSize: file.data.length,
				fileTime: Date.now(),
				compressed: false,
				dataSize: file.data.length,
				data: file.data,
				crc32: haxe.crypto.Crc32.make(file.data),
				extraFields: null
			};
			haxe.zip.Tools.compress(entry, 1);
			entries.add(entry);
		}
		return entries;
	}

	function onData(target:Target, s:String) {
		Sys.println('Received content for $target');
		var name = 'haxe-${config.haxeVersion}-${config.getFileName(target)}';
		name = config.haxeVersion + "/" + name;
		switch(target) {
			case Linux64 | Mac:
				File.saveContent(name + ".tar.gz", s);
			case Windows32 | Windows64:
				File.saveContent(name + ".zip", s);
			case MacInstaller:
				var data = unpack(s);
				while(data.first().data.length == 0) {
					data.pop();
				}
				File.saveBytes(name + ".pkg", data.first().data);
			case Windows32Installer | Windows64Installer:
				var zip = new haxe.zip.Reader(new haxe.io.StringInput(s));
				for (elt in zip.read()) {
					if (elt.fileSize == 0) {
						continue;
					}
					File.saveBytes(name + ".exe", haxe.zip.Reader.unzip(elt));
				}
		}
		Sys.println('Finished $target');
		handledTargets++;
	}

	function onError(target:String, s:String) {
		Sys.println('Could not retrieve content for $target: $s');
		failed = true;
		handledTargets++;
	}
}