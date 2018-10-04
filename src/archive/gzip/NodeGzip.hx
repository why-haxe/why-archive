package archive.gzip;

import js.node.Zlib;

using tink.CoreApi;
using tink.io.Source;

class NodeGzip implements Gzip {
	
	var options:ZlibOptions;
	
	public function new(?options)
		this.options = options;
	
	public function compress(source:RealSource):RealSource
		return Source.ofNodeStream('Gzip stream', source.toNodeStream().pipe(Zlib.createGzip(options)));
		
	public function uncompress(source:RealSource):RealSource
		return Source.ofNodeStream('Gunzip stream', source.toNodeStream().pipe(Zlib.createGunzip(options)));
}