
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
//x = Buffer.read(s, p); // remember to free the buffer later.
FreqScope.new(400, 300, 0, server: s);
SynthDef(\equalizer, { |gains = #[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], pansx = #[0, 0, 0], pansy = #[0, 0, 0]|
    var n = 30, freqInit = 25, out = 0, outEq, outEnv;
    var r = pow(2,4/12);
    var bwcoeff = pow(r,0.5) - 1/pow(r,0.5);

	outEq = Mix.fill(n, { |i|
        Pan4.ar(BPF.ar(WhiteNoise.ar(1, 0.0), freqInit*pow(r,i), bwcoeff, mul: gains[i], add: 0.0), if(i<10){pansx[0]}{if(i<20){pansx[1]}{pansx[2]}}, if(i<10){pansy[0]}{if(i<20){pansy[1]}{pansy[2]}}, Line.ar(mul: 0.5));
    });

 //(PlayBuf.ar(2, 0.1)
/*
    outEnv = Array.fill(n, { |i|
        SendPeakRMS.kr(BPF.ar(WhiteNoise.ar(1, 0.0), freqInit*pow(r,i), bwcoeff, mul: gains[i], add: 0.0), 20, 3, "/replyAddress" +/+ i);
    });


    for(0, 29, {|i|
        o = OSCFunc({ |msg|
            "peak:" +/+ " %, rms" +/+ ": %".format(msg[3], msg[4]).postln
        }, "/replyAddress" +/+ i)
        });
*/
//o.free;
    Out.ar(out, outEq);
}).add;
)

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



//PANxy osc
for(0, 2, {|j|
    OSCdef(j,
    {
        arg msg;
        var panx = msg [1];
		var pany = msg [2];

        postf("G: %, x: %, y: %\n", j, panx, pany);
        a.seti(\pansx, j, panx);
		a.seti(\pansy, j, pany);
    },
        "/eq/pan/" +/+ j)});
)



OSCFunc.trace(true);
// ora basta
OSCFunc.trace(false) ;

NetAddr("192.168.1.107", 57120);
