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
	var n = 30, out, outEq, groupLow, groupMid, groupHigh;
	var gain= [0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0.000001];
	var gainLow= [1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	var gainMid= [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0];
	var gainHigh= [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1];
	var r = pow(2,4/12);
	var bwcoeff = pow(r,0.5) - 1/pow(r,0.5);
	outEq = Mix.fill(n, { |i|
		//gain[i] * BPF.ar(PlayBuf.ar(2, 0.1), freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
		BPF.ar(WhiteNoise.ar(1, 0), freqInit*pow(r,i), 0.23, mul: gain[i], add: 0.0)
	});


	groupLow = Mix.fill(n, { |i|
		gainLow[i] * BPF.ar(outEq, freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
	});

	groupMid = Mix.fill(n, { |i|
		gainMid[i] * BPF.ar(outEq, freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
	});

	groupHigh = Mix.fill(n, { |i|
		gainHigh[i] * BPF.ar(outEq, freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
	});
	/*
	groupLow = BHiPass4(outEq, freq: 3000.0, rq: 0.23, mul: 1.0, add: 0.0);

	groupMid = BBandPass(outEq, freq: 10000.0, bw: 1.0, mul: 1.0, add: 0.0);

	groupHigh = BLowPass4(outEq, freq: 10000.0, rq: 1.0, mul: 1.0, add: 0.0);
	*/
	Out.ar(0, Pan4.ar(groupLow, MouseX.kr(-1,1), MouseY.kr(-1,1), Line.ar(mul: 0.5)));
	Out.ar(0, Pan4.ar(groupMid, MouseX.kr(-1,1), MouseY.kr(-1,1), Line.ar(mul: 0.5)));
	Out.ar(0, Pan4.ar(groupHigh, MouseX.kr(-1,1), MouseY.kr(-1,1), Line.ar(mul: 0.5)));

}).add;
)

OSCFunc.trace(true);
// ora basta
OSCFunc.trace(false) ;

NetAddr("192.168.1.107", 57120);

(
a = Synth(\equalizer);

OSCdef('OSCgain'+/+ 1,
	{
		arg msg;

		var gain = (msg[1]);

		postf("gain: % \n", gain);
		a.set(\gain, gain);

	},
		"/eq/" +/+ i +/+ "/gain");

b.release;