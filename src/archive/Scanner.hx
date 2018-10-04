package archive;

using tink.streams.RealStream;
using tink.CoreApi;

interface Scanner {
	function scan():RealStream<Entry<Error>>;
}