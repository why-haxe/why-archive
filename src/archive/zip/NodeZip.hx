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
	
	public function pack(files:RealStream<Entry<Error>>):RealSource {
		var pack:Dynamic = js.Lib.require('archiver')('zip', {zlib: {level: 9}});
		
		files.forEach(function(file:Entry<Error>) {
			pack.append(file.source.toNodeStream(), {
				name: file.name, 
				mode: file.mode,
				stats: { // TODO: pass file stats properly
					size: file.size,
				}
			});
			return Resume;
		}).handle(function(o) switch o {
			case Depleted: pack.finalize();
			case Failed(e): pack.emit('error', new js.Error(e.message));
			// case Clogged(e, _): pack.emit('error', new js.Error(e.message));
			case Halted(_): throw 'unreachable';
		});
		
		return Source.ofNodeStream('Zip package', pack);
	}
	
	public function unpack(source:RealSource):RealStream<Entry<Error>> {
		var extract:Dynamic = js.Lib.require('unzipper').Parse();
		
		
		var trigger = Signal.trigger();
		var out = new SignalStream(trigger);
		extract.on('entry', function(entry:Dynamic) {
			trigger.trigger(Data({
				name: entry.path,
				size: entry.vars.uncompressedSize,
				mode: entry.mode, // TODO: properly propagate this value
				mtime: entry.mtime, // TODO: properly propagate this value
				uid: entry.uid, // TODO: properly propagate this value
				gid: entry.gid, // TODO: properly propagate this value
				uname: entry.uname, // TODO: properly propagate this value
				gname: entry.gname, // TODO: properly propagate this value
				source: Source.ofNodeStream('Zip entry: ${entry.name}', entry),
			}));
		});

		extract.on('error', function(e) trigger.trigger(Fail(tink.core.Error.withData(e.code, e.messaage, e))));
		extract.on('finish', function() {
			trigger.trigger(End);
		});

		source.pipeTo(Sink.ofNodeStream('Zip extractor', extract), {end: true}).handle(function(o) switch o {
			case AllWritten: // ok
			case SourceFailed(e) | SinkFailed(e, _): trigger.trigger(Fail(e));
			case SinkEnded(_): trigger.trigger(Fail(new Error('Unexpected end of sink')));
		});
		
		return out;
	}
}