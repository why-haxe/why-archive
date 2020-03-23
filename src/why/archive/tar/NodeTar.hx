package why.archive.tar;

import tink.streams.Stream;
import tink.streams.IdealStream;
import tink.streams.RealStream;
import tink.Chunk;
import js.node.Zlib;
import js.node.Buffer;
import js.node.stream.PassThrough;
import js.node.stream.Readable;
import why.archive.tar.Tar;
import #if haxe4 js.lib.Error #else js.Error #end as JsError;

using tink.CoreApi;
using tink.io.Sink;
using tink.io.Source;

class NodeTar implements Tar {
	
	public function new() {}
	
	public function pack(files:RealStream<Entry<Error>>):RealSource {
		var tar = js.Lib.require('tar-stream');
		var pack:Dynamic = tar.pack();
		
		files.forEach(function(file:Entry<Error>) {
			var entry = pack.entry({name: file.name, size: file.size}); // TODO: pass file stats properly
			return file.source.pipeTo(Sink.ofNodeStream('Tar entry: ${file.name}', entry), {end: true})
				.map(function(o) return switch o {
					case AllWritten: Handled.Resume;
					case SourceFailed(e) | SinkFailed(e, _): Handled.Clog(e);
					case SinkEnded(_): Handled.Clog(new Error('Unexpected end of tar pack'));
				});
		}).handle(function(o) switch o {
			case Depleted: pack.finalize();
			case Failed(e): pack.emit('error', new JsError(e.message));
			case Clogged(e, _): pack.emit('error', new JsError(e.message));
			case Halted(_): throw 'unreachable';
		});
		
		return Source.ofNodeStream('Tar package', pack);
	}
	
	public function unpack(source:RealSource):RealStream<Entry<Error>> {
		var tar = js.Lib.require('tar-stream');
		var extract:Dynamic = tar.extract();
		
		var trigger = Signal.trigger();
		var out = new SignalStream(trigger);
		
		var count = 0; // HACK: https://github.com/mafintosh/tar-stream/issues/71
		extract.on('entry', function(header, stream, next) {
			count++;
			trigger.trigger(Data({
				name: header.name,
				size: header.size,
				mode: header.mode,
				mtime: header.mtime,
				uid: header.uid,
				gid: header.gid,
				uname: header.uname,
				gname: header.gname,
				source: Source.ofNodeStream('Tar entry: ${header.name}', stream),
			}));
			next();
		});

		extract.on('error', function(e) trigger.trigger(Fail(tink.core.Error.withData(e.code, e.messaage, e))));
		extract.on('finish', function() {
			trigger.trigger(count == 0 ? Fail(new Error('Invalid TAR')) : End);
		});

		source.pipeTo(Sink.ofNodeStream('Tar extractor', extract), {end: true}).handle(function(o) switch o {
			case AllWritten: // ok
			case SourceFailed(e) | SinkFailed(e, _): trigger.trigger(Fail(e));
			case SinkEnded(_): trigger.trigger(Fail(new Error('Unexpected end of sink')));
		});
		return out;
	}
}