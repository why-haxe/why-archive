package why.archive.scanner;

import why.archive.*;
import tink.streams.Stream;

using tink.streams.RealStream;
using asys.io.File;
using asys.FileSystem;
using haxe.io.Path;
using tink.CoreApi;

@:require('asys')
class AsysScanner implements Scanner {
	var path:String;
	var root:String;
	
	public function new(path, ?root) {
		this.path = path;
		this.root = root == null ? path.withoutDirectory() : root;
	} 
		
	public function scan():RealStream<Entry<Error>>
		return _scan(path, root)
			.next(function(entries) return Stream.ofIterator(entries.iterator()));
	
	function _scan(directory:String, root:String):Promise<Array<Entry<Error>>> {
		var ret = [];
		return directory.readDirectory()
			.next(function(files) return {
				Promise.inParallel([for(f in files) {
					var path = Path.join([directory, f]);
					var relativePath = Path.join([root, f]);
					path.isDirectory()
						.next(function(isDir) return {
							if(isDir) {
								_scan(path, relativePath).next(function(entries) return {
									ret = ret.concat(entries);
									Noise;
								});
							} else {
								path.stat().next(function(stat) return {
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
			.next(function(_) return ret);
	}
}