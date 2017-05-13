package archive.tar;

import tink.streams.IdealStream;
import tink.streams.RealStream;

using tink.io.Source;
using tink.CoreApi;

interface Tar {
	function pack(files:IdealStream<Entry<Noise>>):RealSource;
	function extract(source:IdealSource):RealStream<Entry<Error>>;
}

