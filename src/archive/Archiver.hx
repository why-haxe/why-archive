package archive;

import tink.streams.IdealStream;
import tink.streams.RealStream;

using tink.io.Source;
using tink.CoreApi;

interface Archiver {
	function pack(files:IdealStream<Entry<Noise>>):RealSource;
	function unpack(source:IdealSource):RealStream<Entry<Error>>;
}

