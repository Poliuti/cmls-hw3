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
	arg freqInit = 25, freq;
	var out, outEq, n = 30;
	var gain= [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0000001];
	var r = pow(2,4/12);
	//var bwcoeff = pow(r,0.5) - 1/pow(r,0.5)//=0.23;

	outEq = Mix.fill(n, { |i|
		//gain[i] * BBandPass.ar(WhiteNoise.ar(2, 0.1), freqInit*pow(r,i), 5, mul: 1.0, add: 0.0)
			//gain[i] * BBandPass.ar(WhiteNoise.ar(1.0, 0.0), freqInit*pow(r,i), (sqrt(r) - 1/sqrt(r))*freqInit*pow(r,i), mul: 1.0, add: 0.0)
		gain[i] * BPF.ar(WhiteNoise.ar(2, 0.1), freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
	});
	//(pow(r,0.5) - 1/pow(r,0.5))*freqInit*pow(r,i)

	Out.ar(0, Pan2.ar(outEq, 0.0, 1.0));
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

		var gain = (msg[1]);

		postf("gain: % \n", gain);
		a.set(\gain, gain);

	},
	"/oscControl/gain");

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