package archive.deflate;

using tink.io.Source;

interface Deflate {
	function compress(source:IdealSource):RealSource;
	function uncompress(source:IdealSource):RealSource;
}