package why.archive.deflate;

import js.node.Zlib;

using tink.CoreApi;
using tink.io.Source;

/**
 * Compress data using deflate, with a zlib header.
 */
class NodeDeflate implements Deflate {
	
	var options:ZlibOptions;
	
	public function new(?options)
		this.options = options;
	
	public function extension() return 'zip'; // TODO: w/ zlib header == zip?
	
	public function compress(source:RealSource):RealSource
		return Source.ofNodeStream('Deflate stream', source.toNodeStream().pipe(Zlib.createDeflate(options)));
		
	public function uncompress(source:RealSource):RealSource
		return Source.ofNodeStream('Inflate stream', source.toNodeStream().pipe(Zlib.createInflate(options)));
}