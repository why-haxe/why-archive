# archive

Streaming archives (tar, zip, tgz, etc)

## Overview

There is 2 interfaces currently:

**Compressor**

This defines an interface for compressing/uncompressing a data stream.

Example implementations: Deflate, Gzip

```haxe
interface Compressor {
	function compress(source:RealSource):RealSource;
	function uncompress(source:RealSource):RealSource;
}
```

**Archiver**

This defines an interface for packing serveral file entries into one file archive and optionally compressing the entries, and vice-versa (unpacking).

Example implementations: Tar, Zip

```haxe
interface Archiver {
	function pack(files:RealStream<Entry>):RealSource;
	function unpack(source:RealSource):RealStream<Entry>;
}
```

