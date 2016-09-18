s.boot;
s.meter(2,8);

//
x = {SinOsc.ar([60.midicps, 64.midicps], mul: 0.5)}.play;
//


//
(
x = {
	var sig, env, trig;
	trig = Impulse.kr(freq: [2,3]);
	env = EnvGen.kr(Env.perc(releaseTime:0.2), gate: trig);
	sig = SinOsc.ar(freq: [60,64].midicps, mul:env);
	Out.ar(0, sig);
}.play;
)

x.free;
//


//
{rrand(50,1200)}!4;
//


//
a = ["Hi!", 1000, 0.25, \foo];
a.do({arg item; item.postln});
//


//
f = (0..31).collect({arg item; (item+1).reciprocal});
//