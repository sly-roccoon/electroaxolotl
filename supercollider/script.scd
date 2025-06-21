ServerOptions.outDevices;
(
s.quit;
s.options.numOutputBusChannels = 16;
Server.default.options.outDevice = "ASIO : ReaRoute ASIO (x64)";
s.boot;
NetAddr.langPort;
)
NetAddr.langPort;
Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");
// Quarks.install("https://github.com/madskjeldgaard/binauraldecoders");
// Quarks.install("ReaCollider");

// ATK.load;

// BinauralDecoderCIPIC.new(hoaOrder:3);
s.freeAll;
(
~vPlayer = [0,0,0];
~vPlayerRot = [0,0];

~continuous = ();
~maxAmp = 1;
)

// Rotates a 3D vector [x, y, z] by yaw (around Z) and pitch (around X)
// yaw and pitch in radians
(
~rotateVector = { |x, y, z, yaw, pitch|
    // First, rotate by yaw (around Z axis)
    var x1 =  x * yaw.cos - y * yaw.sin;
    var y1 =  x * yaw.sin + y * yaw.cos;
    var z1 =  z;
    // Then, rotate by pitch (around X axis)
    var x2 = x1;
    var y2 = y1 * pitch.cos - z1 * pitch.sin;
    var z2 = y1 * pitch.sin + z1 * pitch.cos;
    [x2, y2, z2];
};
)

// OSC responder for player position
(
OSCdef(\player, {
    arg msg, time, addr, recvPort;
    var x, y, z, pitch, yaw;

    // Extract coordinates (assuming Godot sends [x, y, z])
    #x, y, z, pitch, yaw = msg[1..5];

    // Store in global variables
	~vPlayer[0] = x;
    ~vPlayer[1] = y;
    ~vPlayer[2] = z;

	~vPlayerRot[0] = pitch;
	~vPlayerRot[1] = yaw;

}, '/player'); // Match this address in GodOSC
)

(
// Synth definition for continuous particles
SynthDef(\continuousParticle, { |id, freq=440, harm=1, amp=0.1, gate=1, azim=0, elev=0|
    var sig, env, hoa;
    env = EnvGen.kr(Env.asr(0.01, 1, 0.5), gate, doneAction:2);
    sig = 0;
	(1..10).do { |i|
		sig = sig + SinOsc.ar(freq * i, 0, amp * (-1.0*(i-1)/harm).exp);
    };

    sig = sig * env * amp;
	sig = FreeVerb.ar(sig, 0.3, 1.0, 0.1);

	hoa = HoaEncodeDirection.ar(sig, azim, elev, 1.5, AtkHoa.defaultOrder);

	Out.ar(0, hoa);
}).add;
)

(
SynthDef(\collisionParticle, { |freq=440, harm=1, amp=0.5, azim=0, elev=0|
    var sig, env, hoa;
    env = EnvGen.kr(Env.perc(0.001, 5.0/harm, amp, -12), doneAction:2);
    sig = 0;
	(1..10).do { |i|
		sig = sig + SinOsc.ar(freq * i, 0, amp * (-1.0*(i-1)/harm).exp);
    };

    sig = sig * env * amp;
    sig = FreeVerb.ar(sig, 0.3, 1.0, 0.1);

	hoa = HoaEncodeDirection.ar(sig, azim, elev, 1.5, AtkHoa.defaultOrder);

    Out.ar(0, hoa);
}).add;
)

// OSC responder for continuous particles
(
OSCdef(\continuous, {
    arg msg, time, addr, recvPort;
    var id, x, y, z, size, speed;
    var freq, harm, amp;
	var relX, relY, relZ, azim, elev, dist;
	var outX, outY, outZ;

	#id, x, y, z, size, speed = msg[1..6];

	freq = speed.linexp(1, 50, 100, 2000);
    harm = size.linexp(0.1, 20, 10, 0.5);

	relX = x - (~vPlayer[0] ? 0);
    relY = y - (~vPlayer[1] ? 0);
    relZ = z - (~vPlayer[2] ? 0);

	/*#outX, outY, outZ = ~rotateVector.(relX, relY, relZ, -1.0*~vPlayerRot[1], -1.0*~vPlayerRot[0]);

    azim = atan2(outY, outX); // Azimuth (horizontal angle)
    elev = atan2(outZ, hypot(outX, outY)); // Elevation (vertical angle)
    dist = hypot(hypot(outX, outY), outZ);
*/
	azim = atan2(relY, relX); // Azimuth (horizontal angle)
    elev = atan2(relZ, hypot(relX, relY)); // Elevation (vertical angle)
    dist = hypot(hypot(relX, relY), relZ);

	amp = ~maxAmp / max(1, dist);

	if(~continuous[id].notNil) {
        ~continuous[id].set(\freq, freq, \azim, azim, \elev, elev);
    } {
        ~continuous[id] = Synth(\continuousParticle, [\id: id, \freq: freq, \harm: harm, \amp: 0.05, \azim: azim, \elev: elev]);
    };
}, '/continuous');
)

(
OSCdef(\continuousRemoved, {
    arg msg, time, addr, recvPort;
    var id = msg[1];
	~continuous[id].set(\gate, 0);
	~continuous.removeAt(id);
}, '/rm_continuous')
)

// OSC responder for collision2 particles
(
OSCdef(\collision, {
    arg msg, time, addr, recvPort;
    var id, x, y, z, size, speed;
	var freq, harm, amp;
	var relX, relY, relZ, azim, elev, dist;
	var outX, outY, outZ;

	#id, x, y, z, size, speed = msg[1..6];

	freq = speed.linexp(1, 50, 100, 2000);
    harm = size.linexp(0.1, 20, 10, 0.5);

	relX = x - (~vPlayer[0] ? 0);
    relY = y - (~vPlayer[1] ? 0);
    relZ = z - (~vPlayer[2] ? 0);

	/*#outX, outY, outZ = ~rotateVector.(relX, relY, relZ, -1.0*~vPlayerRot[1], -1.0*~vPlayerRot[0]);

    azim = atan2(outY, outX); // Azimuth (horizontal angle)
    elev = atan2(outZ, hypot(outX, outY)); // Elevation (vertical angle)
    dist = hypot(hypot(outX, outY), outZ);
*/
	azim = atan2(relY, relX); // Azimuth (horizontal angle)
    elev = atan2(relZ, hypot(relX, relY)); // Elevation (vertical angle)
    dist = hypot(hypot(relX, relY), relZ);

	amp = ~maxAmp/4/* / max(1, dist)*/;

	Synth(\collisionParticle, [\freq: freq, \harm: harm, \amp: amp, \azim: azim, \elev: elev]);
}, '/collision');
)

(
OSCdef(\clearAll, {
	arg msg, time, addr, recvPort;

	~continuous.do { |synth| synth.free };
	~continuous = ();
}, '/clear');
)