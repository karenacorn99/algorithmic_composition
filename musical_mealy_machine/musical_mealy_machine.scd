/*
Project 3: Musical Mealy Machine
Keen You
keen.you@yale.edu
*/

// Run everything to listen to a sample
(
s.waitForBoot{
	// function that takes input
	// check out default values here
	~get_input= {
		// C -> G -> F -> C -> F -> G -> C
		arg operations = [\generate, \modulate_right, \generate, \tonicize, \generate, \modulate_left_2, \generate, \modulate_right, \generate, \modulate_left, \generate, \modulate_right_2, \generate, \modulate_left, \generate],
		starting_key = \C,
		play_mode = \alberti_bass; // {alberti_bass, chord}
		[starting_key, operations, play_mode]
	};

	/*
	input specifications:
	operations: an operation to perform on current state
	supported operations {generate, modulate_left, modulate_right, modulate_left_2, modulate_right_2, tonicize}

	generate: generate a chord progression for current state

	modulate_left: generate a chord progress to modulate to left/counterclockwise direction neighbor of current state on circle of fifths, for example, if current state is C, modulate_left will move to F

	modulate_right: generate a chord progress to modulate to right/clockwise direction neighbor of current state on circle of fifths, for example, if current state is C, modulate_right will move to G

	modulate_left_2: generate a chord progress to modulate to left/counterclockwise direction *next* neighbor of current state on circle of fifths, for example, if current state is C, modulate_left_2 will move to Bb

	modulate_right_2: generate a chord progress to modulate to right/clockwise direction *next* neighbor of current state on circle of fifths, for example, if current state is C, modulate_right_2 will move to D

	tonicize: 'temporarily modulate' to fifth, add V/V - I, no changes made to current state

	*/

	/*** INPUT EXAMPLES ***/
	// example: going clockwise around circle of fifths
	//~input= ~get_input.(operations: \modulate_right!13, starting_key: \Eb, play_mode: \alberti_bass);

	// example: going counter-clockwise around circle of fifths
	//~input= ~get_input.(operations: \modulate_left!13);

	// default
	//~input= ~get_input.();

	// ******* ENTER CUSTOM INPUT HERE ********
	// In this example: start in Db, to Gb, to Db, to Eb, tonicize, back to Db
	~input= ~get_input.(operations: [\modulate_left, \generate, \modulate_right, \modulate_right_2, \generate, \tonicize, \generate, \modulate_left_2], starting_key: \Db, play_mode: \alberti_bass);

	/*** Auxiliary Functions ***/
	// mealy machine
	~mealy_machine = (
		key_progression: [],
		current_key: 0,
		current_index: 0,
		// I - IV - V - I, I - ii - V - I, I - vi - V - I, I - IV - ii - V - I
		major_regular_progression: [[\tonic, \subdominant, \dominant, \tonic],
			                        [\tonic, \supertonic, \dominant, \tonic],
			                        [\tonic, \submediant, \dominant, \tonic],
			                        [\tonic, \subdominant, \supertonic, \dominant, \tonic]],
		chords: [],
		function_to_scale_degree_triad: Dictionary.newFrom([\tonic, Scale.major.degrees.at([0,2,4]), \supertonic, Scale.major.degrees.at([1,3,5]), \mediant, Scale.major.degrees.at([2,4,6]), \subdominant, Scale.major.degrees.at([3,5,0]), \dominant, Scale.major.degrees.at([4,6,1]), \submediant, Scale.major.degrees.at([5,0,2])]),
		key_to_midi: Dictionary.newFrom([\F, 65, \C, 60, \G, 67, \D, 62, \A, 69, \E, 64, \B, 71, \Gb, 66, \Db, 61, \Ab, 68, \Eb, 63, \Bb, 70]);
	);
	// other functions moved outside for better readability

	// circle of fifths
	~circle = [\F, \C, \G, \D, \A, \E, \B, \Gb, \Db, \Ab, \Eb, \Bb];
	//~circle_minor = [\d, \a, \e, \b, \f_sharp, \c_sharp, \g_sharp, \eb, \bb, \f, \c, \g];

	// parse input
	~starting_key = ~input[0];
	~operations = ~input[1];
	~play_mode = ~input[2];

	// set initial state
	~mealy_machine.current_key = ~starting_key;
	~mealy_machine.key_progression = ~mealy_machine.key_progression.add(~starting_key);
	~mealy_machine.current_index = ~circle.indexOf(~starting_key); // index of starting_key in circle of fifths

	// loop through operations
	// for each operation given by user, adjust current state
	// if a modulation is required, two preselected pivot chords will be shuffled and together with V - I of new key, form the modulation progression
	// if a generation is required, one of the predefined regular progression will be selected
	(~operations.do({
		arg item;
		switch (item,
			\modulate_right, {
				"modulate right".postln;
				~mealy_machine.current_index = ~mealy_machine.current_index + 1; // set new state index
				~mealy_machine.current_key = ~circle.wrapAt(~mealy_machine.current_index); // find corresponding key using circle of fifths
				~mealy_machine.current_index = ~circle.indexOf(~mealy_machine.current_key); // reset index
				~mealy_machine.key_progression = ~mealy_machine.key_progression.add(~mealy_machine.current_key); // add key progression just in case
				~progression = [\submediant, \supertonic].scramble ++ [\dominant, \tonic];  // pivot chords - V - I, all in new keys
				~mealy_machine.chords = ~mealy_machine.chords.add([~mealy_machine.current_key, ~progression]);
			},
			\modulate_right_2, {
				"modulate right 2".postln;
				~mealy_machine.current_index = ~mealy_machine.current_index + 2;
				~mealy_machine.current_key = ~circle.wrapAt(~mealy_machine.current_index);
				~mealy_machine.current_index = ~circle.indexOf(~mealy_machine.current_key);
				~mealy_machine.key_progression = ~mealy_machine.key_progression.add(~mealy_machine.current_key);
				~progression = [\supertonic, \subdominant].scramble ++ [\dominant, \tonic];  // pivot chords - V - I, all in new keys
				~mealy_machine.chords = ~mealy_machine.chords.add([~mealy_machine.current_key, ~progression]);
			},
			\modulate_left, {
				"modulate left".postln;
				~mealy_machine.current_index = ~mealy_machine.current_index - 1;
				~mealy_machine.current_key = ~circle.wrapAt(~mealy_machine.current_index);
				~mealy_machine.current_index = ~circle.indexOf(~mealy_machine.current_key);
				~mealy_machine.key_progression = ~mealy_machine.key_progression.add(~mealy_machine.current_key);
				~progression = [\mediant, \submediant].scramble ++ [\dominant, \tonic];  // pivot chords - V - I, all in new keys
				~mealy_machine.chords = ~mealy_machine.chords.add([~mealy_machine.current_key, ~progression]);
			},
			\modulate_left_2, {
				"modulate left 2".postln;
				~mealy_machine.current_index = ~mealy_machine.current_index - 2;
				~mealy_machine.current_key = ~circle.wrapAt(~mealy_machine.current_index);
				~mealy_machine.current_index = ~circle.indexOf(~mealy_machine.current_key);
				~mealy_machine.key_progression = ~mealy_machine.key_progression.add(~mealy_machine.current_key);
				~progression = [\dominant, \mediant] ++ [\dominant, \tonic];  // pivot chords - V - I, all in new keys // no scrambling, don't want two consecutive dominant chords
				~mealy_machine.chords = ~mealy_machine.chords.add([~mealy_machine.current_key, ~progression]);
			},
			\generate, {
				"generate".postln;
				~progression = ~mealy_machine.major_regular_progression.choose; // randomly pick a regular chord progression
				~mealy_machine.chords = ~mealy_machine.chords.add([~mealy_machine.current_key, ~progression]);
			},
			\tonicize, {
				"tonicize".postln;
				// fifth is the clockwise neighbor of current state
				~mealy_machine.chords = ~mealy_machine.chords.add([~circle.wrapAt(~mealy_machine.current_index + 1), [\dominant, \tonic]]);
				//~mealy_machine.chords = ~mealy_machine.chords.add([~circle.wrapAt([~mealy_machine.current_index + 1, ~mealy_machine.current_index -1].choose), [\dominant, \tonic]]);
			},
			// an invalid will be ignored, remaining operations work normally
			{"invalid modulation, ignored".postln;};
		);
	}
	););

	// add midi_chord field to mealy_machine
	~mealy_machine.midi_chord = [];
	// newline to separate previously printed operations and following chord progression groups
	postf("\n");

	// convert chords to midi notes
	(~mealy_machine.chords.do{
		arg item;
		var root_midi;
		var chord_progression = [];
		// find midi note of root of chord
		root_midi = ~mealy_machine.key_to_midi[item[0]];
		//root_midi.postln;
		item[1].do({
			arg func;
			//chord_progression = chord_progression.add(root_midi + ~mealy_machine.function_to_scale_degree_triad[func]);
			//~mealy_machine.midi_chord = ~mealy_machine.midi_chord.add(root_midi + ~mealy_machine.function_to_scale_degree_triad[func]);

			// adjust octaves depends on chord function
			if(func == \tonic || func == \supertonic || func == \mediant,
				{
					~mealy_machine.midi_chord = ~mealy_machine.midi_chord.add(root_midi + ~mealy_machine.function_to_scale_degree_triad[func]);

				},
				{
					if(func == \subdominant || func == \dominant,
						{
							chord_progression = root_midi + ~mealy_machine.function_to_scale_degree_triad[func];
							chord_progression[2] = chord_progression[2] + 12;
							~mealy_machine.midi_chord = ~mealy_machine.midi_chord.add(chord_progression);
						},
						// submediant
						{
							chord_progression = root_midi + ~mealy_machine.function_to_scale_degree_triad[func];
							chord_progression[1] = chord_progression[1] + 12;
							chord_progression[2] = chord_progression[2] + 12;
							~mealy_machine.midi_chord = ~mealy_machine.midi_chord.add(chord_progression);
						};
					);

				}
			);
			postf("% %\n", item[0], func);
		});
		postf("\n");
		//~mealy_machine.midi_chord = ~mealy_machine.midi_chord.add(chord_progression);
	};);

	// prepare to play
	~layer_1_pitch = [];
	~layer_2_pitch = [];
	~layer_3_pitch = [];
	~layer_1_rhythm = [];
	~layer_2_rhythm = [];
	~layer_3_rhythm = [];

	// function that generate pitch and rhythm arrays for alberti bass mode
	~play_alberti_bass = {
		~mealy_machine.midi_chord.do({
			arg item;
			// alberti bass pattern
			~layer_1_pitch = ~layer_1_pitch.add(item[0]);
			~layer_1_pitch = ~layer_1_pitch.add(item[1]);
			~layer_1_pitch = ~layer_1_pitch.add(item[2]);
			~layer_1_pitch = ~layer_1_pitch.add(item[1]);

			~layer_2_pitch = ~layer_2_pitch.add(\rest);
			~layer_3_pitch = ~layer_3_pitch.add(\rest);

			~layer_1_rhythm = ~layer_1_rhythm ++ [0.5, 0.5, 0.5, 0.5];
			~layer_2_rhythm = ~layer_2_rhythm.add(2);
			~layer_3_rhythm = ~layer_3_rhythm.add(2);
		});
	};

	// function that generate pitch and rhythm arrays for chord mode
	~play_chords = {
		~mealy_machine.midi_chord.do({
			arg item;
			~layer_1_pitch = ~layer_1_pitch.add(item[0]);
			~layer_2_pitch = ~layer_2_pitch.add(item[1]);
			~layer_3_pitch = ~layer_3_pitch.add(item[2]);
			~layer_1_rhythm = 2!~layer_1_pitch.size;
			~layer_2_rhythm = 2!~layer_2_pitch.size;
			~layer_3_rhythm = 2!~layer_3_pitch.size;
		});
	};

	// populate pitch and rhythm array based on input play_mode
	if (~play_mode == \alberti_bass,
		{~play_alberti_bass.()},
		{~play_chords.()}
	);

	// add final chord
	~final_chord = ~mealy_machine.midi_chord[~mealy_machine.midi_chord.size - 1];
	~layer_1_pitch = ~layer_1_pitch.add(~final_chord[0]);
	~layer_2_pitch = ~layer_2_pitch.add(~final_chord[1]);
	~layer_3_pitch = ~layer_3_pitch.add(~final_chord[2]);
	~layer_1_rhythm = ~layer_1_rhythm.add(2);
	~layer_2_rhythm = ~layer_2_rhythm.add(2);
	~layer_3_rhythm = ~layer_3_rhythm.add(2);

	// amplitude manipulation
	// add some variations in amplitude to make it sound more realistic
	~layer_1_amplitude = Array.fill(~layer_1_pitch.size, {0.2 + rrand(-0.05, 0.05)});
	~layer_2_amplitude = Array.fill(~layer_2_pitch.size, {0.2 + rrand(-0.05, 0.05)});
	~layer_3_amplitude = Array.fill(~layer_3_pitch.size, {0.2 + rrand(-0.05, 0.05)});

	// set tempo
	TempoClock.default.tempo = 110/60;

	// SynthDef: piano
	// Adapted from https://github.com/SCLOrkHub/SCLOrkSynths/blob/master/SynthDefs/keyboards/everythingRhodes.scd#L32
	(SynthDef(\piano, {
	arg
	//Standard Definitions
	out = 0, freq = 440, amp = 0.03, att = 0.001, rel = 3, pan = 0,
	//Other Controls
	filterRange = 2000, rq = 0.5, harmonic = 2.pow(33.5/12),
	//These Range from 0 to 1
	width = 0.2, mix = 0.7;

    //Electric Piano
	var snd, env, lfo;

	env = Env.perc(att, rel).kr(doneAction: 2); //Original used an ADSR envelope.

	snd = Pulse.ar(
	        	freq: freq * [1, harmonic], //Original used 33.5.midiratio here, which is just below the 7th harmonic.
	        	width: [width, width/2],
		        mul: [mix, (1 - mix)]
            );
	snd  = BLowPass4.ar(
		        in: snd,
		        freq: (filterRange * env) + (2 * freq),
		        rq: rq
		    );
    snd = Mix.ar(snd) * env * amp;

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Nick Collins, from Mitchell Sigman, 2011. http://www.sussex.ac.uk/Users/nc81/index.html",
	category: \keyboards,
	tags: [\rhodes, \piano, \pitched]
	)
).add);

	s.sync;

	// PLAY!
	Ppar([Pbind(\instrument, \piano, \midinote, Pseq(~layer_1_pitch, 1), \dur, Pseq(~layer_1_rhythm, 1), \amp, Pseq(~layer_1_amplitude, 1)),
		Pbind(\instrument, \piano, \midinote, Pseq(~layer_2_pitch, 1), \dur, Pseq(~layer_2_rhythm, 1), \amp, Pseq(~layer_2_amplitude, 1)),
		Pbind(\instrument, \piano, \midinote, Pseq(~layer_3_pitch, 1), \dur, Pseq(~layer_3_rhythm, 1), \amp, Pseq(~layer_3_amplitude, 1))]
	).play;

}
)