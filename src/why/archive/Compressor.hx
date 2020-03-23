package why.archive;

using tink.io.Source;

interface Compressor {
	function extension():String;
	function compress(source:RealSource):RealSource;
	function uncompress(source:RealSource):RealSource;
}