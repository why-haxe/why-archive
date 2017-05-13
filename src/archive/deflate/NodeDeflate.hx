package archive.deflate;

import js.node.Zlib;

using tink.CoreApi;
using tink.io.Source;

class NodeDeflate implements Deflate {
	
	var options:ZlibOptions;
	
	public function new(?options)
		this.options = options;
	
	public function compress(source:IdealSource):RealSource
		return Source.ofNodeStream('Gzip stream', source.toNodeStream().pipe(Zlib.createDeflate(options)));
		
	public function uncompress(source:IdealSource):RealSource
		return Source.ofNodeStream('Gunzip stream', source.toNodeStream().pipe(Zlib.createInflate(options)));
}