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
	arg freqls = 20.0, dbls = 0.0, rsls = 1.0, freqp = 2000.0, dbp = 0.0, rqp = 1.0, freqhs = 20000.0, dbhs = 0.0, rshs = 1.0;
	var chain;
	chain = BLowShelf.ar(PlayBuf.ar(2, 0.1), freqls, rsls, dbls, mul: 1.0, add: 0.0);
	chain = BPeakEQ.ar(chain, freqp, rqp, dbp, mul: 1.0, add: 0.0);
	chain = BHiShelf.ar(chain, freqhs, rshs, dbhs, mul: 1.0, add: 0.0);
	Out.ar(0, Pan2.ar(chain, 0.0, 1.0));
}).add;
)

//a = Synth(\equalizer, [\freqls, \dbls, \rsls, \freqp, \dbp, \rqp, \freqhs, \dbhs, \rshs])

//a.set(\freqls, 1000, \dbls, -50)


//play(s, [\out, 0, \bufnum, b])

NetAddr("192.168.1.8", 57120);

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
a = Synth(\equalizer, [\freqls, \dbls, \rsls, \freqp, \dbp, \rqp, \freqhs, \dbhs, \rshs])
OSCdef('OSCpotBass',
	{
		arg msg;

		var rsls = round(msg[1]);

		postf("rsls: % \n", rsls);
		a.set(\rsls, rsls);

	},
	"/syntien/filthyanimal/1/knob3");

OSCdef('OSChsliderBass',
	{
		arg msg;

		var freqls = msg[1];

		postf("freqls: %", freqls);
		x.set(\freqls, freqls);

	},
	"/syntien/filthyanimal/1/slider1");


OSCdef('OSCvsliderBass',
	{
		arg msg;

		var dbls = msg[1];

		postf("dbls: %", dbls);
		x.set(\dbls, dbls);

	},
	"/syntien/filthyanimal/1/slider2");
)

b.release;