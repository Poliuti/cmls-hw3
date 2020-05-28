s.boot;

(
Dialog.openPanel({ arg path;
	p = path;
},{
    "cancelled".postln;
});
)

/*
(
// read a whole sound into memory
b = Buffer.read(s, p); // remember to free the buffer later.

SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0 |
    Out.ar(out,
        PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction: Done.freeSelf)
    )
}).play(s, [\out, 0, \bufnum, b]);
)



{HPF.ar(PlayBuf.ar(2,0.1), freq: 440.0, mul: 1.0, add: 0.0)}.play;

{BPF.ar(PlayBuf.ar(2,0.1), freq: 8080.0, rq: 0.2, mul: 1.0, add: 0.0)}.play;
// rq = (bandwidth / cutoffFreq).

{LPF.ar(PlayBuf.ar(2,0.1), 440.0, 1.0, 0.0)}.play;
*/

(
// read a whole sound into memory
b = Buffer.read(s, p); // remember to free the buffer later.

SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0 |
    Out.ar(out,
		LPF.ar(PlayBuf.ar(2,0.1), 440.0, 1.0, 0.0)
    )
}).play(s, [\out, 0, \bufnum, b]);
)
