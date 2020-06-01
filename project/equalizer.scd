
s.boot;

// LOAD FILE
(
Dialog.openPanel({
	arg path;
	~p = path;
},{
    "cancelled".postln;
});
)

// SynthDef EQ
(
// read a whole sound into memory
//x = Buffer.read(s, ~p); // remember to free the buffer later.
FreqScope.new(400, 300, 0, server: s);

SynthDef(\equalizer, {
	|
	gains = #[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	pansx = #[0, 0, 0],
	pansy = #[0, 0, 0]
	|

    var n = 30, freqInit = 25, out = 0, outEq, outEnv;
    var r = pow(2,4/12);
    var bwcoeff = pow(r,0.5) - 1/pow(r,0.5);

	outEq = Mix.fill(n, { |i|
        Pan4.ar(
			BPF.ar(
				WhiteNoise.ar(1, 0.0), freqInit*pow(r,i), bwcoeff, mul: gains[i], add: 0.0
			),
			if(i < 10, pansx[0], if(i<20, pansx[1], pansx[2])),
			if(i < 10, pansy[0], if(i<20, pansy[1], pansy[2])),
			Line.ar(mul: 0.5)
		);
    });

	for(0, 29, { |i|
		SendPeakRMS.kr(BPF.ar(WhiteNoise.ar(1, 0.0), freqInit*pow(r,i), bwcoeff, mul: gains[i], add: 0.0), 2, 3, "/peaks", i);
	});

    Out.ar(out, outEq);

}).add;
)

// O S C
(
a = Synth(\equalizer);

~remote = NetAddr("localhost", 12000);

p = OSCFunc({ |msg|
	~remote.sendMsg("/gui/volumes" +/+ msg[2], 20*log(10, msg[4]));
}, '/peaks');

//GAIN osc
for(0, 29, {|i|
	OSCdef('gain' + i,
	{
        arg msg, addr;
        var gain = pow(10,(msg[1])/20);

        //~remote = addr;

        postf("i: %, gain: % \n", i, gain);
        a.seti(\gains, i, gain);
    },
	"/eq/gain/" +/+ i)
});

//PANxy osc
for(0, 2, {|j|
	OSCdef('pan' + j,
    {
        arg msg, addr;
        var panx = msg[1];
		var pany = msg[2];

		//~remote = addr;

        postf("G: %, x: %, y: %\n", j, panx, pany);
        a.seti(\pansx, j, panx);
		a.seti(\pansy, j, pany);
    },
	"/eq/pan/" +/+ j)
});

)

a.free;

OSCFunc.trace(true);
// ora basta
OSCFunc.trace(false) ;
