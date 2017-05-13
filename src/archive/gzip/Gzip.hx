package archive.gzip;

using tink.io.Source;

interface Gzip {
	function compress(source:IdealSource):RealSource;
	function uncompress(source:IdealSource):RealSource;
}