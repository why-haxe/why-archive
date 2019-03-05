package why.archive;

using tink.io.Source;

typedef Entry<Quality> = {
	name:String,
	?size:Int,
	?mode:Int,
	?mtime:Date,
	?uid:Int,
	?gid:Int,
	?uname:String,
	?gname:String,
	source:Source<Quality>,
}