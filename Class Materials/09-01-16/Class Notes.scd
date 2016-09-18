/* September 1, 2016

Making Sound with SuperCollider

I. Booting and monitoring the server

II. Hardware Audio busses

III. Synths, UGens, and SynthDefs

IV. Synth Arguments

V. Dynamic controls

VI. Simple Envelopes and doneAction

VII. Buffers

*/

/* I. Booting and monitoring the server */

//See Useful_Server_Commands.csd and the help file for "Server Architecture"

//Boot the local server and store it in global variable s

s = Server.local.boot;

//Show the active synthesis "nodes"

s.plotTree; //opens a window that displays the currently active nodes

//Show some meters

s.meter;   //Cmd-M also works

/* II. Hardware Audio Busses */

ServerOptions.devices;          //list all the input and output devices on the (local) server

Server.local.options.device = <device name in quotes>; //Optional, if you want to change devices

s.outputBus;  //display the bus numbers of the hardware output channels
s.inputBus;    //input channels

/* III. Synths, UGens, and SynthDefs */

//See the help files for all these things!

//A Synth is a single sound-producing unit, defined within a function, and containing
//one or more UGens

Synth.new(\default); //this will create a synth on the server, using all defaults

//Stop it (and all other synths) with the Stop command in the Language menu, or with CMD-period

x=Synth.new(\default); //or better, use a variable to contain the synth
x.free;                         //...so you can free it, specifically

//Synths are also created implicitly by SuperCollider when you use the .play method on a function
//containing one or more UGens

x = { SinOsc.ar }.play;
x.free;

//UGens run on the server at one of three rates (.ar, .kr, .ir), which you MUST specify
//e.g.: SinOsc.ar, Blip.ar, Dust.ar, Line.kr, LFNoise0.kr, etc.

//They also have arguments, all of which have default values. (These pop up as you type.)
//They can be specified in sequential order...

x = {VarSaw.ar(100, 0, 0.6, 0.05)}.play; //not easy to read, unless you know this UGen
x.free;

//...or specified by their names (keywords), in any order, as follows:

x = {VarSaw.ar(width: 0.6, mul: 0.05, freq: 100)}.play; //clearer!
x.free;

//Number and types o arguments vary from unit to unit, but mul and add are universal

/* IV. Synth Arguments */

// A slightly more complicated example, in stereo!

(x = {
	arg hz = 100, duty = 0.5, amp = 0.1, pan = 0.0;
	var sig;

	sig = VarSaw.ar(freq: hz, width: duty, mul: amp);
	sig = Pan2.ar(sig, pos: pan);
	Out.ar(0, sig);
}.play
)

// Change the value of an argument while the synth is running

x.set(\hz, 100);
x.set(\hz, 20, \amp, 0.05, \duty, 0.1);
x.set(\pan, 0, \hz, 220);
x.free;

/* V. Dynamic Controls */

(x = {
	arg hz = 100, varyHz = 0.5, amp = 0.1;
	var sig, duty, pan;

	duty = SinOsc.kr(freq: varyHz, mul: 0.5, add: 0.5); //offset sine wave 0-1
	pan = LFNoise1.kr(freq: varyHz); //interpolating random number generator

	sig = VarSaw.ar(freq: hz, width: duty, mul: amp);
	sig = Pan2.ar(sig, pos: pan);
	Out.ar(0, sig);
}.play
)

x.set(\varyHz, 0.1);
x.set(\hz, 80, \varyHz, 2.5);
x.set(\hz, 36.midicps, \varyHz, 0.25);
x.set(\hz, 80.midicps, \varyHz, 10, \amp, 0.05);
x.set(\amp, 0.05, \hz, (36+36.rand.round(3)).midicps); //round to minor thirds
x.free;

//Let's try controlling the amplitude, as well

(x = {
	arg hz = 100, varyHz = 0.5, amp = 0.1, dur = 2;
	var sig, duty, pan, env;

	duty = SinOsc.kr(freq: varyHz, mul: 0.5, add: 0.5); //offset sine wave 0-1
	pan = LFNoise1.kr(freq: varyHz); //interpolating random number generator
	env = XLine.kr(start: 1, end: 0.001, dur: dur);

	sig = VarSaw.ar(freq: hz, width: duty, mul: amp);
	sig = sig * env;  //apply the amplitude envelope
	sig = Pan2.ar(sig, pos: pan);
	Out.ar(0, sig);
}.play
)

x.free;

//Adding a "doneAction" let's the synth turn itself off after the XLine has finished

(x = {
	arg varyHz = 0.5, amp = 0.1, dur = 3, fund = 50;
	var sig, duty, pan, env, hz;

	hz = LFNoise0.kr(freq: varyHz).exprange(fund, fund*16).round(fund); //rand harmonics
	duty = SinOsc.kr(freq: varyHz, mul: 0.5, add: 0.5); //offset sine wave 0-1
	pan = LFNoise1.kr(freq: varyHz); //interpolating random number generator
	env = XLine.kr(start: 1, end: 0.001, dur: dur, doneAction: 2); //will free synth when done

	sig = VarSaw.ar(freq: hz, width: duty, mul: amp);
	sig = sig * env;  //apply the amplitude envelope
	sig = Pan2.ar(sig, pos: pan);
	Out.ar(0, sig);
}.play
)

//Let's turn this into a SynthDef

(
SynthDef(\randHarm,
{
	arg varyHz = 0.5, amp = 0.1, dur = 3, fund = 50;
	var sig, duty, pan, env, hz;

	hz = LFNoise0.kr(freq: varyHz).exprange(fund, fund*16).round(fund); //rand harmonics
	duty = SinOsc.kr(freq: varyHz, mul: 0.5, add: 0.5); //offset sine wave 0-1
	pan = LFNoise1.kr(freq: varyHz); //interpolating random number generator
	env = XLine.kr(start: 1, end: 0.001, dur: dur, doneAction: 2); //will free synth when done

	sig = VarSaw.ar(freq: hz, width: duty, mul: amp);
	sig = sig * env;  //apply the amplitude envelope
	sig = Pan2.ar(sig, pos: pan);
	Out.ar(0, sig);
}).add
)

x = Synth(\randHarm, [\fund, 30.midicps, \dur, 0.5]);

/* Intro to Buffers */
// See the helpfile for Buffer!
(
~fna = Buffer.alloc(s, 512, 1);
~fna.sine1([1.0]).plot;
~fnb = Buffer.alloc(s, 512, 1);
~fnb.sine1([0.0, 1.0]).plot;
~fnc = Buffer.alloc(s, 512, 1);
~fnc.sine1([0.0, 0.0, 1.0]).plot;
~fnd = Buffer.alloc(s, 512, 1);
~fnd.sine1([0.0, 0.0, 0.0, 1.0]).plot;
)
~fna.bufnum;   //returns the number of this buffer

(
SynthDef(\waveStation,
{
	arg freq = 200;
	var sig, siga, sigb, sigc, sigd, xpos, ypos;

	siga = Osc.ar(~fna.bufnum, freq, mul: 0.25);
	sigb = Osc.ar(~fnb.bufnum, freq, mul: 0.25);
	sigc = Osc.ar(~fnc.bufnum, freq, mul: 0.25);
	sigd = Osc.ar(~fnd.bufnum, freq, mul: 0.25);
//	xpos = MouseX.kr;
//	ypos = MouseY.kr;
	xpos = LFNoise1.kr(2, 0.5, 0.5);
	ypos = LFNoise1.kr(1.5, 0.5, 0.5);
	siga = siga * (1-xpos) * (1-ypos);
	sigb = sigb * (1-xpos) * ypos;
	sigc = sigc * xpos * ypos;
	sigd = sigd * xpos * (1 - ypos);
	sig = Splay.ar([siga, sigb, sigc, sigd]);
	Out.ar(0, sig);
}).add
)

a = Synth(\waveStation, [\freq, 36.midicps]);
a.free;

b = Synth(\waveStation, [\freq, 43.midicps]);
c = Synth(\waveStation, [\freq, 46.midicps]);
d = Synth(\waveStation, [\freq, 48.midicps]);

a.set(\freq, 51.midicps);
b.set(\freq, 55.midicps);
c.set(\freq, 60.midicps);
d.set(\freq, 77.midicps);

a.free; b.free; c.free; d.free;