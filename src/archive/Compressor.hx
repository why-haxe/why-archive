package archive;

using tink.io.Source;

interface Compressor {
	function compress(source:RealSource):RealSource;
	function uncompress(source:RealSource):RealSource;
}