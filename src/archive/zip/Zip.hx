package archive.zip;

import tink.streams.IdealStream;
import tink.streams.RealStream;

using tink.io.Source;
using tink.CoreApi;

interface Zip {
	function pack(files:IdealStream<Entry<Noise>>):RealSource;
	function extract(source:IdealSource):RealStream<Entry<Error>>;
}

