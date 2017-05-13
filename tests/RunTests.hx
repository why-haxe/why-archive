package ;

import tink.testrunner.*;
import tink.unit.*;

class RunTests {

	static function main() {
		
		Runner.run(TestBatch.make([
			new TarTest(),
			new GzipTest(),
			new DeflateTest(),
		])).handle(Runner.exit);
	}

}