package archive.deflate;

import js.node.Zlib;

using tink.CoreApi;
using tink.io.Source;

class NodeDeflateRaw implements Deflate {
	
	var options:ZlibOptions;
	
	public function new(?options)
		this.options = options;
	
	public function compress(source:RealSource):RealSource
		return Source.ofNodeStream('DeflateRaw stream', source.toNodeStream().pipe(Zlib.createDeflateRaw(options)));
		
	public function uncompress(source:RealSource):RealSource
		return Source.ofNodeStream('InflateRaw stream', source.toNodeStream().pipe(Zlib.createInflateRaw(options)));
}