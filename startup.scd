(
s.options.numBuffers = 2**24;
s.options.memSize = 2**20;
s.options.maxNodes = 2**20;
s.options.numOutputBusChannels = 24;
s.options.numInputBusChannels = 0;

s.waitForBoot {
  ~dirt = SuperDirt(2, s);

  // Samples init
  ~dirt.loadSoundFiles;
  ~dirt.loadSoundFiles(File.getcwd +/+ "samples/*");
  
  // Synths init
  SynthDef(\scbass8, {
	arg out = 0, amp = 0.1, gate = 1, pan = 0, freq = 200;
	var sig;
	var osc = Array.newClear(6);
	var env = Array.newClear(6);

	env[0] = EnvGen.kr(Env([0,1,0.051,0],[0.001,0.01,0.8], [4,-8]), 1);
	env[1] = EnvGen.kr(Env([0,1,0.051,0],[0.005,0.5,1.5], [0,-8], releaseNode:2), 1);
	env[2] = EnvGen.kr(Env([0,1,1,0],[0.01,0.01,0.2], [0,0,-4], releaseNode:2), gate);
	env[3] = EnvGen.kr(Env([0,1,0],[0.002,2.8], [0,-4]), 1);
	env[4] = EnvGen.kr(Env([0,1,1,0],[0.001,0.1,0.8], [4,0,-4], releaseNode:2), gate);
	env[5] = EnvGen.kr(Env([0,1,0],[0.001,3.0], [0,-4]), 1);

	freq = (freq / 4) * ((0..1)/1 - 0.5 * 0.0007 + 1);

	osc[0] = SinOsc.ar(freq * 11 + 0) * env[0];
	osc[1] = SinOsc.ar(freq * 6 * ( osc[0] * 2.5 + 1 )) * env[1];
	osc[2] = SinOsc.ar(freq * 2 * 1 + 0) * env[2];
	osc[3] = SinOsc.ar(freq * 1 * ( osc[2] * 2.5 + 1 ) + 0) * env[3];
	osc[4] = SinOsc.ar(freq * 1 * ( osc[1] * 2.5 + 1 ) * (osc[3] * 2.5 + 1)) * env[4];
	osc[5] = SinOsc.ar(freq * 2) * env[5];

	sig = osc * DC.ar([0.0, 0.0, 0.0,  0.0, 0.5, 0.5]);
	sig = sig * 0.5;
	sig = sig.flop.sum;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.001,0,1,0.01, 1,-1) ), gate, doneAction:2);
	sig = sig * AmpComp.kr(freq);
	sig = sig.sum;
	Out.ar(out, Pan2.ar(sig, pan, amp));
  }).add;

  // Virtual MIDI Init
  MIDIClient.init(0, 0);
  ~midiOut = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
  ~dirt.soundLibrary.addMIDI(\midi, ~midiOut);

  // Start SuperDirt
  ~dirt.start(20626, 24.collect({|i| i*2}));
};
)