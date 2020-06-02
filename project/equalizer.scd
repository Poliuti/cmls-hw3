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

	var source = WhiteNoise.ar(1.0, 0.0);         /*define audio source*/

	var bandratios = #[0.018708, 0.023605, 0.022600, 0.029477, 0.032374, 0.043147, 0.037739, 0.052607, 0.062592, 0.061173, 0.068746, 0.079751, 0.109919, 0.110754, 0.126597, 0.154050, 0.212709, 0.199884, 0.207186, 0.262644, 0.276780, 0.313258, 0.364565, 0.395140, 0.420587, 0.551271, 0.552812, 0.587294, 0.694492, 0.786524]; // percentage of the bandwidth of each of the 30 bands, obtained empirically by bandpassing a white noise and detecting the rms values
	//var bandratios = #[0.010491, 0.005893, 0.013416, 0.008332, 0.013964, 0.017303, 0.014743, 0.015876, 0.016272, 0.025574, 0.025715, 0.030873, 0.030387, 0.034044, 0.038433, 0.048961, 0.051992, 0.056505, 0.067800, 0.070920, 0.077376, 0.086487, 0.100497, 0.107927, 0.126188, 0.136852, 0.147125, 0.169054, 0.183956, 0.209569]; // percentage of the bandwidth of each of the 30 bands, obtained empirically by bandpassing a white noise and detecting the peak values

	outEq = Mix.fill(n, { |i|
		// band-pass to create bands
		var band = BPF.ar(source, round(freqInit * pow(r,i)).min(20000.0), bwcoeff, mul: gains[i], add: 0.0);
		// send peaks to meters
		var rescaledBand = (band / bandratios[i]) / n;
		SendPeakRMS.kr(rescaledBand, 10, 3, "/peaks", i);
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
	// msg[3] is rms, msg[4] is peak, the documentation is wrong
	postf("meter: % volume: % \n", msg[2], 20*log10(msg[4]));
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