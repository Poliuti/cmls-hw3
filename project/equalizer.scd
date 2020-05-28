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
(
var freqls=20000.0, freqhs = 20.0, freqp = 2000.0;
// read a whole sound into memory
x = Buffer.read(s, p); // remember to free the buffer later.

SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0 |
	out = Mix(
		BPeakEQ.ar(PlayBuf.ar(2,0.1), freqp, rq: 10.0, db:0.0, mul: 1.0, add: 0.0);
		BLowShelf.ar(PlayBuf.ar(2,0.1), freqls, rs: 1.0, db:-50.0, mul: 1.0, add: 0.0);
		BHiShelf.ar(PlayBuf.ar(2,0.1), freqhs, rs: 1.0, db:0.0, mul: 1.0, add: 0.0);

	)

    Out.ar(0, Pan2.ar(out,0));

    )
}).play(s, [\out, 0, \bufnum, b]);
)




x.set(\freqls, 5.0);

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
OSCdef('OSCpotBass',
	{
		arg msg;

		var q = round(msg[1]);

		postf("q: % \n", q);
		x.set(\q, q);

	},
	"/syntien/filthyanimal/1/knob3");

OSCdef('OSChsliderBass',
	{
		arg msg;

		var fre = msg[1];

		postf("fre: %", fre);
		x.set(\fre, fre);

	},
	"/syntien/filthyanimal/1/slider1");
)

OSCdef('OSCvsliderBass',
	{
		arg msg;

		var amp = msg[1];

		postf("amp: %", amp);
		x.set(\amp, amp);

	},
	"/syntien/filthyanimal/1/slider2");
)

b.release;