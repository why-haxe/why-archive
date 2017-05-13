package;

import haxe.io.*;
import tink.unit.Assert.*;
import tink.Chunk;
import archive.gzip.*;

using tink.CoreApi;
using tink.io.Source;

class GzipTest {
	public function new() {}
	
	public function roundtrip() {
		var data:Chunk = Bytes.alloc(Std.random(999999));
		var source:IdealSource = data;
		
		var gzip = new NodeGzip();
		var compressed = gzip.compress(source);
		var uncompressed = gzip.uncompress(compressed.idealize(rescue));
		
		return uncompressed.all().next(function(c) return assert(c.length == data.length));
	}
	
	function rescue(e:Error):RealSource {
		trace(e);
		return Source.EMPTY;
	}
}