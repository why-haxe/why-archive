package why.archive.deflate;

import js.node.Zlib;

using tink.CoreApi;
using tink.io.Source;

class NodeDeflate implements Deflate {
	
	var options:ZlibOptions;
	
	public function new(?options)
		this.options = options;
	
	public function compress(source:RealSource):RealSource
		return Source.ofNodeStream('Deflate stream', source.toNodeStream().pipe(Zlib.createDeflate(options)));
		
	public function uncompress(source:RealSource):RealSource
		return Source.ofNodeStream('Inflate stream', source.toNodeStream().pipe(Zlib.createInflate(options)));
}