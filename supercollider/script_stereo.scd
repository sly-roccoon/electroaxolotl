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
~vPlayer = Array.new(3);
~vPlayer = [0,0,0];

~continuous = ();
~maxAmp = 1;
)
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

	// hoa = HoaEncodeDirection.ar(sig, azim, elev, 1.5, AtkHoa.defaultOrder);

	Out.ar(0, sig ! 2);
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

	// hoa = HoaEncodeDirection.ar(sig, azim, elev, 1.5, AtkHoa.defaultOrder);

    Out.ar(0, sig ! 2);
}).add;
)

// OSC responder for continuous particles
(
OSCdef(\continuous, {
    arg msg, time, addr, recvPort;
    var id, x, y, z, size, speed;
    var freq, harm, amp;
	var relX, relY, relZ, azim, elev, dist;

	#id, x, y, z, size, speed = msg[1..6];

	freq = speed.linexp(1, 50, 100, 2000);
    harm = size.linexp(0.1, 20, 10, 0.5);

	relX = x - ~vPlayer[0];
	relY = y - ~vPlayer[1];
	relZ = z - ~vPlayer[2];

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

	#id, x, y, z, size, speed = msg[1..6];

	freq = speed.linexp(1, 50, 100, 2000);
    harm = size.linexp(0.1, 20, 10, 0.5);

	relX = x - ~vPlayer[0];
	relY = y - ~vPlayer[1];
	relZ = z - ~vPlayer[2];

	azim = atan2(relY, relX); // Azimuth (horizontal angle)
	elev = atan2(relZ, hypot(relX, relY)); // Elevation (vertical angle)
	dist = hypot(hypot(relX, relY), relZ);

	amp = ~maxAmp / max(1, dist);

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