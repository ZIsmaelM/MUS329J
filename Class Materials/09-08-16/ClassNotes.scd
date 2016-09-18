/* September 8, 2016 */
/*
I. More on using dynamic controls
   - Scaling and mapping
   - LF Ugens (LFTri, LFSaw, LFNoise..)
   - .range and .exprange
II. More on additive synthesis
   - Risset Bell
   - Endless Glissando
*/

s = Server.local.boot;
s.plotTree;
s.meter;

/* Scaling and mapping */

//Simple synth with percussive envelope

(
SynthDef (\simple, {
	arg freq = 300, amp = 0.1, minVal = 0, maxVal = 1, gate = 1;

	var sig, env, pan = 0;

	env = EnvGen.kr(Env.perc(releaseTime: 0.01), gate: gate, levelScale: amp, doneAction: 2);

	sig = SinOsc.ar(freq, mul: env);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x = Synth(\simple);


//Convert to a self-triggering synth

(
SynthDef (\simple1, {
	arg freq = 300, amp = 0.1, minVal = 0, maxVal = 1, trigHz = 4;

	var sig, env, pan = 0, trig;

	trig = Impulse.kr(trigHz);

	env = EnvGen.kr(Env.perc(releaseTime: 0.1), gate: trig, levelScale: amp);

	sig = SinOsc.ar(freq, mul: env);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x = Synth(\simple1);
x.set(\trigHz, 10);
x.free;

//Add MouseX control over trigHz

(
SynthDef (\simple2, {
	arg freq = 300, amp = 0.1, trigHz = 4, varHz = 20;

	var sig, env, pan = 0, trig;

	trigHz = MouseX.kr(minval: trigHz, maxval: varHz);

	trig = Impulse.kr(trigHz);

	env = EnvGen.kr(Env.perc(releaseTime: 0.1), gate: trig, levelScale: amp);

	sig = SinOsc.ar(freq, mul: env);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x = Synth(\simple2);
x.free;

//Use same control source for both trigHz and pan position
(
SynthDef (\simple3, {
	arg freq = 300, amp = 0.1, minVal = 0, maxVal = 1, trigHz = 4, varHz = 20;

	var sig, env, pan = 0, trig, ctrl;

	ctrl = MouseX.kr; //Use default min and max values for MouseX (0-1)

	trigHz = ctrl * varHz + trigHz; //scale and offset for trigHz

	trig = Impulse.kr(trigHz);

	pan = ctrl * 2 - 1;  //scale and offset for pan position

	env = EnvGen.kr(Env.perc(releaseTime: 0.1), gate: trig, levelScale: amp);

	sig = SinOsc.ar(freq, mul: env);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x = Synth(\simple3);
x.free;

/* LF Ugens (designed for control, not band limited */

{LFSaw.kr(freq: 1)}.plot(1) //sawtooth wave LFO
{LFSaw.ar(mul: 0.1)}.play; //N.B., aliasing
{VarSaw.ar(width: 0.99, mul: 0.1)}.play; //no aliasing
{VarSaw.kr(freq: 0.99, width: 1)}.plot(1);
{LFTri.kr(freq: 1)}.plot(1) //triangle wave LFO
{LFTri.ar(mul: 0.1)}.play;
{LFCub.kr(freq: 1)}.plot(1) //sine-like wave LFO
{LFCub.ar(mul: 0.1)}.play;
{LFPar.kr(freq: 1)}.plot(1) //cosine-like wave LFO
{LFPar.ar(mul: 0.1)}.play; //audible odd harmonics
{SinOsc.ar(mul:0.1, phase: pi/2)}.play; //compare to SinOsc

//Vibrato with rate controlled by MouseX and width controlled by MouseY

(
SynthDef (\simple4, {
	arg freq = 300, amp = 0.1, gate = 1, minVibHz = 1, maxVibHz = 10, maxVibWidth = 0.1;

	var sig, env, pan = 0, trig, vib, vibHz, vibWidth;

	env = EnvGen.kr(Env.asr(attackTime: 1, releaseTime: 2), gate: gate, levelScale: amp, doneAction: 2);

	vibHz = MouseX.kr(minval: minVibHz, maxval: maxVibHz);
	vibWidth = MouseY.kr(maxval: maxVibWidth);

	vib = LFTri.kr(vibHz, mul: vibWidth, add: 1);

//	freq = freq * (1 + vib) ;
	freq = freq * vib;
	sig = SinOsc.ar(freq, mul: env);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x = Synth(\simple4);
x.set(\gate, 0);
x.free;

//Random control sources
{LFNoise0.kr(freq: 8)}.plot(1) //Non-interpolating random number generator ("Sample and Hold")
{LFNoise1.kr(freq: 8)}.plot(1) //Interpolating random number generator (linear segments)
{LFNoise2.kr(freq: 8)}.plot(1) //Quadratically interpolated random number generator (curved segments)

//Random pitch variation with rate controlled by MouseX and width controlled by MouseY

(
SynthDef (\simple5, {
	arg freq = 200, amp = 0.1, gate = 1, minRandHz = 2, maxRandHz = 20, maxRandRange = 2000;

	var sig, env, pan = 0, hz, randHz, randRange;

	env = EnvGen.kr(Env.asr(attackTime: 1, releaseTime: 2), gate: gate, levelScale: amp, doneAction: 2);

	randHz = MouseX.kr(minval: minRandHz, maxval: maxRandHz);
	randRange = MouseY.kr(maxval: maxRandRange);

	hz = LFNoise0.kr(randHz).exprange(freq, randRange).poll;
//	hz = LFNoise1.kr(randHz).exprange(freq, randRange);
//	hz = LFNoise2.kr(randHz).exprange(freq, randRange);

	sig = SinOsc.ar(hz, mul: env); //try adding .lag to hz
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x = Synth(\simple5);
x.set(\gate, 0);
x.release;


// Synth that generates random pitches that are harmonically related to a fundamental
// The lower the pitch, the more partials generated with the Blip Ugen

(
SynthDef(\EnvPan, { arg pan = 0.25, fundMIDI = 24;
	var env, sig, freq, nharm;
//pick a random harmonic between the 1st and 16th partial at start of each note
	freq = ExpRand(fundMIDI.midicps,fundMIDI.midicps*16).round(fundMIDI.midicps);
//correct the pitch
	freq = freq.cpsmidi.round.midicps; //round out of tune harmonics to well-tempered notes
//number of harmonics is inversely related to the pitch (higher pitches have fewer harmonics)
	nharm = 18 - (freq/(fundMIDI.midicps)); //at least 2 (18-16) harmonics on the highest notes
//length of decay is related to the number of harmonics: lower pitch, more harmonics, longer decay
	env = EnvGen.kr(Env.perc(releaseTime: 0.25 * nharm, level: 0.5, curve:-7), doneAction: 2);
//Blip generates a set of harmonic partials
	sig = Blip.ar(freq: freq, numharm: nharm, mul: env);
	Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

x = Synth(\EnvPan);
x = Synth(\EnvPan, [\pan, 1.0.rand2]); //random pan position between -1 and +1

// Create a lookup table for pan position with Env

p = Env.pairs([[0, -1], [1, 1]],curve: \sin); //an s-shape function
p.plot;

x = Synth(\EnvPan, [\pan, p.at(1.0.rand)]); //random pan position, 0/1 -> -1/1,  favors extremes

/* II - Additive Synthesis examples */

//See RissetBellFlowchart.pdf and RissetBell.scd
//See EndlessFlowchart.pdf and EndlessGlissando.scd