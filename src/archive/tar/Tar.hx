package archive.tar;

import tink.streams.IdealStream;
import tink.streams.RealStream;

using tink.io.Source;
using tink.CoreApi;

interface Tar {
	function pack(files:IdealStream<Entry<Noise>>):RealSource;
	function extract(source:IdealSource):RealStream<Entry<Error>>;
}

typedef Entry<Quality> = {
	name:String,
	size:Int,
	?mode:Int,
	?mtime:Date,
	?uid:Int,
	?gid:Int,
	?uname:String,
	?gname:String,
	source:Source<Quality>,
}