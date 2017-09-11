package github.api;

import haxe.Http;
import haxe.Json;
import haxe.io.Path;

typedef Headers = Array<{name: String, value:String}>;

class ApiConnection {
	var apiUrl:String;
	var token:String;

	public function new(apiUrl:String, token:String) {
		this.apiUrl = apiUrl;
		this.token = token;
	}

	public function delete<T>(s:String):T {
		return doRequest(Path.join([apiUrl, s]), customRequest.bind(_, true, "DELETE"));
	}

	public function get<T>(s:String):T {
		return doRequest(Path.join([apiUrl, s]), request.bind(_, false));
	}

	public function patch<T>(url:String, data:String):T {
		return doRequest(Path.join([apiUrl, url]), customRequest.bind(_, true, "PATCH"), data);
	}

	public function post<T>(url:String, data:String):T {
		return doRequest(Path.join([apiUrl, url]), customRequest.bind(_, true, "POST"), data);
	}

	public function postDirect<T>(url:String, data:String, headers:Headers):T {
		return doRequest(url, customRequest.bind(_, true, "POST", headers), data);
	}

	public function put<T>(url:String, data:String):T {
		return doRequest(Path.join([apiUrl, url]), customRequest.bind(_, true, "PUT"), data);
	}

	function doRequest<T>(url:String, f:Http->Void, ?data = null):T {
		var http = new Http(url);
		if (data != null) {
			http.setPostData(data);
		}
		var isError:Null<Bool> = null, msg = null;
		http.onData = function (s) { isError = false; msg = s; };
		http.onError = function (s) { isError = true; msg = s; };
		f(http);
		if (isError) {
			throw 'Error requesting $url: $msg';
		} else {
			return Json.parse(msg);
		}
	}

	function request(http:Http, post:Bool) {
		setAuth(http);
		http.request(post);
	}

	function customRequest(http:Http, post:Bool, method:String, ?headers:Headers) {
		setAuth(http);
		if (headers != null) {
			for (header in headers) {
				http.setHeader(header.name, header.value);
			}
		}
		var output = new haxe.io.BytesOutput();
		var err = false;
		var old = http.onError;
		http.onError = function(e) {
			#if neko
			untyped http.responseData = neko.Lib.stringReference(output.getBytes());
			#else
			untyped http.responseData = output.getBytes().toString();
			#end
			err = true;
			old(e);
		}
		http.customRequest(post,output, null, method);
		if( !err )
		#if neko
			untyped http.onData(http.responseData = neko.Lib.stringReference(output.getBytes()));
		#else
			untyped http.onData(http.responseData = output.getBytes().toString());
		#end
	}

	function setAuth(http:Http) {
		http.setHeader("User-Agent", "curl/7.27.0");
		http.setHeader("Authorization", 'token $token');
	}
}