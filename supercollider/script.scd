Platform.userAppSupportDir;
// ServerOptions.outDevices;
Server.killAll;
s.latency = 0.5;
s.options.numOutputBusChannels = 16;
Server.default.options.outDevice = "ASIO : ReaRoute ASIO (x64)";
s.boot;

(
Server.supernova;
s.quit;
s.options.numOutputBusChannels = 16;
s.latency = 0.5;
Server.default.options.outDevice = "ASIO : ReaRoute ASIO (x64)";
s.boot;
NetAddr.langPort.postln;

if(
    Quarks.installed.collect(_.name).includes("atk-sc3").not,  // not installed
    {
        // Install ATK Quark
        Quarks.install("https://github.com/ambisonictoolkit/atk-sc3.git");
        "ATK Quark installed. Please recompile the class library and rerun this code.".postln;
    }
);

// BinauralDecoderCIPIC.new(hoaOrder:3);
// s.freeAll;
)
(
~continuous.do { |synth| synth.free };
~continuous = ();
~maxAmp = 1;
)

(
// Synth definition for continuous particles
SynthDef(\continuousParticle, {
	arg id, freq=440, harm=1, amp=0.1, gate=1, azim=0, elev=0;
    var sig, env, hoa;
	env = EnvGen.kr(Env.asr(0.01, 1, 0.5), gate, doneAction:2);
    sig = 0;

	(1..10).do { |i|
		sig = sig + SinOsc.ar(freq * i, 0, amp * (-1.0*(i-1)/harm).exp);
    };

	sig = sig * 0.5;
	sig = FreeVerb.ar(sig, 0.3, 1.0, 0.1);
/*
	hoa = HoaEncodeDirection.ar(sig, azim, elev, 1.5, AtkHoa.defaultOrder);*/

	hoa = sig;

	Out.ar(0, hoa);
}).add;
)

(
SynthDef(\collisionParticle, { |freq=440, harm=1, amp=0.5, azim=0, elev=0|
    var sig, env, hoa;
	env = EnvGen.kr(
		Env.perc(0.01, 1.0/harm, 1.0, -4)
);
    sig = 0;
	(1..10).do { |i|
		sig = sig + SinOsc.ar(freq * i, 0, amp * (-1.0*(i-1)/harm).exp);
    };

    sig = sig * env * amp;
	sig = FreeVerb.ar(sig, 0.3, 0.5, 0.1);

	hoa = HoaEncodeDirection.ar(sig, azim, elev, 1.5, AtkHoa.defaultOrder);


	DetectSilence.ar(sig, doneAction: 2);
    Out.ar(0, hoa);
}).add;
)


// OSC responder for continuous particles
(
OSCdef(\continuous, {
    arg msg, time, addr, recvPort;
    var id, azim, elev, dist, size, speed;
    var freq, harm, amp;

	#id, azim, elev, dist, size, speed = msg[1..6];

	freq = speed.linexp(1, 50, 100, 2000);
    harm = size.linexp(0.1, 20, 10, 0.5);

	amp = ~maxAmp / max(1, dist/10.0);
	amp = amp / 2.0;

	if(~continuous[id].notNil) {
        ~continuous[id].set(\freq, freq, \amp, amp, \azim, azim, \elev, elev);
    } {
        ~continuous[id] = Synth(\continuousParticle, [\id: id, \freq: freq, \harm: harm, \amp: amp, \azim: azim, \elev: elev]);
    };
}, '/continuous');
)

(
OSCdef(\continuousRemoved, {
    arg msg, time, addr, recvPort;
    var id = msg[1];
	~continuous[id].set(\gate, 0);
	~continuous.removeAt(id);
	}, '/rm_continuous');
)

// OSC responder for collision2 particles
(
OSCdef(\collision, {
    arg msg, time, addr, recvPort;
    var id, azim, elev, dist, size, speed;
	var freq, harm, amp;

	#id, azim, elev, dist, size, speed = msg[1..6];


	freq = speed.linexp(1, 50, 100, 2000);
    harm = size.linexp(0.1, 20, 10, 0.5);

	amp = ~maxAmp / max(1, dist/10.0);

	Synth(\collisionParticle, [\freq: freq, \harm: harm, \amp: amp, \azim: azim, \elev: elev]);
}, '/collision');
)

(
OSCdef(\clearAll, {
	arg msg, time, addr, recvPort;

	~continuous.do { |synth| synth.set(\gate, 0) };
	~continuous.do { |synth| synth.free };
	~continuous = ();
}, '/clear');
)