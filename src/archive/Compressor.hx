package archive;

using tink.io.Source;

interface Compressor {
	function compress(source:IdealSource):RealSource;
	function uncompress(source:IdealSource):RealSource;
}