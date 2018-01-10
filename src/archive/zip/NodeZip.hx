package archive.zip;

import tink.streams.Stream;
import tink.streams.IdealStream;
import tink.streams.RealStream;
import tink.Chunk;
import js.node.Zlib;
import js.node.Buffer;
import js.node.stream.PassThrough;
import js.node.stream.Readable;
import archive.zip.Zip;
import js.node.fs.Stats;

using tink.CoreApi;
using tink.io.Sink;
using tink.io.Source;

class NodeZip implements Zip {
	
	public function new() {}
	
	public function pack(files:IdealStream<Entry<Noise>>):RealSource {
		var pack:Dynamic = js.Lib.require('archiver')('zip', {zlib: {level: 9}});
		
		files.forEach(function(file:Entry<Noise>) {
			
			pack.append(file.source.toNodeStream(), {name: file.name, stats: {size: file.size}});
			return Resume;
		}).handle(function(o) switch o {
			case Depleted: pack.finalize();
			// case Clogged(e, _): pack.emit('error', new js.Error(e.message));
			case Halted(_): throw 'unreachable';
		});
		
		return Source.ofNodeStream('Zip package', pack);
	}
	
	public function extract(source:IdealSource):RealStream<Entry<Error>> {
		var extract:Dynamic = js.Lib.require('unzipper').Parse();
		
		return new SignalStream(Signal.generate(function(trigger:Yield<Entry<Error>, Error>->Void) {
			
			var count = 0; // HACK: https://github.com/mafintosh/zip-stream/issues/71
			extract.on('entry', function(entry:Dynamic) {
				trace(entry.type);
				trace(entry.size);
				trigger(Data({
					name: entry.path,
					size: entry.size,
					mode: entry.mode,
					mtime: entry.mtime,
					uid: entry.uid,
					gid: entry.gid,
					uname: entry.uname,
					gname: entry.gname,
					source: Source.ofNodeStream('Zip entry: ${entry.path}', entry),
				}));
			});

			extract.on('error', function(e) trigger(Fail(tink.core.Error.withData(e.code, e.messaage, e))));
			extract.on('finish', function() {
				trigger(End);
			});

			source.pipeTo(Sink.ofNodeStream('Zip extractor', extract), {end: true}).handle(function(o) switch o {
				case AllWritten: // ok
				case SinkFailed(e, _): trigger(Fail(e));
				case SinkEnded(_): trigger(Fail(new Error('Unexpected end of sink')));
			});
			
		}));
	}
}