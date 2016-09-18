//Simple Chorus (heterodyning)

(
SynthDef(\chorus, {
	arg freq = 200, detune = 1, gate = 1, amp = 0.25;
	var env, sig, sig1, sig2;

	env = EnvGen.kr(Env.adsr, gate, levelScale: amp, doneAction: 2);
	sig1 = SinOsc.ar(freq, pi/2, mul: env);
	sig2 = SinOsc.ar(freq+detune, pi2/2, mul: env);

	sig = Splay.ar([sig1, sig2]);
	Out.ar(0, sig);
	}).add;
)

//alternatively...

(
SynthDef(\chorus1, {
	arg freq = 200, detune = 1, gate = 1, amp = 0.25;
	var env, sig;

	env = EnvGen.kr(Env.adsr, gate, levelScale: amp, doneAction: 2);
	sig = SinOsc.ar([freq, freq+detune], pi/2, mul: env);
	sig = Splay.ar(sig);
	Out.ar(0, sig);
	}).add;
)

//and proving the trigonmetric identity (cosA + cosB = 2 * cos(A+B/2) * cos(A-B/2):

(
SynthDef(\chorus2, {
	arg freq = 200, detune = 1, gate = 1, amp = 0.25;
	var env, sig, freqA = freq, freqB = freq + detune;

	env = EnvGen.kr(Env.adsr, gate, levelScale: amp, doneAction: 2);
	sig = 2.0 * SinOsc.ar((freqA + freqB)/2) *
	            SinOsc.ar((freqA - freqB)/2);
	sig = sig * env;
	sig = Pan2.ar(sig);
	Out.ar(0, sig);
	}).add;
)

x = Synth(\chorus);
x.set(\freq, 60.midicps);
x.set(\detune, 2);
x.set(\detune, 3);
x.set(\detune, 5);
x.release;
x.set(\gate, 0);

x = Synth(\chorus1);
x.set(\freq, 60.midicps);
x.set(\detune, 2);
x.set(\detune, 3);
x.set(\detune, 5);
x.release;
x.set(\gate, 0);

y = Synth(\chorus2);
y.set(\freq, 60.midicps);
y.set(\detune, 3);
y.release;