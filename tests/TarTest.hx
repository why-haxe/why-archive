package;

import haxe.io.*;
import tink.unit.Assert.*;
import tink.streams.Stream;
import tink.Chunk;
import archive.tar.*;
import archive.tar.Tar;

using tink.CoreApi;
using tink.io.Source;

@:asserts
class TarTest {
	public function new() {}
	
	public function invalid() {
		var data:Chunk = Bytes.ofString('some random content');
		var source:IdealSource = data;
		
		var tar = new NodeTar();
		var unpacked = tar.extract(source);
		
		return unpacked.forEach(function(entry) return Resume)
			.map(function(o) return assert(o.match(Failed(_))));
	}
	
	public function roundtrip() {
		function file(name:String, size:Int):Entry<Noise> return {
			name: name,
			size: size,
			source: (Bytes.alloc(size):Chunk),
		}
		
		var tar = new NodeTar();
		
		var files = [
			file('src/archive/deflate/NodeDeflate.hx', Std.random(999999)),
			file('src/archive/gzip/NodeGzip.hx', Std.random(999999)),
		];
		
		var packed = tar.pack(files.iterator()).idealize(rescue);
		var entries = tar.extract(packed);
		
		var iter = files.iterator();
		entries.forEach(function(entry:Entry<Error>) 
			return if(iter.hasNext()) {
				var file = iter.next();
				asserts.assert(file.name == entry.name);
				asserts.assert(file.size == entry.size);
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