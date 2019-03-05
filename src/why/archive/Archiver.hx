package why.archive;

import tink.streams.IdealStream;
import tink.streams.RealStream;

using tink.io.Source;
using tink.CoreApi;

interface Archiver {
	function pack(files:RealStream<Entry<Error>>):RealSource;
	function unpack(source:RealSource):RealStream<Entry<Error>>;
}

