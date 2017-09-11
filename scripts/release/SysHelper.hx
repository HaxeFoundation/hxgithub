class SysHelper {
	static public function stderr(s:String) {
		Sys.stderr().writeString(s + "\n");
	}
}