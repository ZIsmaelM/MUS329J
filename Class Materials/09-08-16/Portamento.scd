//Portamento
SynthDef(\test,
	{
		arg freq = 440;
		var sig = SinOsc.ar(freq.lag(1), mul: 0.1);
		Out.ar(0, sig);
	}
).add;

x = Synth(\test);
x.set(\freq, 1000)