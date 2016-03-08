package ;

#if cpp
import cpp.vm.Thread;
import cpp.vm.Lock;
#elseif neko
import neko.vm.Thread;
import neko.vm.Lock;
#end


import haxe.io.Bytes;
import haxe.io.BytesInput;
import hxudp.UdpSocket;
import haxe.unit.*;

class UdpTest extends TestCase {
	var msg1(default, never) = "testing";
	var msg2(default, never) = "testing2";

	function server():Void {
		var lock:Lock = Thread.readMessage(true);
		var mainThread:Thread = Thread.readMessage(true);

		var s = new UdpSocket();
		assertTrue(s.create());
		assertTrue(s.bind(11999));
		assertTrue(s.setNonBlocking(false));
		// assertTrue(s.getMaxMsgSize() > 0); // this crashes on OSX...
		assertTrue(s.getReceiveBufferSize() > 0);
		
		mainThread.sendMessage(true); //notify server is ready

		var b = Bytes.alloc(80);
		var recLen = s.receive(b);
		assertEquals(msg1.length, recLen);
		var input = new BytesInput(b);
		assertEquals(msg1, input.readString(recLen));

		var recLen = s.receive(b);
		assertEquals(msg2.length, recLen);
		var input = new BytesInput(b);
		assertEquals(msg2, input.readString(recLen));

		assertTrue(s.close());

		lock.release();
	}

	function test():Void {
		//create a lock for knowing when server exit
		var lock = new Lock();

		var serverThread = Thread.create(server);
		serverThread.sendMessage(lock);
		serverThread.sendMessage(Thread.current());
		
		Thread.readMessage(true);

		var s = new UdpSocket();
		assertTrue(s.create());
		assertTrue(s.getSendBufferSize() > 0);
		assertTrue(s.connect("127.0.0.1", 11999));
		assertEquals(msg1.length, s.send(Bytes.ofString(msg1)));
		assertEquals(msg2.length, s.sendAll(Bytes.ofString(msg2)));
		assertTrue(s.close());

		//wait for server to exit
		while (!lock.wait(1)) {}
	}

	static public function main():Void {
		var runner = new TestRunner();
		runner.add(new UdpTest());
		var success = runner.run();
		Sys.exit(success ? 0 : 1);
	}
}
