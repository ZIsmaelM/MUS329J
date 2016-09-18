/* Class Notes 09-06-16 */
/*
I. Envelopes
II. Using dynamic controls
III. Additive Synthesis Examples
*/
s = Server.local.boot;
//I. See Envelope tests.scd

Env.new([0, 1, 0.9, 0], [0.1, 0.5, 1],[9, 0, -9]).plot;
Env.new(levels: [0, 0.9, 0.25, 0], times: [0.2, 0.7, 0.9], curve: \sin).plot;
Env.new(levels: [0, 0.9, 0.25, 0], times: [0.2, 0.7, 0.9], curve: \sqr).plot;
Env.new(levels: [0, 0.9, 0.25, 0], times: [0.2, 0.7, 0.9], curve: \cub).plot;
Env.new(levels: [0.001, 0.9, 0.25, 0.001], times: [0.2, 0.7, 0.9], curve: \exp).plot;

Env.pairs([[0, 0], [0.5, 0.25], [1, 1], [2, 0]], \sin).plot;

Env.sine(dur: 1, level: 1).plot; //a hanning window

Env.perc(0.05, 1, 1, -4).test.plot;
Env.perc(0.001, 1, 1, -4).test.plot;    // sharper attack
Env.perc(0.001, 1, 1, -8).test.plot;    // change curvature
Env.perc(1, 0.01, 1, 4).test.plot;    // reverse envelope

// Using an Env like an array
e = Env.pairs([[0, 0.001], [10, 1]], \exp);
e.at(5).postln;
e.at(0).postln;
e.at(10).postln;
e[7].postln;

(
SynthDef(\envtest, {
	arg dur = 1, amp = 0.125, freq = 200;
	var sig, env;

	env = EnvGen.kr(Env.perc, timeScale: dur, doneAction: 2);
	sig = SinOsc.ar(freq: freq, mul: env * amp);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;
)

x = Synth(\envtest);
x = Synth(\envtest, [\dur, 3, \freq, 400, \amp, 0.25]);
x = Synth(\envtest, [\freq, (36+36.rand).midicps]);

(
SynthDef(\adsrtest, {
	arg gate = 1, amp = 0.125, freq = 200, att = 0.1, dec = 0.5, sust = 0.25, rel = 2;
	var sig, env;

	env = EnvGen.kr(Env.adsr(attackTime: att, decayTime: dec, sustainLevel: sust, releaseTime: rel), gate: gate, doneAction: 2).poll;
	sig = SinOsc.ar(freq: freq, mul: env);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;
)

x = Synth(\adsrtest);
x = Synth(\adsrtest, [\att, 2, \dec, 1]);
x.set(\gate, 0);

//II. Using dynamic controls

//Common UGens:

//Line segment generators:
{Line.kr(start: 10, end: -10)}.plot(1) //Timed linear ramp from start to end
{XLine.kr(1, 2**10.neg)}.plot(1)  //Timed exponential curve from start to end (same sign, no zero values)
{EnvGen.kr(Env.new)}.plot(1) //Most flexible line segment generator
//Oscillating units (LFOs)
{SinOsc.kr(freq: 1, phase: pi/2)}.plot(1) //Sinusoidal LFO
{LFTri.kr(freq: 1)}.plot(1) //triangle wave LFO
{LFSaw.kr(freq: 1)}.plot(1) //sawtooth wave LFO
//Random control sources
{LFNoise0.kr(freq: 8)}.plot(1) //Non-interpolating random number generator ("Sample and Hold")
{LFNoise1.kr(freq: 8)}.plot(1) //Interpolating random number generator (linear segments)
{LFNoise2.kr(freq: 8)}.plot(1) //Quadratically interpolated random number generator (curved segments)
(
SynthDef(\gliss1, {
	arg startPit = 500, endPit = 250, glissDur = 1, noteDur = 1;
	var sig, env, freq, gate;

	gate = Trig.kr(1, dur: noteDur);
	freq = XLine.kr(startPit, endPit, glissDur);
	env = Linen.kr(gate: gate, doneAction: 2);
	sig = SinOsc.ar(freq, mul: env);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;
)

x = Synth(\gliss1, [\noteDur: 3, \glissDur: 3]);

//Simple vibrato
(
SynthDef(\vibrato, {
	arg lfoHz = 3, vibWidth = 0.01, freq = 200, noteDur = 1;
	var sig, env, vfreq, gate;

	gate = Trig.kr(1, dur: noteDur);
//	ctrl = SinOsc.kr(freq: lfoHz);
	vfreq = freq * SinOsc.kr(freq: lfoHz, mul: vibWidth, add: 1) ;
	env = Linen.kr(gate: gate, doneAction: 2);
	sig = SinOsc.ar(vfreq, mul: env);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;
)

x = Synth(\vibrato, [\lfoHz, 6, \vibWidth, 0.035]);

// Using the same control source for both vibrato and pan
(
SynthDef(\vibpan, {
	arg lfoHz = 3, vibWidth = 0.01, freq = 200, noteDur = 1;
	var sig, env, vfreq, gate, ctrl;

	gate = Trig.kr(1, dur: noteDur);
	ctrl = SinOsc.kr(freq: lfoHz);
	vfreq = freq * (1 + (ctrl * vibWidth)) ;
	env = Linen.kr(gate: gate, doneAction: 2);
	sig = SinOsc.ar(vfreq, mul: env);
	sig = Pan2.ar(sig, ctrl);
	Out.ar(0, sig);
}).add;
)

x = Synth(\vibpan, [\noteDur, 3, \lfoHz, 2, \vibWidth, 0.07, \freq, 400]);

//III. Additive Synthesis

//See SimpleChorus.csd
