s = Server.local.boot;
s.plotTree;
s.meter(2,8);

/* Using control busses */

//Make a control synth

//first, get the next available control bus into a global variable

~ctrlBus1 = Bus.control;
~ctrlBus1.free; //You can free it, once you've created it, but don't right now...

//define the synth that will output to a control bus
(
SynthDef(\vib, {
	arg outBus, vibRate = 6, vibWidth = 0.02, vibDel = 1, vibRise = 1, vibDecay = 1, gate = 1;
	var vibEnv, vibSig;

	vibEnv = EnvGen.kr(Env.dadsr(vibDel, vibRise, vibDecay, sustainLevel: 1, curve: 0),gate: gate, doneAction: 2);
	vibSig = LFTri.kr(vibRate, mul: vibWidth * vibEnv);
	Out.kr(outBus, vibSig); //N.B., .kr and not a hardware output
}).add;
)

//Make a simple synth to be controlled

(
SynthDef(\tone, {
	arg inBus, freq = 100, amp = 0.5, gate = 1, pan = 0;
	var env, sig, vib;

	vib = 1 + In.kr(inBus); //apply the control signal
	env = EnvGen.kr(Env.asr(attackTime: 0.5),gate: gate, doneAction: 2);
	sig = Blip.ar(freq * vib, numharm: 4, mul: env * amp);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x = Synth(\tone, [\pan, -1, \inBus, ~ctrlBus1]);
y = Synth(\tone, [\inBus, ~ctrlBus1, \freq, 200, \pan, 1]);
v = Synth(\vib, [\outBus, ~ctrlBus1, \vibWidth, 0.03, \vibRise, 2]);

v.set(\gate, 0);
x.set(\gate, 0); y.set(\gate, 0);

//each new synth will be added at the head of the execution chain by default
v = Synth(\vib, [\outBus, ~ctrlBus1, \vibWidth, 0.03, \vibRise, 2]);
x = Synth(\tone, [\pan, -1], addAction: \addToTail);
y = Synth(\tone, [\inBus, ~ctrlBus1, \freq, 200, \pan, 1], addAction: \addToTail);
v.set(\gate, 0);
x.set(\gate, 0); y.set(\gate, 0);

//Make another control synth for overall level control

~ctrlBus2 = Bus.control; //get next available control bus

(
SynthDef(\fadeout, {
	arg outBus, release = 8, gate = 1;
	var env;
//use the cutoff envelope shape for a general fadeout
	env = EnvGen.kr(Env.cutoff(releaseTime: release, curve: -5), gate: gate, doneAction: 2);
	Out.kr(outBus, env);
}).add;
)

//Modify synth to respond to overall envelope control

(
SynthDef(\tone1, {
	arg inBus1, inBus2, freq = 200, amp = 0.25, gate = 1, rhz = 4, pan = 0, nh = 5;
	var env, sig, vib, vamp, vhz;

	vhz = freq * LFNoise0.kr(rhz).range(1, 4).round;
	vib = 1 + In.kr(inBus1); //apply vibrato
	vamp = amp * In.kr(inBus2); //apply final fade
	env = EnvGen.kr(Env.asr(attackTime: 0.5),gate: gate, doneAction: 2);
	sig = Blip.ar(vhz * vib, numharm: nh, mul: env * vamp);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

//add the fadeout synth first!
f = Synth(\fadeout, [\outBus, ~ctrlBus2]);
x = Synth(\tone1, [\inBus1, ~ctrlBus1, \inBus2, ~ctrlBus2, \pan, -1, \freq, 36.midicps], addAction: \addToTail);
y = Synth(\tone1, [\inBus1, ~ctrlBus1, \inBus2, ~ctrlBus2, \freq, 43.midicps, \rhz, 5, \pan, 1], addAction: \addToTail);
z = Synth(\tone1, [\inBus1, ~ctrlBus1, \inBus2, ~ctrlBus2, \freq, 52.midicps, \rhz, 6], addAction: \addToTail);
v = Synth(\vib, [\outBus, ~ctrlBus1, \vibRate, 0.0625, \vibWidth, 0.125]); //add slow vib
v.set(\vibWidth, 0.5); //wider!
v.set(\vibRate, 0.125);
v.set(\vibWidth, 0.03125, \vibRate, 4); //less wide, but faster
v.set(\gate, 0); //stop the vib
f.set(\gate, 0); //fade everyone out
x.set(\gate, 0); y.set(\gate, 0); z.set(\gate, 0);

s.freeAll; //free everything at once


/* Using audio busses for signal routing */

~fxBus1 = Bus.audio;

//Make a simple reverb synth

(
SynthDef(\monoverb, {
	arg inBus, wet = 0.33, roomsize = 0.5, damping = 0.5;
	var insig, sig;

	insig = In.ar(inBus);
	sig = FreeVerb.ar(insig, mix: wet, room: roomsize, damp: damping)!2;
	Out.ar(0, sig);
}).add;
)

//Make a simple test instrument

(
SynthDef (\blipper, {
	arg base = 220, blipHz = 4, amp = 0.25, fxLevel = 0.5, dryLevel = 0.5, fxBus;

	var sig, env, trig, pan, freq;

	trig = Impulse.kr(freq: blipHz);
	freq = base * TRand.kr(lo: 1, hi: 8, trig: trig);
	env = EnvGen.kr(Env.perc(releaseTime: 0.2),gate: trig);
	sig = Blip.ar(freq: freq, numharm: 3, mul: env * amp);
	Out.ar(fxBus, sig * fxLevel); //output some signal to FX bus
	pan = TRand.kr(lo: -1, hi: 1, trig: trig);
	sig = Pan2.ar(sig, pan); //apply pan
	Out.ar(0, sig * dryLevel); //stereo output of dry signal
}).add;
)

r = Synth(\monoverb, [\inBus, ~fxBus1]);
x = Synth(\blipper, [\fxBus, ~fxBus1]);
x.set(\base, 24.midicps);
x.set(\blipHz, 6);
r.set(\wet, 0.8);
r.set(\wet, 0.25);
r.set(\wet, 0);
r.set(\roomsize, 0.75);
r.set(\roomsize, 0.5);
r.set(\damping, 0.0);
r.set(\damping, 1.0);
r.set(\damping, 0.5);
x.set(\dryLevel, 0);
x.set(\dryLevel, 0.33);

x.free;
r.free;

//ensure that FX synth is after the sound generator
r = Synth(\monoverb, [\inBus, ~fxBus1], addAction: \addToTail);

//try some stereo reverb with a stereo FX bus
~fxBus2 = Bus.audio(s, 2); //get next available 2-channel audio bus

//Make a stereo reverb synth - very simple alteration

(
SynthDef(\stereoverb, {
	arg inBus, wet = 0.33, roomsize = 0.5, damping = 0.5;
	var insig, sig;

	insig = In.ar(inBus, 2);
	sig = FreeVerb2.ar(insig[0],insig[1], mix: wet, room: roomsize, damp: damping);
	Out.ar(0, sig);
}).add;
)

(
SynthDef (\blipper2, {
	arg base = 220, blipHz = 4, amp = 0.25, fxLevel = 0.5, dryLevel = 0.5, fxBus;

	var sig, env, trig, pan, freq;

	trig = Impulse.kr(freq: blipHz);
	freq = base * TRand.kr(lo: 1, hi: 8, trig: trig);
	env = EnvGen.kr(Env.perc(releaseTime: 0.2),gate: trig);
	sig = Blip.ar(freq: freq, numharm: 3, mul: env * amp);
	pan = TRand.kr(lo: -1, hi: 1, trig: trig);
	sig = Pan2.ar(sig, pan); //apply pan
	Out.ar(fxBus, sig * fxLevel); //output a stereo signal to FX bus
	Out.ar(0, sig * dryLevel); //stereo output of dry signal
}).add;
)

r = Synth(\stereoverb, [\inBus, ~fxBus2]);
x = Synth(\blipper2, [\fxBus, ~fxBus2]);
x.set(\base, 36.midicps);
x.set(\blipHz, 6);
r.set(\wet, 0.8);
r.set(\wet, 0.0);
r.set(\roomsize, 0.75);
r.set(\roomsize, 0.5);
r.set(\damping, 0.0);
r.set(\damping, 1.0);
r.set(\damping, 0.5);
x.set(\dryLevel, 0);
x.set(\dryLevel, 0.33);

x.free;
r.free;

/* Groups */

~srcGroup = Group.new; //create a group for the source sounds
~fxGroup = Group.after(~srcGroup); //create a group after the sources for FX

x = Synth(\blipper2, [\fxBus, ~fxBus2], target: ~srcGroup);
y = Synth(\blipper2, [\fxBus, ~fxBus2], target: ~srcGroup);
r = Synth(\stereoverb, [\inBus, ~fxBus2], target: ~fxGroup);

(
SynthDef(\tone2, {
	arg inBus, freq = 200, amp = 0.125, gate = 1, rhz = 4, pan = 0, nh = 5;
	var env, sig, vib, vhz;

	vhz = freq * LFNoise0.kr(rhz).range(1, 4).round;
	vib = 1 + In.kr(inBus); //apply vibrato
	env = EnvGen.kr(Env.asr(attackTime: 0.5),gate: gate, doneAction: 2);
	sig = Blip.ar(vhz * vib, numharm: nh, mul: env * amp);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

x.free;
r.free;

// Groups can also be used to send messages to all synths in the group
v = Synth(\vib, [\outBus, ~ctrlBus1, \vibWidth, 0.03, \vibRise, 2], target: ~srcGroup);
t = Synth(\tone2, [\inbus, ~ctrlBus1, \pan, -1], target: ~srcGroup, addAction: \addToTail);
u = Synth(\tone2, [\inBus, ~ctrlBus1, \freq, 300, \pan, 1], target: ~srcGroup, addAction: \addToTail);
q = Synth(\tone2, [\inBus, ~ctrlBus1, \freq, 100, \pan, 0], target: ~srcGroup, addAction: \addToTail);

~srcGroup.set(\rhz, 5);
~srcGroup.set(\amp, 0.1);
~srcGroup.set(\vibWidth, 0);
~srcGroup.set(\gate, 0);

~srcGroup.free;
~fxGroup.free;

