package why.archive.deflate;

import js.node.Zlib;

using tink.CoreApi;
using tink.io.Source;

/**
 * Compress data using deflate, and do not append a zlib header.
 */
class NodeDeflateRaw implements Deflate {
	
	var options:ZlibOptions;
	
	public function new(?options)
		this.options = options;
	
	public function extension() return 'deflate';
	
	public function compress(source:RealSource):RealSource
		return Source.ofNodeStream('DeflateRaw stream', source.toNodeStream().pipe(Zlib.createDeflateRaw(options)));
		
	public function uncompress(source:RealSource):RealSource
		return Source.ofNodeStream('InflateRaw stream', source.toNodeStream().pipe(Zlib.createInflateRaw(options)));
}