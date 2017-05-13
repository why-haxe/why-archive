// package archive.tar;

// import format.tar.*;
// import haxe.io.*;

// using Lambda;
// using tink.io.Source;
// using tink.CoreApi;
// using haxe.io.Path;
// #if (sys || nodejs)
// using sys.FileSystem;
// using asys.io.File;
// #end

// typedef File = {
// 	name:String,
// 	size:Int,
// 	time:Date,
// 	fmod:Int,
// 	uid:Int,
// 	gid:Int,
// 	uname:String,
// 	gname:String,
// 	source:IdealSource,
// }

// class StdTar {
// 	public function new() {}
	
// 	#if (sys || nodejs)
// 	public function packPath(path:String) {
		
// 		function traverse(path:String, ?drill):Array<File> {
// 			path = path.absolutePath();
// 			if(drill == null) drill = [];
// 			var files = [];
// 			if(path.isDirectory()) {
// 				path = path.addTrailingSlash();
// 				drill = drill.concat([path.removeTrailingSlashes().split('/').pop()]);
// 				for(dir in path.readDirectory()) 
// 					files = files.concat(traverse(path.addTrailingSlash() + dir, drill));
// 			} else {
// 				var stat = path.stat();
// 				files.push({
// 					name: drill.join('/') + (drill.length > 0 ? '/' : '') + path.withoutDirectory(),
// 					size: stat.size,
// 					time: stat.mtime,
// 					fmod: stat.mode,
// 					uid: stat.uid,
// 					gid: stat.gid,
// 					uname: Std.string(stat.uid), // TODO: how to get name?
// 					gname: Std.string(stat.gid), // TODO: how to get name?
// 					source: path.readStream().idealize(function(_) return Source.EMPTY),
// 				});
// 			}
// 			return files;
// 		}
		
// 		return packFiles(traverse(path));
// 	}
// 	#end
	
// 	public function packFiles(files:Array<File>):RealSource {
// 		// TODO: make this streaming
// 		trace(files.length);
// 		return Future.ofMany([for(file in files) {
// 			file.source.all().map(function(chunk) return {
// 				fileName: file.name,
// 				fileSize: file.size,
// 				fileTime: file.time,
// 				fmod: file.fmod,
// 				uid: file.uid,
// 				gid: file.gid,
// 				uname: file.uname,
// 				gname: file.gname,
// 				data: chunk,
// 			});
// 		}]).next(function(data) {
// 			for(file in data) trace(file.fileName, file.fileSize);
// 			var output = new BytesOutput();
// 			new Writer(output).write(data.list());
// 			var bytes = output.getBytes();
// 			for(file in new Reader(new BytesInput(bytes)).read()) trace(file.fileName, file.fileSize);
// 			return Source.ofInput('Tar stream', new BytesInput(bytes));
// 		});
// 	}
// }