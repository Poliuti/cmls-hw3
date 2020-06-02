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

// Synth definition for the equalizer
(
// read a whole sound into memory
x = Buffer.read(s, ~p); // remember to free the buffer later.
FreqScope.new(400, 300, 0, server: s);


SynthDef(\equalizer, {
	|
	gains = #[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],   /*An array of gains for 30 eq bands*/
	pansx = #[0, 0, 0],                           /*An array of x coordinates for Low-Mid-High groups*/
	pansy = #[0, 0, 0]                            /*An array of y coordinates for Low-Mid-High groups*/
	|

    var n = 30,                                   /*num of eq bands*/
	freqInit = 25.0,                              /*initial frequency*/
	out = 0,                                      /*output buffer*/
	outEq;
	var r = pow(2,4/12);                          /*R coefficient*/
	var bwcoeff = (pow(r,0.5) - 1/pow(r,0.5));    /*bandwidth coefficient*/

	var source = WhiteNoise.ar(1.0, 0.0);           /*define audio source*/

	outEq = Mix.fill(n, { |i|
		// band-pass to create bands
		var band = BPF.ar(source, round(freqInit * pow(r,i)).min(20000.0), bwcoeff, mul: gains[i], add: 0.0);
		// send peaks to meters
		SendPeakRMS.kr(band, 10, 3, "/peaks", i);
		// apply quadraphonic panning
        Pan4.ar(band,
			if(i < 10, pansx[0], if(i<20, pansx[1], pansx[2])),
			if(i < 10, pansy[0], if(i<20, pansy[1], pansy[2])),
			Line.ar(mul: 0.5)
		);
    });

    Out.ar(out, outEq);

}).add;
)

// PLAY the synth and define OSC messages
(
a = Synth(\equalizer);

~remote = NetAddr("localhost", 12000);

//Send volumes to GUI meters through OSC
OSCdef('peaks', { |msg|
	//postf("meter: % volume: % \n", msg[2], 20*log10(msg[4]));
	~remote.sendMsg("/gui/volumes" +/+ msg[2], 20*log10(msg[4]));
}, '/peaks');

//Receive gain settings from the GUI through OSC
for(0, 29, {|i|
	OSCdef("gain" + i,
	{
        arg msg, addr;
        var gain = pow(10,(msg[1])/20);

        //~remote = addr;

        postf("i: %, gain: % \n", i, gain);
        a.seti(\gains, i, gain);
    },
	"/eq/gain/" +/+ i)
});

//Receive Low-Mid-High coordinates from the GUI through OSC
for(0, 2, {|j|
	OSCdef("pan" + j,
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

//STOP and free buffers
(
a.stop;
a.free;
)