/*
Project 2: Markov Madness
Keen You (keen.you@yale.edu)

No input required. Just run everything and the program will generate ~3 min of music.
Structure of output is explained below.
*/

(
s.waitForBoot {

	/********************************* SynthDefs *********************************/
	// Layer 1 SynthDef: a brass sounding instrument
	// Adapted from https://github.com/everythingwillbetakenaway/Synthdefs/blob/master/solo.scd
	(
		SynthDef(\solo, { | amp=0.8 out=0 gate=1 freq=90  |
			var aEnv, fEnv, osc, flt;
			aEnv = EnvGen.kr(Env.asr(0.2, 1, 2), gate);
			fEnv = EnvGen.kr(Env.adsr(0.4, 1.2, 0.7, 2), gate, 800);
			osc = Saw.ar(Lag.kr(freq, 0.1) * [1, 1.005], amp); // add amplitude
			flt = LPF.ar(osc, fEnv + 800, aEnv);
			Out.ar(out, flt);
		}).add;
	);

	// Layer 2 SynthDef: glokenspiel
	// Adapted from https://github.com/SCLOrkHub/SCLOrkSynths/blob/master/in-process/Completed/glockenspiel.scd
	(
		SynthDef(\glockenspiel, {
		arg freq = 440, amp = 0.4, pan = 0, out = 0, att = 0.001, rel = 6, exciterRel = 0.05;

		var env, snd, exciter;

		env = Env.perc(att, exciterRel, 0.25).kr;

		exciter = WhiteNoise.ar(env);

		snd = DynKlank.ar(
			specificationsArrayRef:
			Ref.new([
				[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // harmonics
				[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
				[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
			]),
			input: exciter,
			freqscale: freq,
			decayscale: rel
		);

		DetectSilence.ar(
			in: snd,
			amp: 0.001,
			time: 0.5,
			doneAction: 2
		);

		snd = snd * 0.1;

		Out.ar(out, Pan2.ar(snd, pan, amp));
	},
	metadata: (
		credit: "http://sccode.org/1-5aD",
		category: \bells,
		tags: [\pitched]
	)
	).add;);

	// Layer 3 SynthDef: guitar
	// Adapted from https://github.com/SCLOrkHub/SCLOrkSynths/blob/master/SynthDefs/guitar/pluck.scd
	(SynthDef("pluck", {arg amp = 0.4, freq = 440, decay = 5, coef = 0.1, pan = 0;
		var env, snd;
		env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
		snd = Pluck.ar(
			in: WhiteNoise.ar(amp),
			trig: Impulse.kr(0),
			maxdelaytime: 0.1,
			delaytime: freq.reciprocal,
			decaytime: decay,
			coef: coef);
		snd = Pan2.ar(snd, pan);
		Out.ar(0, [snd, snd]);
	}).add;);

	/********************************* End of SynthDefs *********************************/

	/******************************** Composer Functions ********************************/

	// collect chords in section 1 training data
	(~analyze_section_1 = {
		arg layer_1, layer_2, layer_3;
		var layer_3_subsection, layer_2_subsection;
		var layer_2_chords = [];
		var layer_3_chords = [];
		var chords = [];
		var chord;

		// from insepcting music score, the first 22 measures of layer 2 and 3 are regular arpeggio patterns

		// extract chords from first 22 meausures of layer 3
		layer_3_subsection = layer_3.copyRange(0, 6 * 2 * 2 * 22 - 1);
		layer_3_subsection = layer_3_subsection.flatten.reshape(22, 6 * 2 * 2, 2);

		// first 22 measures for layer 2
		layer_2_subsection = layer_2.copyRange(0, 4 * 2 * 6 * 22 - 1);
		layer_2_subsection = layer_2_subsection.flatten.reshape(22, 4 * 2 * 6, 2);

		// from inspecting subsection, each note is followed by a short duration of rest
		// probably relic from quantization

		// find chords for layer 3
		layer_3_subsection.do({
			arg measure, i;
			chord = [];
			measure.do({
				arg note, j;
				// only take the note and ignore the rest that follows
				if((note[0] != \rest), {chord = chord.add(note[0])});
			});
			layer_3_chords = layer_3_chords.add(chord);
		});

		// find chords for layer 2
		layer_2_subsection.do({
			arg measure, i;
			chord = [];
			measure.do({
				arg note, j;
				if((note[0] != \rest), {chord = chord.add(note[0])});
			});
			layer_2_chords = layer_2_chords.add(chord);
		});
		layer_2_chords = layer_2_chords.flatten.reshape(44, 3, 4);
		layer_3_chords = layer_3_chords.flatten.reshape(44, 6);

		// add layer_3 chords as it is, add the first of every 3 layer 2 chords because each chord is repeated 3 times
		layer_3_chords.do({
			arg item, i;
			chords = chords.add([layer_2_chords[i][0], item]); // for layer 2, only keep one of the repeating 3
		});

		// return melody as it is, and the extracted chords
		[layer_1, chords]
	};);

	// compose all layers for section I
	// Training data: Saint-Saens Swan
	// Time signature: 6/4
	// Number of measures: 17
	(~compose_section_1 = {
		arg pattern;
		var melody, chords;
		var msf; // melody shannon finger
		var csf; // chord shannon finger
		var generator;
		var generated_tuples = [];
		var melody_pitch = [\rest]; // no melody in intro measure
		var melody_duration = [6]; // no melody in intro measure (6 beats)
		var tuple;
		var layer_2_pitch = [];
		var layer_2_duration = [];
		var layer_3_pitch = [];
		var layer_3_duration = [];
		var layer_2_reg = 0.25!24; // regular arpeggio rhythm pattern
		var layer_2_rolled_chords = ([0.01,0.01,0.01,0.97]!6).flatten; // rolled chord rhythm pattern
		var layer_3_reg = 0.5!12;
		var layer_3_rolled_chords = ([0.01,0.01,0.01,0.01,0.01,2.95]!2).flatten;
		var chord_progression = [];

		'Compose section I...'.postln;

		melody = pattern[0];
		chords = pattern[1];

		// shannon finger for layer 1
		msf = ShannonFinger(melody.size);
		melody.do { |item, i| msf.put(i, item)}; // put both pitch and duration
		generator = msf.asStream(2); // change order here
		generated_tuples = Array.fill(50, {generator.next}); // add 50 notes first
		generated_tuples.do({
			arg item, i;
			melody_pitch = melody_pitch.add(item[0]);
			melody_duration = melody_duration.add(item[1]);
		});
		// keep adding to melody until 90 beats
		while({sum(melody_duration) < 90},
			{
				tuple = generator.next;
				melody_pitch = melody_pitch.add(tuple[0]);
				melody_duration = melody_duration.add(tuple[1]);
			}
		);
		// end on a 3-beat G
		melody_pitch = melody_pitch.add(67);
		melody_duration = melody_duration.add(3);
		// add rest to complete 17 measures
		melody_pitch = melody_pitch.add(\rest);
		melody_duration = melody_duration.add(6 * 17 - sum(melody_duration));

		// compose layer 2 and layer 3
		csf = ShannonFinger(chords.size);
		chords.do { |item, i| csf.put(i, item)};
		generator = csf.asStream(1); // change order here
		// generate 8 chords for a 4-measure phrase
		generated_tuples = Array.fill(8, {generator.next});

		generated_tuples.do({
			arg item, i ;
			layer_2_pitch = layer_2_pitch.add((item[0]!3).flatten); // repeat 3 times
			layer_3_pitch = layer_3_pitch.add(item[1]);
		});
		layer_2_pitch = layer_2_pitch.flatten;
		layer_3_pitch = layer_3_pitch.flatten;
		// add intro
		layer_2_pitch = (generated_tuples[0][0]!6).flatten ++ (layer_2_pitch!4).flatten;
		layer_3_pitch = (generated_tuples[0][1]!2).flatten ++ (layer_3_pitch!4).flatten;

		// rhythm pattern:
		// layer 2 and 3 play arpeggio for one-measure intro, no melody
		// layer 2 and 3 play arpeggio for 4 measures, with melody
		// layer 2 plays rolled chords on downbeat, layer 3 plays arpeggio, with melody
		// layer 3 plays rolled chords on downbeat, layer 2 plays arpeggio, with melody
		// layer 2 and 3 play arpeggio for 4 measures, with melody, melody ends on a 3-beat G
		// diagram:
		// layer 2: [intro measure] arpeggio rolled   arpeggio  arpeggio
		// layer 3: [intro measure] arpeggio arpeggio rolled    arpeggio

		// add above rhythm pattern
		layer_2_duration = layer_2_reg ++ (layer_2_reg!4).flatten ++ (layer_2_rolled_chords!4).flatten ++ (layer_2_reg!4).flatten ++ (layer_2_reg!4).flatten;
		layer_3_duration = layer_3_reg ++ (layer_3_reg!4).flatten ++ (layer_3_reg!4).flatten ++ (layer_3_rolled_chords!4).flatten ++ (layer_3_reg!4).flatten;

		[melody_pitch, melody_duration, layer_2_pitch, layer_2_duration, layer_3_pitch, layer_3_duration]
	};);

	// compose all layers for section II
	// Training data: Bach Flute Sonata in G major
	// Time signature: 4/4
	// Number of measures: varies
	(~compose_section_2 = {
		arg layer_1, layer_2, layer_3;
		var msf; // melody shannonfinger
		var rsf; // rhythm shannonfinger
		var layer_1_pitch = [];
		var layer_1_duration= [];
		var layer_2_pitch = [];
		var layer_2_duration = [];
		var layer_3_pitch = [];
		var layer_3_duration = [];
		var pitch_generator, duration_generator;
		var count, unit;
		var index;

		'Compose section II...'.postln;

		// shannon finger for layer 1
		// model pitch and duration in two shannon fingers
		msf = ShannonFinger(layer_1.size);
		rsf = ShannonFinger(layer_1.size);
		index = 0;
		layer_1.do { |item, i| if((item[0] != \rest), {msf.put(i, item[0])})};
		layer_1.do { |item, i| if(((item[0] != \rest) && (item[1] < 5)), {rsf.put(index, item[1]); index = index + 1})};

		pitch_generator = msf.asStream(5);
		duration_generator = rsf.asStream(2);

		// generate rhythm first
		count = 0;
		while ({count < 50}, {
			unit = duration_generator.next;
			count = count + unit;
			layer_1_duration = layer_1_duration.add(unit);
		});
		// for each note in generated rhythm, generate a corresponding pitch
		layer_1_duration.size.do({layer_1_pitch = layer_1_pitch.add(pitch_generator.next)});
		// layer 2 is silent while layer 1 plays
		layer_2_pitch = layer_2_pitch.add(\rest);
		layer_2_duration = layer_2_duration.add(count);

		// shannon finger for layer 2
		// model pitch and duration in two shannon fingers
		msf = ShannonFinger(layer_2.size);
		rsf = ShannonFinger(layer_2.size);
		index = 0;
		layer_2.do { |item, i| if((item[0] != \rest), {msf.put(i, item[0])})};
		layer_2.do { |item, i| if(((item[0] != \rest) && (item[1] < 5)), {rsf.put(index, item[1]); index = index + 1})};
		pitch_generator = msf.asStream(5);
		duration_generator = rsf.asStream(2);
		// generate rhythm
		count = 0;
		while ({count < 50}, {
			unit = duration_generator.next;
			count = count + unit;
			layer_2_duration = layer_2_duration.add(unit);
		});
		// -1 one for the previously added \rest
		// for each note in generated rhythm, generate a corresponding pitch
		(layer_2_duration.size - 1).do({layer_2_pitch = layer_2_pitch.add(pitch_generator.next)});
		// layer 1 is silent while layer 1 plays
		layer_1_pitch = layer_1_pitch.add(\rest);
		layer_1_duration = layer_1_duration.add(count);

		// shannon finger for layer 3
		// model pitch and duration in two shannon fingers
		msf = ShannonFinger(layer_3.size);
		rsf = ShannonFinger(layer_3.size);
		index = 0;
		layer_3.do { |item, i| if((item[0] != \rest), {msf.put(i, item[0])})};
		layer_3.do { |item, i| if(((item[0] != \rest) && (item[1] < 5)), {rsf.put(i, item[1]); index = index + 1;})};
		pitch_generator = msf.asStream(5);
		duration_generator = rsf.asStream(2);
		// generate rhythm
		count = 0;
		while ({count < sum(layer_1_duration)}, {
			unit = duration_generator.next;
			count = count + unit;
			layer_3_duration = layer_3_duration.add(unit);
		});
		// for each note in generated rhythm, generate a corresponding pitch
		layer_3_duration.size.do({layer_3_pitch = layer_3_pitch.add(pitch_generator.next)});

		// structure overview:
		// Part 1: layer 1 plays melody, layer 3 accompanies, layer 2 silent
		// Part 2: layer 2 plays melody, layer 3 accompanies, layer 1 silent

		[[layer_1_pitch, layer_1_duration], [layer_2_pitch, layer_2_duration], [layer_3_pitch, layer_3_duration]]
	});

	// compose all layers for section III
	// Training data: Hisaishi Merry Go Round of Life (Howl's Moving Castle Theme)
	// Time signature: 3/4
	// Number of measures: varies
	(~compose_section_3 = {
		arg layer_1, layer_2, layer_3;
		var layer_1_pitch = [];
		var layer_1_duration= [];
		var layer_2_pitch = [];
		var layer_2_duration = [];
		var layer_3_pitch = [];
		var layer_3_duration = [];
		var generated_tuples = [];
		var unit;
		var count = 0;
		var generator, msf; // melody shannonfinger

		'Compose section III...'.postln;

		// add first 4 measures as they are
		41.do({
			arg i;
			layer_1_pitch = layer_1_pitch.add(layer_1[i][0]);
			layer_1_duration = layer_1_duration.add(layer_1[i][1]);
			layer_2_pitch = layer_2_pitch.add(layer_2[i][0]);
			layer_2_duration = layer_2_duration.add(layer_2[i][1]);
			layer_3_pitch = layer_3_pitch.add(layer_3[i][0]);
			layer_3_duration = layer_3_duration.add(layer_3[i][1]);
		});

		// removing trailing rests
		layer_1 = ~remove_trailing_rest.(layer_1); // size 280
		layer_2 = ~remove_trailing_rest.(layer_2); // size 265
		layer_3 = ~remove_trailing_rest.(layer_3); // size 254

		// some actual rests are removed, resulting in different sizes
		// fill in random rests in layer 2 and 3 such that all three layers have the same number of pitches
		while ({layer_2.size < layer_1.size}, {layer_2 = layer_2.insert(rrand(0, layer_2.size-1), [\rest, 0.5])});
		while ({layer_3.size < layer_1.size}, {layer_3 = layer_3.insert(rrand(0, layer_3.size-1), [\rest, 0.5])});

		// model layer 1 pitch + duration and layer 2 and 3 pitch as one unit
		msf = ShannonFinger(layer_1.size);
		layer_1.size.do({
			arg i;
			//         [[layer 1 pitch, duration], layer 2 pitch, layer 3 pitch]
			msf.put(i, [layer_1[i], layer_2[i][0], layer_3[i][0]]);
		});

		generator = msf.asStream(1); // change order here

		// generate at least 120 beats of music
		while ({count < 120},
			{
				unit = generator.next;
				count = count + unit[0][1]; // accumulate current number of beats
				layer_1_pitch = layer_1_pitch.add(unit[0][0]);
				layer_1_duration = layer_1_duration.add(unit[0][1]);
				// layer 2 and 3 duration will be the same as layer 1 duration
				layer_2_pitch = layer_2_pitch.add(unit[1]);
				layer_2_duration = layer_2_duration.add(unit[0][1]);
				layer_3_pitch = layer_3_pitch.add(unit[2]);
				layer_3_duration = layer_3_duration.add(unit[0][1]);
			}
		);

		// all three layers will play at exactly the same beats, will sound boring
		// replace 30 random notes with rest in layer 2 and layer 3
		(30).do({layer_2_pitch = layer_2_pitch.put(rrand(0, layer_2_pitch.size-1), \rest)});
		(30).do({layer_3_pitch = layer_3_pitch.put(rrand(0, layer_3_pitch.size-1), \rest)});

		[[layer_1_pitch, layer_1_duration], [layer_2_pitch, layer_2_duration], [layer_3_pitch, layer_3_duration]]
	});

	// Auxiliary function: remove trailing rest for each pitch
	(~remove_trailing_rest = {
		arg layer;
		var output = [];
		forBy(0, layer.size - 2, 2,
			{
				arg i;
				output = output.add([layer[i][0], layer[i][1] + layer[i+1][1]]);
			};
		);
		output
	};);

	/******************************** End of Composer Functions ********************************/

	// midi files for training data, donwloaded from MuseScore
	// file 1: https://musescore.com/user/5051806/scores/1602621
	// file 2: https://musescore.com/user/13172/scores/1666461
	// file 3: https://musescore.com/user/27400629/scores/6089315
	~section_1_file = "SaintSaens-Swan.mid";
	~section_2_file = "bach-sonataGmajor.mid";
	~section_3_file = "hisaishi-MerryGoRoundOfLife.mid";

	// read midi files
	~section_1_midi = SimpleMIDIFile.read("SaintSaens-Swan.mid".resolveRelative);
	~section_2_midi = SimpleMIDIFile.read("bach-sonataGmajor.mid".resolveRelative);
	~section_3_midi = SimpleMIDIFile.read("hisaishi-MerryGoRoundOfLife.mid".resolveRelative);

	// get data for each layer for each piece
	~section_1_layer_1 = ~section_1_midi.generatePatternSeqs[0];
	~section_1_layer_2 = ~section_1_midi.generatePatternSeqs[1];
	~section_1_layer_3 = ~section_1_midi.generatePatternSeqs[2];

	~section_2_layer_1 = ~section_2_midi.generatePatternSeqs[0];
	~section_2_layer_2 = ~section_2_midi.generatePatternSeqs[1];
	~section_2_layer_3 = ~section_2_midi.generatePatternSeqs[2];

	~section_3_layer_1 = ~section_3_midi.generatePatternSeqs[0];
	~section_3_layer_2 = ~section_3_midi.generatePatternSeqs[1];
	~section_3_layer_3 = ~section_3_midi.generatePatternSeqs[2];

	// compose section I
	~section_1_pattern = ~analyze_section_1.(~section_1_layer_1, ~section_1_layer_2, ~section_1_layer_3);
	~section_1_composition = ~compose_section_1.(~section_1_pattern);

	~layer_1_pitch = ~section_1_composition[0];
	~layer_1_rhythm = ~section_1_composition[1];
	~layer_2_pitch = ~section_1_composition[2];
	~layer_2_rhythm = ~section_1_composition[3];
	~layer_3_pitch = ~section_1_composition[4];
	~layer_3_rhythm = ~section_1_composition[5];

	// compose section II
	~section_2_composition = ~compose_section_2.(~section_2_layer_1, ~section_2_layer_2, ~section_2_layer_3);

	~layer_1_pitch = ~layer_1_pitch ++ ~section_2_composition[0][0];
	~layer_1_rhythm = ~layer_1_rhythm ++ ~section_2_composition[0][1];
	~layer_2_pitch = ~layer_2_pitch ++ ~section_2_composition[1][0];
	~layer_2_rhythm = ~layer_2_rhythm ++ ~section_2_composition[1][1];
	~layer_3_pitch = ~layer_3_pitch ++ ~section_2_composition[2][0];
	~layer_3_rhythm = ~layer_3_rhythm ++ ~section_2_composition[2][1];

    // since section II is composed with duration freedom,
	// need to align playhead so that all layers have the same accumulative durations

	// align playhead
	// find max duration of the three layers and add 4 beats
	~beat = round(([sum(~layer_1_rhythm), sum(~layer_2_rhythm), sum(~layer_3_rhythm)].maxItem) + 4);
	// fill with rest to reach ~beat
	~layer_1_pitch = ~layer_1_pitch.add(\rest);
	~layer_1_rhythm = ~layer_1_rhythm.add(~beat - sum(~layer_1_rhythm));
	~layer_2_pitch = ~layer_2_pitch.add(\rest);
	~layer_2_rhythm = ~layer_2_rhythm.add(~beat - sum(~layer_2_rhythm));
	~layer_3_pitch = ~layer_3_pitch.add(\rest);
	~layer_3_rhythm = ~layer_3_rhythm.add(~beat - sum(~layer_3_rhythm));

	// compose section III
	~section_3_composition = ~compose_section_3.(~section_3_layer_1, ~section_3_layer_2, ~section_3_layer_3);

	~layer_1_pitch = ~layer_1_pitch ++ ~section_3_composition[0][0];
	~layer_1_rhythm = ~layer_1_rhythm ++ ~section_3_composition[0][1];
	~layer_2_pitch = ~layer_2_pitch ++ ~section_3_composition[1][0];
	~layer_2_rhythm = ~layer_2_rhythm ++ ~section_3_composition[1][1];
	~layer_3_pitch = ~layer_3_pitch ++ ~section_3_composition[2][0];
	~layer_3_rhythm = ~layer_3_rhythm ++ ~section_3_composition[2][1];

	'Composition completed!'.postln;

	// amplitude manipulation
	// add some variations in amplitude to make it sound more realistic
	~layer_1_amplitude = Array.fill(~layer_1_pitch.size, {0.5 + rrand(-0.3, 0.3)});
	~layer_2_amplitude = Array.fill(~layer_2_pitch.size, {0.2 + rrand(-0.2, 0.2)});
	~layer_3_amplitude = Array.fill(~layer_3_pitch.size, {0.2 + rrand(-0.2, 0.2)});

	// set tempo
	TempoClock.default.tempo = 110/60;

	s.sync;

	// play
	Ppar([Pbind(\instrument, \solo, \midinote, Pseq(~layer_1_pitch, 1), \dur, Pseq(~layer_1_rhythm, 1), \amp, Pseq(~layer_1_amplitude, 1)),
		Pbind(\instrument, \glockenspiel, \midinote, Pseq(~layer_2_pitch, 1), \dur, Pseq(~layer_2_rhythm, 1), \amp, Pseq(~layer_2_amplitude, 1)),
		Pbind(\instrument, \pluck, \midinote, Pseq(~layer_3_pitch, 1), \dur, Pseq(~layer_3_rhythm, 1), \amp, Pseq(~layer_3_amplitude, 1))]
	).play;

}
)
