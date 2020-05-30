s.boot;

// LOAD FILE
(
Dialog.openPanel({ arg path;
	p = path;
},{
    "cancelled".postln;
});
)

//PLAY FILE (+ start EQ)
(
// read a whole sound into memory
x = Buffer.read(s, p); // remember to free the buffer later.

SynthDef(\equalizer, {
	arg freqInit = 25, freq, gain;
	var out, outEq;

	outEq = Mix.fill(n, { |i|
		BBandPass.ar(PlayBuf.ar(2, 0.1), freqInit*pow(2,i*4/12), bw: 1.0, mul: 1.0, add: 0.0)
	});
	out = PlayBuf.ar(2, 0.1) + outEq;
	Out.ar(0, Pan2.ar(out, 0.0, 1.0));
}).add;
)
//play(s, [\out, 0, \bufnum, b])

NetAddr("192.168.1.107", 57120);

(
/*OSCdef('OSCmotion',
	{
		arg msg;
		//var pan = -msg[3];
		// all the messages should stay between + - pi ( in practice not really)
		var note = round(((msg[1] + 1.5) / (3)) * 100);  //roll (rotation on x axis)

		var detune = msg[3];     //yaw (rotation on z axis)

		postf("detune: %, note: % \n", detune, note);
		x.set(\note, note,\detune,detune);

	},
	"/syntien/filthyanimal/1/scope1");
*/
a = Synth(\equalizer);


OSCdef('OSCpotBass',
	{
		arg msg;

		var rsls = round(msg[1]);

		postf("rsls: % \n", rsls);
		a.set(\rsls, rsls);

	},
	"/oscControl/");

OSCdef('OSChsliderBass',
	{
		arg msg;

		var freqls = msg[1];

		postf("freqls: % \n", freqls);
		a.set(\freqls, freqls);

	},
	"/oscControl/freqls");


OSCdef('OSCvsliderBass',
	{
		arg msg;

		var dbls = msg[1];

		postf("dbls: % \n", dbls);
		a.set(\dbls, dbls);

	},
	"/oscControl/dbls");
)

b.release;