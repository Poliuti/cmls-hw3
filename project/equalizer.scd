s.boot;

// LOAD FILE
(
Dialog.openPanel({ arg path;
	p = path;
},{
    "cancelled".postln;
});
)

// SynthDef EQ
(
// read a whole sound into memory
x = Buffer.read(s, p); // remember to free the buffer later.
FreqScope.new(400, 300, 0, server: s);

SynthDef(\equalizer, { |gains = #[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], pansx = #[0, 0, 0], pansy = #[0, 0, 0]|
	var n = 30, freqInit = 25, out, outEq, groupLow, groupMid, groupHigh;
	//var gain= [0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,1,0,0.000001];
	var gainLow= [1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	var gainMid= [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0];
	var gainHigh= [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1];
	var r = pow(2,4/12);
	var bwcoeff = pow(r,0.5) - 1/pow(r,0.5);
	outEq = Mix.fill(n, { |i|
		//gain[i] * BPF.ar(PlayBuf.ar(2, 0.1), freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
		BPF.ar(WhiteNoise.ar(1, 0), freqInit*pow(r,i), bwcoeff, mul: gains[i], add: 0.0)
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
	Out.ar(0, Pan4.ar(groupLow, pansx[0], pansy[0], Line.ar(mul: 0.5)));
	Out.ar(0, Pan4.ar(groupMid, pansx[1], pansy[1], Line.ar(mul: 0.5)));
	Out.ar(0, Pan4.ar(groupHigh, pansx[2], pansy[2], Line.ar(mul: 0.5)));

}).add;
)

OSCFunc.trace(true);
// ora basta
OSCFunc.trace(false) ;

NetAddr("192.168.1.107", 57120);


// O S C
(
a = Synth(\equalizer);
//GAIN osc
for(0, 29, {|i|
	OSCdef(i,
	{
		arg msg;
			var gain = pow(10,(msg [1])/20);

		postf("i: %, gain: % \n", i, gain);
		a.seti(\gains, i, gain);
	},
		"/eq/gain/" +/+ i)});


//PANx osc
for(0, 3, {|j|
	OSCdef(j,
	{
		arg msg;
		var panx = abs(msg [1]);

		postf("G: %, x: % \n", j, panx);
		a.seti(\pansx, j, panx);
	},
		"/eq/pan/" +/+ j +/+ "/x")});


//PANy osc
for(0, 3, {|k|
	OSCdef(k,
	{
		arg msg;
		var pany = msg [1];

		postf("G: %, y: % \n", k, pany);
		a.seti(\pansy, k, pany);
	},
		"/eq/pan/" +/+ k +/+ "/y")});
)