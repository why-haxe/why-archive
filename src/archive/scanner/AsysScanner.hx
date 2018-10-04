package archive.scanner;

import archive.*;
import tink.streams.Stream;

using tink.streams.RealStream;
using asys.io.File;
using asys.FileSystem;
using haxe.io.Path;
using tink.CoreApi;

@:require('asys')
class AsysScanner implements Scanner {
	var path:String;
	
	public function new(path) 
		this.path = path;
		
	public function scan():RealStream<Entry<Error>>
		return _scan(path, path.withoutDirectory())
			.next(function(entries) {
				return Stream.ofIterator(entries.iterator());
			});
		
	
	function _scan(directory:String, root:String):Promise<Array<Entry<Error>>> {
		var ret = [];
		return directory.readDirectory()
			.next(files -> {
				Promise.inParallel([for(f in files) {
					var path = Path.join([directory, f]);
					var relativePath = Path.join([root, f]);
					path.isDirectory()
						.next(isDir -> {
							if(isDir) {
								_scan(path, relativePath).next(entries -> {
									ret = ret.concat(entries);
									Noise;
								});
							} else {
								path.stat().next(stat -> {
									ret.push({
										name: relativePath,
										size: stat.size,
										mode: stat.mode,
										mtime: stat.mtime,
										uid: stat.uid,
										gid: stat.gid,
										source: path.readStream(),
									});
									Noise;
								});
							}
						});
				}]);
			})
			.next(_ -> ret);
	}
}