s=Server.local.boot;
s.meter(2, 8);
s.options.outDevice = "Fireface UFX (23323293)"';
Server.local.options.numOutputBusChannels = 8;
s.reboot;

/* Multichannel Expansion */

//Explicit multichannel expansion

//Mono output to bus 0
x = {SinOsc.ar}.play;
x.free;

//Stereo output to busses 0-1
x = {SinOsc.ar.dup(2)}.play;
//or
x = {SinOsc.ar!2}.play;
//8-channels (but maybe not all will be heard)
x = {SinOsc.ar!8}.play;

//Implicit multichannel expansion

x = {SinOsc.ar([60.midicps, 64.midicps], mul: 0.5)}.play;

//Arrays of parameters -> arrays of Ugens

(
x = {
	var sig, env, trig;

	trig = Impulse.kr(freq: [2, 3]); //trig is an array of 2 impulses, so...
	env = EnvGen.kr(Env.perc(releaseTime: 0.2),gate: trig); //2 envs
	sig = SinOsc.ar(freq: [60, 64].midicps, mul: env); //2 sines
	Out.ar(0,sig); //2 signals
}.play;
)
x.free;

//If you have multichannel audio...

(
x = {
	var sig, env, trig;

	trig = Impulse.kr(freq: [1, 2, 3, 5, 7]); //5 triggers
	env = EnvGen.kr(Env.perc(releaseTime: 0.2),gate: trig); //5 envs
	sig = SinOsc.ar(freq: [48, 55, 60, 64, 67].midicps, mul: env); //5 sines
	Out.ar(0,sig); //5 output channels
}.play;
)

x.free;

//Or use Splay to spread a multichannel array over a stereo output

(
x = {
	var sig, env, trig;

	trig = Impulse.kr(freq: [1, 2, 3, 5, 7, 11]); //6 triggers
	env = EnvGen.kr(Env.perc(releaseTime: 0.2),gate: trig); //6 envs
	sig = SinOsc.ar(freq: [48, 55, 60, 64, 67, 70].midicps, mul: env); //6 sines
	sig = Splay.ar(sig); //mix down to 2 channels
	Out.ar(0,sig * -3.dbamp); //stereo output, factored down
}.play;
)

x.free;

//Note that the term "multichannel" expansion isn't quite accurate here
//What SC really does is expand the number of UGens to fit the number of arguments

//Note the difference between duplicating args and duplicating UGens (see Eli's ex)
(
x = {
	var freq, sig;

	freq = LFNoise0.kr(6, mul: 200, add:400)!2; //2 copies of output of one LFNoise0
//	freq = LFNoise0.kr(6!2, mul: 200, add:400); //2 independent copies of LFNoise0
	sig = SinOsc.ar(freq, mul: 0.5);
	Out.ar(0, sig);
}.play;
)

//Eli's example of rrand:

rrand(50, 1200)!4; //4 copies of the output of one rrand
{rrand(50,1200)}!4; //4 copies of the function, hence 4 different random numbers

//Eli's example of difference between exprand and ExpRand in a synth
(
SynthDef.new(\multi, {
	var sig, amp;
	amp = SinOsc.kr(exprand(0.2, 12)!8).range(0,1); //8 copies of one random #
	sig = SinOsc.ar(exprand(50, 1200)!8);
//	amp = SinOsc.kr({exprand(0.2, 12)}!8).range(0,1); //different #'s per SynthDef
//	sig = SinOsc.ar({exprand(50, 1200)}!8);
//	amp = SinOsc.kr({ExpRand(0.2, 12)}!8).range(0,1); //different #'s per Synth
//	sig = SinOsc.ar({ExpRand(50, 1200)}!8);
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\multi);
x.free;

//Using "do" and "collect"

a = ["Hi!", 1000, 0.25, \foo]; //An array of four things
//iterate through the array with .do
a.do({arg item; item.postln}); //Send each item to a function
a.do({arg item, count; "Item number ".post; count.post; " = ".post; item.postln});

//We can also fill an array using .collect and a function
f = (0..31).collect({arg item; (item+1).reciprocal});

//or fill with random values...

f = (0..31).collect({rrand(0.01, 1.0)});

//using collect in a synthdef
(
SynthDef.new(\pseudoSaw, {
	arg fund = 200, amp = 0.5;
	var amps, freqs, sig, env;
	env = EnvGen.kr(Env.linen(attackTime: 0.5), levelScale: 0.5, doneAction: 2);
	amps = (0..31).collect({arg harm; (harm+1).reciprocal});
//	amps = (0..31).collect({rrand(0.01, 0.25)}); //random amps
	freqs = (0..31).collect({arg harm; fund*harm});
	sig = SinOsc.ar(freqs, mul: amps);
	sig = Splay.ar(sig * env);
	Out.ar(0, sig);
}).add;
)

x = Synth(\pseudoSaw);
x = Synth(\pseudoSaw, [\fund, exprand(50, 1000).round(50)]); //random harmonics
x = Synth(\pseudoSaw, [\fund, exprand(36.midicps, 36.midicps*16).round(36.midicps)]);

//Eli's iter2 example
(
SynthDef.new(\iter2, {
	arg freq=200, dev=1.02;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(0.98,1.02)
//			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(dev.reciprocal,dev) //with variable deviation
		);
		temp = temp * LFNoise1.kr({Rand(0.5,8)}!2).exprange(0.01,1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x.set(\freq, 50);
x.set(\dev, 1.15);
x.free;


