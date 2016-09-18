s.boot;
s.scope;

/* Linen Tests */

// triggered
(
SynthDef(\LinenTest, {
	arg out = 0, rate = 2, rise = 0.01, sus = 0.6, decay = 1.0;
    Out.ar(out,
        Linen.kr(Impulse.kr(rate), rise, sus, decay, doneAction: 0) * SinOsc.ar(440, 0, 0.1)
    )
}).add;
)
x = Synth(\LinenTest);
x.set(\rise, 0.1);
x.set(\decay, 0.01);
x.set(\rate, 0.5);
x.set(\sus, 4.0);
x.free;

// gated

(
SynthDef(\LinenTest1, {
	arg out = 0, rate = 2, rise = 0.01, sus = 0.6, dur = 0.1, decay = 1.0;
	var gate, trig;
	trig = Impulse.kr(rate);
	gate = Trig.kr(trig, dur);
    Out.ar(out,
        Linen.kr(gate, rise, sus, decay, doneAction: 0) * SinOsc.ar(440, 0, 0.1)
    )
}).add;
)

x = Synth(\LinenTest1);
x.set(\rise, 0.1);
x.set(\decay, 0.01);
x.set(\rate, 0.45);
x.set(\dur, 1);
x.free;

/* Decay Tests */

(
x = { arg out = 0, rate = 2, decay = 1;
	var trig;
	trig = Impulse.kr(rate);
	Out.ar(out,
		SinOsc.ar(440, 0, mul: Decay.kr(trig, decay, 0.1))
    )
}.play;
)
x.set(\rate, 16);
x.set(\decay, 0.25);
x.free;

/* Decay2 Tests */

(
x = { arg out = 0, rate = 2, attack = 0.01, decay = 1;
	var trig;
	trig = Impulse.kr(rate);
	Out.ar(out,
		SinOsc.ar(440, 0, mul: Decay2.kr(trig, attack, decay, 0.1))
    )
}.play;
)
x.set(\rate, 0.5);
x.set(\attack, 0.7); //can't be as long as the decay
x.set(\decay, 2);
x.free;

/* EnvGen Tests */

//EnvGen.ar (envelope, gate: 1, levelScale: 1, levelBias: 0, timeScale: 1, doneAction: 0)

//Use Env to create the envelope

//Env([levels],[times],[curve],releaseNode,loopNode)

//Try various curve settings
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1]).plot //default curve is \lin
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: \step).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: \hold).plot
Env.new(levels: [0.001,1,0.5,0.001],times: [0.25, 0.5, 1], curve: \exponential).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: \sine).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: \welch).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: \squared).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: \cubed).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: 0.1).plot //slow, then fast change
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: 0.5).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: 1).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: 2).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: 3).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: 5).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: -0.1).plot //fast, then slow change
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: -0.5).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: -1).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: -2).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: -3).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: -5).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: [5,-2,-5] ).plot
Env.new(levels: [0,1,0.5,0],times: [0.25, 0.5, 1], curve: [\lin,\sin,\sin] ).plot

//Predefined shapes

Env.linen.plot
Env.triangle.plot
Env.sine.plot //an inverted, offset cosine, actually (hanning window)
Env.perc.plot
Env.pairs([[0,0],[0.25,1],[0.75,0.5],[2,0]],\lin).plot
Env.pairs([[0,0],[0.25,1],[0.75,0.5],[2,0]],\sin).plot
Env.pairs([[0,0.001],[0.25,1],[0.75,0.5],[2,0.001]],\exp).plot
Env.xyc([[0,0,\sin],[0.25,1,\exp],[0.75,0.5,\exp],[2,0.001]]).plot //curve applies to next point
Env.asr.plot
Env.adsr.plot
Env.dadsr.plot
Env.cutoff.plot //starts at one, then fades out

e = Env.adsr(attackTime: 0.01, decayTime: 0.24, sustainLevel: 0.5, releaseTime: 2, curve: \sin);

e.plot; //plot the envelope shape
e.test; //play test tone on server with this env

// We can also access the values at various time points like this:
e.at(0.01); //level at time 0.01
e.at(0.01 + 0.24); //level at time 0.25
e[1.25]; //alternate syntax - halfway through the release

// So we can use an Env as a stored function:
e = Env.perc(releaseTime: 5, curve: 0);
e.at(0);
e.at(3);
e.at(5);
e.at(5.01);

(
p = Env.pairs([[0, -1], [1, 1]],curve: \sin); //an s-shape function
p.plot;

SynthDef(\EnvPan, { arg pan = 0.25, fundMIDI = 24;
	var env, sig, freq, nharm;
	freq = ExpRand(fundMIDI.midicps,fundMIDI.midicps*16).round(fundMIDI.midicps);
	freq = freq.cpsmidi.round.midicps; //round out of tune harmonics to well-tempered notes
	nharm = 18 - (freq/(fundMIDI.midicps)); //at least 2 (18-16) harmonics on the highest notes
	env = EnvGen.kr(Env.perc(releaseTime: 0.25 * nharm, level: 0.5, curve:-7), doneAction: 2);
	sig = Blip.ar(freq: freq, numharm: nharm, mul: env);

	Out.ar(0, LinPan2.ar(sig,pan));
}).add;
)

x = Synth(\EnvPan);
x = Synth(\EnvPan, [\pan, p.at(1.0.rand)]); //random pan position


//Can also use Env directly in a Synth, using the .kr and .ar methods
(
x = {
	SinOsc.ar * Env.perc.kr;
}.play;
)
x.free; //no done action parameter, so need to free manually