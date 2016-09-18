/* Risset Bell Instrument from Dodge p.105 */

//Decay function is from 1 to 2^-10

Env.pairs([[0,1], [20,2**10.neg]],curve: \exp).plot;

(
SynthDef(\rissetBell, {
	arg freq = 200, peakAmp = 0.25;
	var env, sig;

	Line.kr(dur: 20, doneAction: 2); //simply extends execution for 20 seconds, then frees
	env = EnvGen.kr(Env.pairs([[0,1], [20,2**10.neg]],curve: \exp),
		timeScale: [1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075],
		levelScale: [1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33],
		doneAction: 0); //done action of 2 would free synth after shortest envelope
	sig = Splay.ar(SinOsc.ar(
		freq: [freq * 0.56, freq * 0.56 + 1, freq * 0.92, freq * 0.92 + 1.7, freq * 1.19,
			freq * 1.7, freq * 2, freq * 2.74, freq * 3, freq * 3.76, freq * 4.07],
		mul: env));
	Out.ar(0,sig*peakAmp);
}).add;
)

x = Synth(\rissetBell);
x = Synth(\rissetBell, [\freq, 300]);
x = Synth(\rissetBell, [\freq, 150 + 450.rand]);

