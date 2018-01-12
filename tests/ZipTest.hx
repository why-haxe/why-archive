package;

import haxe.io.*;
import tink.unit.Assert.*;
import tink.streams.Stream;
import tink.Chunk;
import archive.zip.*;
import archive.zip.Zip;

using tink.CoreApi;
using tink.io.Source;

@:asserts
class ZipTest {
	public function new() {}
	
	public function invalid() {
		var data:Chunk = Bytes.ofString('some random content');
		var source:IdealSource = data;
		
		var zip = new NodeZip();
		var unpacked = zip.unpack(source);
		
		return unpacked.forEach(function(entry) return Resume)
			.map(function(o) return assert(o.match(Failed(_))));
	}
	
	public function roundtrip() {
		function file(name:String, size:Int):Entry<Noise> return {
			name: name,
			size: size,
			source: (Bytes.alloc(size):Chunk),
		}
		
		var zip = new NodeZip();
		
		var files = [
			file('src/archive/deflate/NodeDeflate.hx', Std.random(999999)),
			file('src/archive/gzip/NodeGzip.hx', Std.random(999999)),
		];
		
		var packed = zip.pack(files.iterator()).idealize(rescue);
		var entries = zip.unpack(packed);
		
		var iter = files.iterator();
		entries.forEach(function(entry:Entry<Error>) 
			return if(iter.hasNext()) {
				var file = iter.next();
				asserts.assert(file.name == entry.name);
				// asserts.assert(file.size == entry.size);
				entry.source.all().map(function(c) {
					asserts.assert(c.sure().length == file.size);
					return Resume;
				});
			} else {
				Future.sync(Clog(new Error('No more files')));
			}
		).handle(function(o) switch o {
			case Depleted: asserts.done();
			case Clogged(e, _) | Failed(e): asserts.fail(e);
			case Halted(_): throw 'unreachable';
		});
		
		return asserts;
	}
	
	function rescue(e:Error):RealSource {
		trace(e);
		return Source.EMPTY;
	}
}