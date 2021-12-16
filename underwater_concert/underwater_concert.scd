/*
╭╮╱╭╮╱╱╱╱╭╮╱╱╱╱╱╱╱╱╱╱╱╱╭╮╱╱╱╱╱╱╭━━━╮╱╱╱╱╱╱╱╱╱╱╱╱╱╭╮
┃┃╱┃┃╱╱╱╱┃┃╱╱╱╱╱╱╱╱╱╱╱╭╯╰╮╱╱╱╱╱┃╭━╮┃╱╱╱╱╱╱╱╱╱╱╱╱╭╯╰╮
┃┃╱┃┣━╮╭━╯┣━━┳━┳╮╭╮╭┳━┻╮╭╋━━┳━╮┃┃╱╰╋━━┳━╮╭━━┳━━┳┻╮╭╯
┃┃╱┃┃╭╮┫╭╮┃┃━┫╭┫╰╯╰╯┃╭╮┃┃┃┃━┫╭╯┃┃╱╭┫╭╮┃╭╮┫╭━┫┃━┫╭┫┃
┃╰━╯┃┃┃┃╰╯┃┃━┫┃╰╮╭╮╭┫╭╮┃╰┫┃━┫┃╱┃╰━╯┃╰╯┃┃┃┃╰━┫┃━┫┃┃╰╮
╰━━━┻╯╰┻━━┻━━┻╯╱╰╯╰╯╰╯╰┻━┻━━┻╯╱╰━━━┻━━┻╯╰┻━━┻━━┻╯╰━╯
*/
// generated using https://fsymbols.com/generators/carty/

/*

No input required, run everything

underwater_concert_sample.mp3 is a sample output

*/

(
s.waitForBoot{

	//************* Global Variables *************//
	// https://www.julieswihart.com/chord-progressions-chart/
	~major_chord_progrerssion = [
		[\tonic, \subdominant, \submediant, \dominant], // I IV vi V
		[\tonic, \subdominant, \tonic, \dominant],      // I IV I  V
		[\tonic, \dominant, \subdominant, \dominant],   // I V  IV V
		[\tonic, \submediant, \subdominant, \dominant]  // I vi IV V
	];
	// https://beginnerguitarhq.com/minor-chord-progressions/
	~minor_chord_progrerssion = [
		[\tonic, \subdominant, \mediant, \submediant], // i iv III VI
		[\tonic, \subdominant, \submediant, \dominant], // i iv VI  v
		[\tonic, \submediant, \mediant, \subdominant] // I VI III iv
	];
	// circles of fifths
	~circle_major = [\F, \C, \G, \D, \A, \E, \B, \Gb, \Db, \Ab, \Eb, \Bb];
	~circle_minor = [\d, \a, \e, \b, \f_sharp, \c_sharp, \g_sharp, \eb, \bb, \f, \c, \g];

	// rhythm patterns for pluck
	~rhythms = [
		// Section I
		// relaxed
		[[0.5,0.5,0.25,0.5,0.25,0.5,0.25,0.75,1],
		 [0.25,0.75,1,0.25,0.25,0.25,0.25,0.5],
		 [0.5,0.5,0.25,0.5,0.25,0.5,0.25,0.75,1],
		 [0.25,0.75,1,0.25,0.25,0.25,0.25,0.5]],
		// lively
		[[0.25,0.25,0.25,0.75,0.5,0.25,0.25,0.25,0.25,0.25,0.25,0.75],
		 [0.25,0.25,0.25,0.25,0.25,1,0.25,0.25,0.25,0.25,0.5],
		 [0.25,0.25,0.25,0.75,0.5,0.25,0.25,0.25,0.25,0.25,0.25,0.75],
		 [0.25,0.25,0.25,0.25,0.25,1,0.25,0.25,0.25,0.25,0.5]],
		 // tragic transition
		[[0.25,0.25,Rest(1),0.25,0.25,Rest(0.01),0.33,0.33,0.33,Rest(0.01),0.33,0.33,0.33],
		 [Rest(0.01),0.33,0.33,0.33,Rest(0.5),0.5,Rest(0.75),0.25,Rest(0.5),0.25,0.25],
		 [0.25,0.25,Rest(1),0.25,0.25,Rest(0.01),0.33,0.33,0.33,Rest(0.01),0.33,0.33,0.33],
		 [Rest(0.01),0.33,0.33,0.33,Rest(0.5),0.5,Rest(0.75),0.25,Rest(0.5),0.25,0.25]],
		// chromatic transition
		[0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.5,0.25,0.5,0.5,0.35,Rest(1.65)],
		// Section II
		// melancholy
		[[0.5,0.5,0.5,0.5,0.5,0.5,1.5],
		 [0.5,0.5,0.5,1,1],
		 [0.5,0.5,0.5,0.5,0.5,0.5,1.5],
		 [0.5,0.5,0.5,1,1]],
		// regain hope
		[[0.5,0.5,0.5,0.5,0.5,0.5,1],
		 [0.5,0.5,0.5,0.5,0.5,0.25,0.25,1],
		 [0.5,0.5,0.5,0.5,0.5,0.5,1],
		 [0.5,0.5,0.5,0.5,0.5,0.25,0.25,1]],
		// Section III
		// courageous
		[[0.5,0.5,0.5,0.5,0.25,0.25,0.5,0.5,0.5],
		 [0.5,0.5,0.5,0.5,0.5,0.25,0.25,1],
		 [0.5,0.5,0.5,0.5,0.25,0.25,0.5,0.5,0.5],
		 [0.5,0.5,0.5,0.5,0.5,0.25,0.25,1]],
		// triumphant
		[[0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25],
		 [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25],
		 [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25],
		 [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25]],
		// ending measure
		[1,1,1,1,Rest(1),0.5,0.5,2] // tonic dominant tonic dominant tonic dominant tonic
	];

	// from chord function to scale degrees
	~major_triad = Dictionary.newFrom([\tonic, Scale.major.degrees.at([0,2,4]), \supertonic, Scale.major.degrees.at([1,3,5]), \mediant, Scale.major.degrees.at([2,4,6]), \subdominant, Scale.major.degrees.at([3,5,0]), \dominant, Scale.major.degrees.at([4,6,1]), \submediant, Scale.major.degrees.at([5,0,2]), \dominant7, Scale.major.degrees.at([4,6,3])]);

	~minor_triad = Dictionary.newFrom([\tonic, Scale.minor.degrees.at([0,2,4]), \supertonic, Scale.minor.degrees.at([1,3,5]), \mediant, Scale.minor.degrees.at([2,4,6]), \subdominant, Scale.minor.degrees.at([3,5,0]), \dominant, Scale.minor.degrees.at([4,6,1]), \submediant, Scale.minor.degrees.at([5,0,2])]);

	~mode_dic = Dictionary.newFrom([\major, ~major_triad, \minor, ~minor_triad]);

	// ordering of pitches, 0 -> tonic, 1 -> mediant, 2 -> dominant, 3 -> tonic an octave higher
	~pluck_patterns = [[0,1,2,1,3,1,2,1,0,1,2,1,3,2,3],[0,1,2,3,1,2,3,0,0,1,2,3,0,1,3,2], [0,3,1,3,2,3,1,3,0,3,2,3,1,3,2,3], [0,1,2,3,1,2,3,2,0,1,2,3,2,3,2,3]];

	// note name to midi number
	~key_to_midi = Dictionary.newFrom([\F, 65, \C, 60, \G, 67, \D, 62, \A, 69, \E, 64, \B, 71, \Gb, 66, \Db, 61, \Ab, 68, \Eb, 63, \Bb, 70]);
	// minor note name to major note name
	~minor_to_major = Dictionary.newFrom([\d, \D, \a, \A, \e, \E, \b, \B, \f_sharp, \Gb, \c_sharp, \Db, \g_sharp, \Ab, \eb, \Eb, \bb, \Bb, \f, \F, \c, \C, \g, \G]);

	// rhythm patterns for flute & piano
	~section_I_rhythms = [[[1.5,2,1],[1,0.5,1,1]],[[0.5,0.5,1.5,1,1],[1.5,0.5,1.5]]];
	~section_II_rhythms = [[[4],[4]]];
	~section_III_rhythms = [[[0.5,1,1,1,0.5],[0.5,0.5,1.5,0.5,1]], [[1.5,1,1,1],[0.5,1.5,0.5,1]]];

	~rhythm_dic = Dictionary.newFrom([0, ~section_I_rhythms, 1, ~section_II_rhythms, 2, ~section_III_rhythms]);

	// keep track of current states (section, key, etc)
	~state = (
		current_rhythm: -1,
		current_key: -1,
		current_section: 0,
		chord_progression: [], // tuple of (key, chord_progression, rhythm_index)
		mode: -1, // major or minor
		current_index: -1,
		cumulative_duration: 0,
		section_durations: []
	);

	/********************* Auxiliary Functions *********************/
	// create pitch & amplitude arrays for pluck
	(~populate_rhythm = {
		arg key, progressions, rhythms;
		var pitch = [];
		var amplitude = [];
		// pitch array
		var root;
		var mode;
		var triad;
		var triads = [];
		var pluck_pattern;
		var rhythm;
		var counter;
		var phrasing;

		// find mode: major/minor
		if (~circle_major.indexOf(key) != nil, {mode = \major}, {mode = \minor});

		// find root midi note
		if (mode == \minor, {root = ~key_to_midi[~minor_to_major[key]]}, {root = ~key_to_midi[key]});

		// find all triads
		progressions.do({
			arg progression;
			triad = root + ~mode_dic[mode][progression];
			triad = triad.add(root + 12);
			// correct octaves
			if (progression == \subdominant, triad[2] = triad[2] + 12);
			if (progression == \dominant || progression == \dominant7, { triad[0] = triad[0] - 12; triad[1] = triad[1] - 12; triad[2] = triad[2] - 12;});
			if (progression == \submediant, {triad[0] = triad[0] - 12; triad[2] = triad[2] - 12;});
			triads = triads.add(triad);
		});

		// randomly select a ordering sequence for the 4 triad notes
		pluck_pattern = ~pluck_patterns.choose;

		// fill rhythms with pitches
		triads.do({
			arg triad, i;
			rhythm = rhythms[i];
			counter = 0;
			rhythm.do ({
				arg note;
				if (note.class() != Rest, {
					pitch = pitch.add(triad[pluck_pattern.wrapAt(counter)]);
					counter = counter + 1;
				},
				{
					pitch = pitch.add(note)
				});
			});
		});

		amplitude = Array.fill(pitch.size, {0.5 + rrand(-0.05, 0.05)});
		phrasing = (1..5) ++ (2..4).reverse() / 100; // a little swell in phrasing
		amplitude = amplitude + phrasing;

		[pitch, amplitude]
	});

	// get ending measure pitch & amplitude arrays
	(~get_end = {
		arg key;
		var tonic_root, tonic_chord, dominant_chord;
		var amplitude, crescendo;
		var num = 8;

		// tonic
		tonic_root = ~key_to_midi[key];
		tonic_chord = tonic_root + ~major_triad[\tonic];
		tonic_chord = tonic_chord.add(tonic_root + 12);
		tonic_chord = tonic_chord - 12;

		// dominant
		dominant_chord = tonic_root + ~major_triad[\dominant];
		dominant_chord = dominant_chord.add(dominant_chord[0] + 12);
		dominant_chord[0] = dominant_chord[0] - 12;
		dominant_chord[1] = dominant_chord[1] - 12;
		dominant_chord[3] = dominant_chord[3] - 12;
		dominant_chord = dominant_chord - 12;

		amplitude = Array.fill(num, {0.5 + rrand(-0.05, 0.05)});
		crescendo = (1..num) / 100;
		amplitude = amplitude + crescendo;

		[[tonic_chord, dominant_chord, tonic_chord, dominant_chord, Rest(0.5), tonic_chord, dominant_chord, tonic_chord], amplitude]
	});

	// create pitch & amplitude arrays for chromatic section of length num
	(~get_chromatic = {
		arg num;
		var amplitude, crescendo;
		// pick a random start note
		var start_note = (60..71).choose;
		// pitch array
		var primary = (start_note - 24..start_note - 24 + num - 2).reverse(); // descending chromatic scale for more tension, lower 2 octaves
		// entry of 2nd desccending chromatic scale after 4 notes, increase tension
		var secondary = [];

		primary.do({
			arg item, index;
			if (index < 4, {secondary = secondary.add(item);}, {secondary = secondary.add([item, item - 1]);});
		});

		// create random crescendo amplitudes
		amplitude = Array.fill(num, {0.55 + rrand(-0.05, 0.05)});
		crescendo = (1..num) / 100;
		amplitude = amplitude + crescendo;

		[secondary.add(Rest(1.65)), amplitude]
	};);

	// find total number of beats in given rhythm array
	(~find_duration = {
		arg array;
		var total = 0;
		array.do({
			arg item;
			if (item.class() == Rest,
				{total = total + item.value},
				{total = total + item}
			)
		});
		total
	});

	// get list of triads
	(~find_chords = {
		arg key, progressions, mode;
		var chords = [];
		var root;
		var triad;

		if (mode == \minor, {root = ~key_to_midi[~minor_to_major[key]]}, {root = ~key_to_midi[key]});

		// find all chords
		progressions.do({
			arg progression;
			triad = root + ~mode_dic[mode][progression];
			chords = chords.add(triad);
		});
		chords
	});

	//****************** Pluck Arrays ******************//
	~pluck_pitch = [];
	~pluck_rhythm = [];
	~pluck_amplitude = [];

	//****************** Melody Arrays ******************//
	~flute_pitch = [];
	~flute_rhythm = [];
	~flute_amplitude = [];
	~piano_pitch = [];
	~piano_rhythm = [];
	~piano_amplitude = [];

	//****************** Compose Pluck Accompaniment ******************//
	// randomly pick start key
	~start_key = ~circle_major.choose;
	// uncomment the line below is custom start key is desired
	//~start_key = \C;

	// set initial states
	~state.current_key = ~start_key;
	~state.mode = \major;
	~state.current_index = ~circle_major.indexOf(~start_key);
	postf("Start key: %\n", ~state.current_key);

	// add operations
	// ~operations can be customized to complement different stories, this set of operations is designed to fit my story
	~operations = [
		// Section I
		\next_rhythm, // relaxed
		\generate, \silence_4,
		\generate, \flute_solo,
		\generate, \piano_solo,
		\generate, \duet,
		\next_rhythm, // lively
		\generate, \silence_4,
		\generate, \piano_solo,
		\tonicize, \silence_4,
		\generate, \duet,
		// transition
		\next_rhythm, // tragic transition
		\modulate_left_major, \silence_4,
		\next_rhythm, // chromatic
		\chromatic, \silence_2,
		\modulate_left_minor_no_progression,
		\change_mode,
		\end_section,
		// Section II
		\next_rhythm, // melancholy
		\generate, \silence_4,
		\generate, \duet,
		\generate, \flute_solo,
		\generate, \flute_solo,
		\next_rhythm, // regain hope
		\generate, \duet,
		\generate, \piano_solo,
		\generate, \piano_solo,
		\modulate_right_2_major, \change_mode, \silence_4,
		\end_section,
		// Section III
		\next_rhythm, // courageous
		\generate, \duet,
		\generate, \flute_solo,
		\generate, \piano_solo,
		\generate, \silence_4,
		\next_rhythm, // triumphant
		\generate, \piano_solo,
		\generate, \duet,
		\generate, \duet,
		\generate, \flute_solo,
		\next_rhythm, // end
		\end,
		\end_section
	];

	// process operations
	(~operations.do({
		arg item;
		switch (item,
			\next_rhythm, {
				~state.current_rhythm = ~state.current_rhythm + 1;
			},
			\generate, {
				// check major/minor
				if (~state.mode == \major,
					{
						// current key is major
						~state.chord_progression = ~state.chord_progression.add([~state.current_key,
							                                                     ~major_chord_progrerssion.choose(),
							                                                     ~rhythms[~state.current_rhythm]]); // [key, progression, rhythm] tuple
					},
					{
						// current key is minor
						~state.chord_progression = ~state.chord_progression.add([~state.current_key,
							                                                     ~minor_chord_progrerssion.choose(),
							                                                     ~rhythms[~state.current_rhythm]]);
				})
			},
			\tonicize, {
				// add progression in right neighbor key, but does not change state
				~state.chord_progression = ~state.chord_progression.add([~circle_major.wrapAt(~state.current_index + 1),
					                                                    [\subdominant, \subdominant, \dominant7, \tonic],
					                                                    ~rhythms[~state.current_rhythm]]);
			},
			\modulate_left_major, {
				~state.current_index = ~state.current_index - 1;
				~state.current_key = ~circle_major.wrapAt(~state.current_index);
				~state.current_index = ~circle_major.indexOf(~state.current_key);
				// pivot chords - V - I, all in new keys
				~progression = [\mediant, \submediant].scramble ++ [\dominant, \tonic];
				~state.chord_progression = ~state.chord_progression.add([~state.current_key,
					                                                     ~progression,
					                                                     ~rhythms[~state.current_rhythm]]);
			},
			\chromatic, {
				~state.chord_progression = ~state.chord_progression.add([\chromatic,
					                                                     nil,
					~rhythms[~state.current_rhythm]]);
			},
			\modulate_left_minor_no_progression, {
				// change to new key after a brief silence, no progression needed
				~state.current_index = ~state.current_index - 1;
				~state.current_key = ~circle_minor.wrapAt(~state.current_index);
				~state.current_index = ~circle_minor.indexOf(~state.current_key);
			},
			\modulate_right_2_major, {
				~state.current_index = ~state.current_index + 1;
				~state.current_key = ~circle_major.wrapAt(~state.current_index);
				~state.current_index = ~circle_major.indexOf(~state.current_key);
				// pivot chords - V - I, all in new keys
				~progression = [\supertonic, \subdominant].scramble ++ [\dominant, \tonic];
				~state.chord_progression = ~state.chord_progression.add([~state.current_key,
					                                                     ~progression,
					                                                     ~rhythms[~state.current_rhythm]]);
			},
			\end, {
				~state.chord_progression = ~state.chord_progression.add([~state.current_key,
					                                                     \end,
					                                                     ~rhythms[~state.current_rhythm]])
			},
			\change_mode, {
				if (~state.mode == \major,
					{~state.mode = \minor}, // change to major
					{~state.mode = \major}  // change to minor
				)
			},
			\end_section, {
				~state.chord_progression = ~state.chord_progression.add([\end_section, nil, nil]);
				~state.current_section = ~state.current_section + 1;
			},
			\silence_4, {
				// 4 measures of silence for melodies
				~flute_pitch = ~flute_pitch ++ [Rest(16)];
				~flute_rhythm = ~flute_rhythm ++ [Rest(16)];
				~piano_pitch = ~piano_pitch ++ [Rest(16)];
				~piano_rhythm = ~piano_rhythm ++ [Rest(16)];
			},
			\silence_2, {
				// 2 measures of silence for melodies
				~flute_pitch = ~flute_pitch ++ [Rest(8)];
				~flute_rhythm = ~flute_rhythm ++ [Rest(8)];
				~piano_pitch = ~piano_pitch ++ [Rest(8)];
				~piano_rhythm = ~piano_rhythm ++ [Rest(8)];
			},
			\flute_solo, {
				~current_progression = ~state.chord_progression[~state.chord_progression.size - 1][1];
				~roots = ~find_chords.(~state.current_key, ~current_progression, ~state.mode);

				// choose two rhythms from corresponding section
				~r = Array.fill(2, {~rhythm_dic[~state.current_section].choose});
				~r = [~r[0][0], ~r[0][1], ~r[1][0], ~r[1][1]];

				~flute_pitch = ~flute_pitch ++ (~roots[0]!~r[0].size) ++ (~roots[1]!~r[1].size) ++ (~roots[2]!~r[2].size) ++ (~roots[3]!~r[3].size);
				~flute_rhythm = ~flute_rhythm ++ ~r.flatten;

				~piano_pitch = ~piano_pitch ++ [Rest(16)];
				~piano_rhythm = ~piano_rhythm ++ [Rest(16)];
			},
			\piano_solo, {
				~current_progression = ~state.chord_progression[~state.chord_progression.size - 1][1];
				~roots = ~find_chords.(~state.current_key, ~current_progression, ~state.mode);
				~roots = ~roots - 12;

				// choose two rhythms from corresponding section
				~r = Array.fill(2, {~rhythm_dic[~state.current_section].choose});
				~r = [~r[0][0], ~r[0][1], ~r[1][0], ~r[1][1]];

				~piano_pitch = ~piano_pitch ++ (~roots[0]!~r[0].size) ++ (~roots[1]!~r[1].size) ++ (~roots[2]!~r[2].size) ++ (~roots[3]!~r[3].size);
				~piano_rhythm = ~piano_rhythm ++ ~r.flatten;

				~flute_pitch = ~flute_pitch ++ [Rest(16)];
				~flute_rhythm = ~flute_rhythm ++ [Rest(16)];
			},
			\duet, {
				~current_progression = ~state.chord_progression[~state.chord_progression.size - 1][1];
				~roots = ~find_chords.(~state.current_key, ~current_progression, ~state.mode);

				// choose two rhythms from corresponding section for flute
				~r = Array.fill(2, {~rhythm_dic[~state.current_section].choose});
				~r = [~r[0][0], ~r[0][1], ~r[1][0], ~r[1][1]];

				~flute_pitch = ~flute_pitch ++ (~roots[0]!~r[0].size) ++ (~roots[1]!~r[1].size) ++ (~roots[2]!~r[2].size) ++ (~roots[3]!~r[3].size);
				~flute_rhythm = ~flute_rhythm ++ ~r.flatten;

				~roots = ~roots - 12;
				// choose two rhythms from corresponding section for piano
				~r = Array.fill(2, {~rhythm_dic[~state.current_section].choose});
				~r = [~r[0][0], ~r[0][1], ~r[1][0], ~r[1][1]];

				~piano_pitch = ~piano_pitch ++ (~roots[0]!~r[0].size) ++ (~roots[1]!~r[1].size) ++ (~roots[2]!~r[2].size) ++ (~roots[3]!~r[3].size);
				~piano_rhythm = ~piano_rhythm ++ ~r.flatten;
			},
			{
				"invalid operation".postln();
				item.postln();
			};
	)}););

	// musicians/I can refer to this output to improvise on top
	// ~state.chord_progression.postln();
	~state.chord_progression.do ({
		arg item;
		item.postln;
	});

	// expand chord progession to playable arrays
	(~state.chord_progression.do ({
		arg item;

		var key = item[0];
		var progression = item[1];
		var rhythm = item[2];

		if (key == \chromatic,
			{
				~chromatic_arrays = ~get_chromatic.(rhythm.size);
				~pluck_pitch = ~pluck_pitch ++ ~chromatic_arrays[0];
				~pluck_rhythm = ~pluck_rhythm ++ rhythm.flatten();
				~pluck_amplitude = ~pluck_amplitude ++ ~chromatic_arrays[1];
			}
		);
		if (key == \end_section,
			{
				// end of section, update accumulative_duration & section_durations
				// this is to determine the number of beats of section for percussion
				// different sections have different beat patterns
				~current_total = ~find_duration.(~pluck_rhythm);
				~state.section_durations = ~state.section_durations.add(~current_total - ~state.cumulative_duration);
				~state.cumulative_duration = ~current_total;
			}
		);
		if (progression == \end,
			{
				~end_arrays = ~get_end.(key);
				~pluck_pitch = ~pluck_pitch ++ ~end_arrays[0];
				~pluck_rhythm = ~pluck_rhythm ++ rhythm;
				~pluck_amplitude = ~pluck_amplitude ++ ~end_arrays[1];
			}
		);
		if (((key != \chromatic) && (progression != \end) && (key != \end_section)),
			{
				~arrays = ~populate_rhythm.(key, progression, rhythm);
				~pluck_pitch = ~pluck_pitch ++ ~arrays[0];
				~pluck_rhythm = ~pluck_rhythm ++ rhythm.flatten();
				~pluck_amplitude = ~pluck_amplitude ++ ~arrays[1];
			}
		);

	}));

	//****************** Sound Effect Arrays ******************//
	~bubble1 = [];
	~bubble2 = [];
	~waterdrop = [];

	// an estimate of the number of plays
	~estimate = round(~pluck_rhythm.size / 5);

	//************** Compose Sound Effect **************//
	// stochatically determine existence arrays
	~estimate.do({
		arg index;
		var existence, value;
		// should bubble 1 be played?
		existence = [0, 1].wchoose([0.7, 0.3]);
		value = 2 + 1.0.sum3rand; // add a little variation in amplitude values
		if (existence == 1, {~bubble1 = ~bubble1.add(value)}, {~bubble1 = ~bubble1.add(Rest(value))});
		// should bubble 2 be played?
		existence = [0, 1].wchoose([0.4, 0.6]);
		value = 2 + 1.sum3rand;
		if (existence == 1, {~bubble2 = ~bubble2.add(value)}, {~bubble2 = ~bubble2.add(Rest(value))});
		// should there be a water drop?
		existence = [0, 1].wchoose([0.8, 0.2]);
		value = 2 + 1.0.sum3rand;
		if (existence == 1, {~waterdrop = ~waterdrop.add(value)}, {~waterdrop = ~waterdrop.add(Rest(value))});
	});

	//****************** Percussion Arrays ******************//
	~closedhh = [];
	~closedhh_amplitude = [];

	//************** Compose Percussions **************//
	~sec1_dur = ~state.section_durations[0] - 2; // last ~2 beats = silence after tragic transition
	~sec2_dur = ~state.section_durations[1];
	~sec3_dur = ~state.section_durations[2];

	// differences lie in ~note values (durations of each hi-hat hit) and their respective probabilities
	// compose Section I percussion - relaxed
	~cur = 0;
	while({~cur < ~sec1_dur},
		{
			~note = [0.25, 0.5, 1].wchoose([0.5, 0.6, 0.4].normalize);
			~note = min(~note, ~sec1_dur - ~cur);
			~closedhh = ~closedhh.add(~note);
			~cur = ~cur + ~note;
			// randomly decide whether a note should be accented
			~accent = [0, 1].wchoose([0.7, 0.3]);
			if (~accent == 1,
				{~closedhh_amplitude = ~closedhh_amplitude.add(0.75 + rrand(-0.01, 0.01))},
				{~closedhh_amplitude = ~closedhh_amplitude.add(0.55 + rrand(-0.01, 0.01))}
			)
		}
	);
	~closedhh = ~closedhh.add(Rest(2));

	// compose Section II percussion - melancholy
	~cur = 0;
	while({~cur < ~sec2_dur},
		{
			~note = [0.5, 1].wchoose([0.4, 0.6].normalize);
			~note = min(~note, ~sec2_dur - ~cur);
			~closedhh = ~closedhh.add(~note);
			~cur = ~cur + ~note;
			// randomly decide whether a note should be accented
			~accent = [0, 1].wchoose([0.7, 0.3]);
			if (~accent == 1,
				{~closedhh_amplitude = ~closedhh_amplitude.add(0.60 + rrand(-0.01, 0.01))},
				{~closedhh_amplitude = ~closedhh_amplitude.add(0.40 + rrand(-0.01, 0.01))}
			)
		}
	);

	// compose Section III percussion - agitated
	~cur = 0;
	while({~cur < ~sec3_dur},
		{
			~note = [0.125, 0.25, 0.5].wchoose([0.45, 0.6, 0.3].normalize);
			~note = min(~note, ~sec3_dur - ~cur);
			~closedhh = ~closedhh.add(~note);
			~cur = ~cur + ~note;
			// randomly decide whether a note should be accented
			~accent = [0, 1].wchoose([0.7, 0.3]);
			if (~accent == 1,
				{~closedhh_amplitude = ~closedhh_amplitude.add(0.85 + rrand(-0.01, 0.01))},
				{~closedhh_amplitude = ~closedhh_amplitude.add(0.65 + rrand(-0.01, 0.01))}
			)
		}
	);

	// complete flute & piano amplitude arrays
	~flute_amplitude = Array.fill(~flute_pitch.size, {0.5 + rrand(-0.25, 0.25)});
	~piano_amplitude = Array.fill(~piano_pitch.size, {0.5 + rrand(-0.25, 0.25)});

	//************** SynthDefs & Buffers **************//
	// SynthDef: guitar
	// Adapted from https://github.com/SCLOrkHub/SCLOrkSynths/blob/master/SynthDefs/guitar/pluck.scd
	(SynthDef("pluck", {arg amp = 0.43, freq = 440, decay = 5, coef = 0.1, pan = 0;
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

	// sound effect buffer
	b = [\bubble1, \bubble2, \waterdrop, \closedhh].collect{|val| Buffer.read(s,(val++".wav").resolveRelative) };

	// a very simple sample-playing instrument.
	SynthDef(\playBuf,
		{ |buffer, start = 0, dur = 2, amp = 0.15|
			var sig = PlayBuf.ar(2, buffer,startPos: start, loop: 0);
			var env = EnvGen.kr(Env.linen(0.01,dur,0.01,level:amp),doneAction:2);
			Out.ar(0,(sig*env) !2);
		}
	).add;

	// uncomment the following line to hear each sample
	//Synth(\playBuf, [\buffer, b[3]]);

	// SynthDef: flute
	// Adapted from https://github.com/everythingwillbetakenaway/Synthdefs/blob/master/solo.scd
	(SynthDef(\flute, { | amp=0.8 out=0 gate=1 freq=90  |
		var aEnv, fEnv, osc, flt;
		aEnv = EnvGen.kr(Env.asr(0.2, 1, 2), gate);
		fEnv = EnvGen.kr(Env.adsr(0.4, 1.2, 0.7, 2), gate, 800);
		osc = Saw.ar(Lag.kr(freq, 0.1) * [1, 1.005], amp); // add amplitude
		flt = LPF.ar(osc, fEnv + 800, aEnv);
		Out.ar(out, flt);
	}).add;
	);

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

	//************** Performance **************//
	s.sync;
	TempoClock.default.tempo = 105/60;

	Ppar([
		//pluck
		Pbind(\instrument, \pluck, \midinote, Pseq(~pluck_pitch, 1), \dur, Pseq(~pluck_rhythm, 1), \amp, Pseq(~pluck_amplitude, 1)),
		// bubble 1
		Pbind(\instrument, \playBuf, \dur, Pseq(~bubble1, 1), \buffer, b[0], \amp, 0.10),
		// bubble 2
		Pbind(\instrument, \playBuf, \dur, Pseq(~bubble2, 1), \buffer, b[1], \amp, 0.10),
		// waterdrop 3
		Pbind(\instrument, \playBuf, \dur, Pseq(~waterdrop, 1), \buffer, b[2], \amp, 0.50),
		// cloasedhh
		Pbind(\instrument, \playBuf, \dur, Pseq(~closedhh, 1), \buffer, b[3], \amp, Pseq(~closedhh_amplitude, 1)),
		// flute
		Pbind(\instrument, \flute, \midinote, Pseq(~flute_pitch, 1), \dur, Pseq(~flute_rhythm, 1), \amp, Pseq(~flute_amplitude, 1)),
		// piano
		Pbind(\instrument, \piano, \midinote, Pseq(~piano_pitch, 1), \dur, Pseq(~piano_rhythm, 1), \amp, Pseq(~piano_amplitude, 1))
	]).play;
})