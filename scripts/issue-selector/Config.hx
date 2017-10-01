class Config {

	public var accessToken:String;
	public var users:Array<String>;
	public var repoOwner:String;
	public var repoName:String;
	public var numberOfSelections:Int;
	public var dry:Bool;

	public function new() {
		users = [];
		numberOfSelections = 1;
		dry = false;
	}
}