package github.api;

@:enum abstract IssueFilter(String) {
	var Assigned = "assigned";
	var Created = "created";
	var Mentioned = "mentioned";
	var Subscribed = "subscribed";
	var All = "all";
}

@:enum abstract IssueState(String) {
	var Open = "open";
	var Closed = "closed";
	var All = "all";
}

@:enum abstract IssueSort(String) {
	var Created = "created";
	var Updated = "updated";
	var Comments = "comments";
}

@:enum abstract IssueDirection(String) {
	var Asc = "asc";
	var Desc = "desc";
}

enum IssueOption<T> {
	None;
	All;
	Some(s:T);
}

typedef IssueParameters = {
	> Pagination,
	?milestone: IssueOption<Int>,
	?assignee: IssueOption<String>,
	?creator: String,
	?mentioned: String,
	?filter: IssueFilter,
	?state: IssueState,
	?labels: Array<String>,
	?sort: IssueSort,
	?direction: IssueDirection,
	?since: String // TODO?
}

abstract IssueApi(Api) {
	public inline function new(api:Api) {
		this = api;
	}

	public function list(parameters:IssueParameters):Array<Issue> {
		var options = [];
		switch (parameters.milestone) {
			case null:
			case None: options.push("milestone=none");
			case All: options.push("milestone=*");
			case Some(i): options.push("milestone=" + Std.string(i));
		}
		switch (parameters.state) {
			case null:
			case Open: options.push("state=open");
			case Closed: options.push("state=closed");
			case All: options.push("state=all");
		}
		switch (parameters.assignee) {
			case null:
			case All: options.push("assignee=*");
			case None: options.push("assignee=none");
			case Some(s): options.push("assignee=" + s);
		}
		if (parameters.creator != null) {
			options.push("creator=" + parameters.creator);
		}
		if (parameters.mentioned != null) {
			options.push("mentioned=" + parameters.mentioned);
		}
		if (parameters.labels != null) {
			options.push("labels=" + parameters.labels.join(","));
		}
		if (parameters.sort != null) {
			options.push("sort=" + parameters.sort);
		}
		if (parameters.direction != null) {
			options.push("direction=" + parameters.direction);
		}
		if (parameters.since != null) {
			options.push("since=" + parameters.since);
		}
		if (parameters.page != null) {
			options.push("page=" + parameters.page);
		}
		if (parameters.per_page != null) {
			options.push("per_page=" + parameters.per_page);
		}
		var s = 'issues';
		if (options.length > 0) {
			s += "?";
			s += options.join("&");
		}
		return this.get(s);
	}
}