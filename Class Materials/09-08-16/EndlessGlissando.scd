/* Jean Claude Risset's Endless Glissando */

// Generate the bell function from Dodge p. 107
(
~bellFunc = {
	arg i, len;

	var val;

	val = exp(4.8283.neg * (1-cos(2*pi*(i-(len/2))/len)));
};

~bellColl = (0..8191).collect({|i| ~bellFunc.value(i,8191)}); //fill an array

~ampBuf = Buffer.alloc(s, 8192); //allocate the buffer

~ampBuf.loadCollection(~bellColl, 0); //load the array into the buffer

~ampBuf.plot("Amp Control Function");

// Generate the 10 octave gliss function from Dodge p. 107
~gliss10 = Env.pairs([[0, 1], [1, 2**10.neg]], \exp);
//~gliss10.plot;

~glissFunc = {
	arg i, len;

	var val;

	val = ~gliss10.at(i/len);
};

~glissColl = (0..8191).collect({|i| ~glissFunc.value(i,8191)}); //fill an array

~hzBuf = Buffer.alloc(s, 8192); //allocate the buffer

~hzBuf.loadCollection(~glissColl, 0); //load the array into the buffer

~hzBuf.plot("Pitch Control Function");
)

// Define the synth

(
SynthDef(\Endless,
{
	arg hzbuf, ampbuf, freq=3900, amp=0.1, dur=180, buflen = 8192, gate = 1;
	var sig, pan = 0, trig = 1, phase, sr = SampleRate.ir;

	phase = Phasor.ar(trig: 1, rate: (1/dur)/sr); //master phase

		sig = Mix.fill(10, {arg i; var phs = (phase + (i / 10)) % 1.0;
			SinOsc.ar(
				freq * BufRd.ar(1, hzbuf, phs * buflen),
				0,
				amp * BufRd.ar(1, ampbuf, phs * buflen))});
		sig = sig * Linen.kr(gate, attackTime: 2, releaseTime: 2, doneAction: 2);
	Out.ar(0, Pan2.ar(sig,pan));
}).add;
)

a = Synth(\Endless, [\hzbuf, ~hzBuf, \ampbuf, ~ampBuf, \buflen, ~hzBuf.numFrames]);
a.release;