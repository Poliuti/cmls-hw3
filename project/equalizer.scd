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
FreqScope.new(400, 300, 0, server: s);

SynthDef(\equalizer, { |gains = #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], pansx = #[0, 0, 0], pansy = #[0, 0, 0]|
	var n = 30, freqInit = 25, out, outEq, groupLow, groupMid, groupHigh, outEnv, x1=1, x2=1,x3=1,y1=1,y2=1,y3=1;
	var r = pow(2,4/12);
	var bwcoeff = pow(r,0.5) - 1/pow(r,0.5);
	outEq = Mix.fill(n, { |i|
		Pan4.ar(BPF.ar(WhiteNoise.ar(1, 0.0), freqInit*pow(r,i), bwcoeff, mul: gains[i], add: 0.0), if(i<10){pansx[0]}{if(i<20){pansx[1]}{pansx[2]}}, if(i<10){pansy[0]}{if(i<20){pansy[1]}{pansy[2]}}, Line.ar(mul: 0.5));
	});

	outEnv = Array.fill(n, { |i|
		SendPeakRMS.kr(BPF.ar(WhiteNoise.ar(1, 0.0), freqInit*pow(r,i), bwcoeff, mul: gains[i], add: 0.0), 20, 3, "/replyAddress" +/+ i);
	});

	for(0, 29, {|i|
		o = OSCFunc({ |msg|
			"peak:" +/+ " %, rms" +/+ ": %".format(msg[3], msg[4]).postln
		}, "/replyAddress" +/+ i)
		});

			//o.free;
/*
	groupLow = Mix.fill(n, { |i|
		gainLow[i] * BPF.ar(outEq, freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
	});

	groupMid = Mix.fill(n, { |i|
		gainMid[i] * BPF.ar(outEq, freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
	});

	groupHigh = Mix.fill(n, { |i|
		gainHigh[i] * BPF.ar(outEq, freqInit*pow(r,i), 0.23, mul: 1.0, add: 0.0)
	});
*/
	//groupLow = BLowPass.ar(outEq, freq: 120.0, rq: 0.23, mul: 1.0, add: 0.0);

	//groupMid = BBandPass.ar(outEq, freq: 5000.0, bw: 1, mul: 1.0, add: 0.0);

	//groupHigh = BHiPass.ar(outEq, freq: 12000.0, rq: 1.0, mul: 1.0, add: 0.0);

	//Out.ar(0, Pan4.ar(groupLow, MouseX.kr(-1,1), MouseY.kr(-1,1), Line.ar(mul: 0.5)));
	//Out.ar(0, Pan4.ar(groupMid, MouseX.kr(-1,1), MouseY.kr(-1,1), Line.ar(mul: 0.5)));
	Out.ar(0, outEq);
}).add;
)

OSCFunc.trace(true);
// ora basta
OSCFunc.trace(false) ;

a = Synth(\equalizer);
a.seti(\gains, 1, 15);

(
for(0, 29, {|i|
	OSCdef(i,
	{
		arg msg;
			var gain = msg [1];

		postf("i: %, gain: % \n", i, gain);
		a.seti(\gains, i, gain);
	},
		"/eq/gain" +/+ i)});
)

(
SynthDef("help-EnvDetect",{Out.ar(0,Pan2.ar(
SinOsc.ar(440,0,0.3*EnvDetect.ar(LFNoise1.ar(20), MouseX.kr(0.001,0.1,'exponential'), MouseY.kr(0.001,0.1,'exponential')))
,0.0))
}).play
)// O S C
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
for(0, 2, {|j|
    OSCdef(j,
    {
        arg msg;
        var panx = abs(msg [1]);

        postf("G: %, x: % \n", j, panx);
        a.seti(\pansx, j, panx);
    },
        "/eq/pan/" +/+ j +/+ "/x")});




//PANy osc
for(0, 2, {|k|
    OSCdef(k,
    {
        arg msg;
        var pany = msg [1];

        postf("G: %, y: % \n", k, pany);
        a.seti(\pansy, k, pany);
    },
        "/eq/pan/" +/+ k +/+ "/y")});
)

