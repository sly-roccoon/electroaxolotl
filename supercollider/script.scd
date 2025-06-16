NetAddr.langPort;

~vPlayer = Array.new(3);
~vPlayer = [0,0,0];

// OSC responder for player position
(
OSCdef(\player, {
    arg msg, time, addr, recvPort;
    var x, y, z;

    // Extract coordinates (assuming Godot sends [x, y, z])
    #x, y, z = msg[1..3];

    // Store in global variables
	~vPlayer[0] = x;
    ~vPlayer[1] = y;
    ~vPlayer[2] = z;

	~vPlayer.postln;

}, '/player'); // Match this address in GodOSC
)

// OSC responder for continuous particles
(
OSCdef(\continuous, {
    arg msg, time, addr, recvPort;
    var x, y, z, size, speed;

	#x, y, z, size, speed = msg[1..5];
	size.postln;
}, '/continuous');
)

// OSC responder for collision particles
(
OSCdef(\collision, {
    arg msg, time, addr, recvPort;
    var x, y, z, size, speed;

	#x, y, z, size, speed = msg[1..5];
	size.postln;
}, '/collision');
)