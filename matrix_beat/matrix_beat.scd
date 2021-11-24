// A program that takes in an array of beat elements and perform various transformations on the input to produce an extended segment of beat patterns

// run everything will play default piece
(
s.waitForBoot {

	// function to get user input
	~get_input = {
		// Default argument values
		arg beat_pattern = [\kick,\closedhh,\snare,\kick,\kick,\closedhh,\snare,\closedhh],
		transformations = [["forward"], ["backward"], ["inverse"], ["shift -4"], ["repeat 3"], ["backward", "inverse", "shift -4"], ["scramble"], ["rotate -2"], ["swap 0 1"], ["accumulate"], ["index_product"],["backward", "swap 2 4", "rotate +2", "shift +2", "scramble"]],
		tempo = 135,
		sample_pitch = 1,
		solo=True,
		pan_list=[0, 0, 0, 1, 0, 1, 1],
		pickup = True;
		[beat_pattern, transformations, tempo, sample_pitch, solo, pan_list, pickup]
	};

	/*
	Arguments:
	    beat_pattern: a list of beat element, transformations will be done on this pattern
	    transformations: a list of transformations
	    tempo: # of beats per minute
	    sample_pitch: pitch adjustment
	    solo: boolean value, whether to append a four-measure solo at the end of all transformations
	    pan_list: a list of length 7, each element corresponds to the pan control for the sample
	    pick_up: boolean value, whether to start with a 2-beat pickup

	   SEE INPUT EXAMPLES BELOW with more detailed explanations of argument input
	*/

	// EXAMPLE INPUTS //

	/*
	  DEFAULT mode:
	      beat_pattern = [\kick,\closedhh,\snare,\kick,\kick,\closedhh,\snare,\closedhh]
	              -> a list of beat elements
	              -> choices are {\crash, \openhh, \closedhh, \kick, \snare, \tom1, \tom2}

	      transformations = [["forward"], ["backward"], ["inverse"], ["shift -4"], ["repeat 3"], ["backward", "inverse", "shift -4"], ["scramble"], ["rotate -2"], ["swap 0 1"], ["accumulate"], ["index_product"],["backward", "swap 2 4", "rotate +2", "shift +2", "scramble"]]
	              -> a list of transformations
	              -> choices are:
	                  - forward: same as input pattern
	                  - backward: reverse of input pattern
		              - inverse: inverse of input pattern
	                  - shift +/- degree: 'modulation' ie move to another row in matrix
	                  - repeat start_index: repeat from start_inde-th transformation through end of current passage
	can repeat a section or a measure, in this example, ["shift -4"] is repeated
	                  - scramble: shuffle element in input pattern
	                  - rotate degree: shift the values in input pattern to the right/left by degree elements
	                  - swap i j: swap i-th element with j-th element in input pattern
	                  - accumulate: sum each element with the previous element
	                  - index_product: multiply each element by its index + 1
	                  - any permutation: each individual transformation should be written as a string, with space between arguments if there are any
	                                     each complete transformation should be in a list
	                                     ["inverse"] will generate the inverse of input_pattern
	                                     ["backward", "inverse", "shift -4"] will shift, invert and reverse the input pattern,
	                                                                         producing output same length as input pattern
		tempo = 130
		sample_pitch = 1
	        -> pitch variation of samples, rate argument for PlayBug.ar, 2 for one octave higher, etc
		solo=True,
	        -> if True, a randomly generated 4-measure drum solo will be appended to the end of all transformations
		pan_list=[0,       0,       0,         1,     0,      1,     1]
	        ->    [\crash, \openhh, \closedhh, \kick, \snare, \tom1, \tom2] indices corresponding to each element
	        -> location for each sample
		pickup = True;
	        -> if True, a 2-beat pick up fill is appended before all transformations happen
	*/

	/* DEFAULT input */
	~input = ~get_input.value();

	/* Example 1 of customized input */
	// ~input= ~get_input.value(beat_pattern: [\crash,\closedhh,\snare,\tom1,\kick,\tom2,\snare,\openhh], transformations: [["forward"], ["backward"], ["inverse"], ["shift +2"], ["backward", "inverse", "shift +2"], ], tempo: 150, sample_pitch: 2, solo: False, pan_list: [1, 1, 1, 1, 0, 0, 0, 0], pickup: False);

	/* Example 2 of customized input: solo nspection */
	//~input= ~get_input.value(beat_pattern: [\kick,\closedhh,\snare,\closedhh,\kick,\closedhh,\snare,\closedhh], transformations: [["forward"]], tempo: 120, solo: True);


	// from sampleswap.org and https://github.com/tidalcycles/Dirt-Samples
	b = [\crash, \openhh, \closedhh, \kick, \snare, \tom1, \tom2].collect{|val| Buffer.read(s,(val++".wav").resolveRelative) };

	~sample_pitch = ~input[3];

	// a very simple sample-playing instrument.
	SynthDef(\playBuf,
		{ |buffer, start = 0, dur = 0.25, amp = 1|
			var sig = PlayBuf.ar(2,buffer,startPos: start, loop: 0, rate: ~sample_pitch);
			var env = EnvGen.kr(Env.linen(0.01,dur,0.01,level:amp),doneAction:2);
			//Out.ar(0,(sig*env) !2);
			~pan_list = ~input[5];
			Out.ar(0, Pan2.ar(sig, ~pan_list, env));
		}
	).add;

	// hear individual element
	//Synth(\playBuf, [\buffer, b[6]]);

	/*==================================================================================================================*/
	/* Auxiliary Functions */

	~fixed_degrees = (0..6); // degrees of beat elements
	~beat_to_num = Dictionary.newFrom([\crash, 0, \openhh, 1, \closedhh, 2, \kick, 3, \snare, 4, \tom1, 5, \tom2, 6]);
	~num_to_beat = Dictionary.newFrom([0, \crash, 1, \openhh, 2, \closedhh, 3, \kick, 4, \snare, 5, \tom1, 6, \tom2]);

	// convert beat element to numbers
	~convert_to_num = {
		arg beat;
		var output;
		output = beat.collect({arg item, i; ~beat_to_num[item]});
		output
	};
    // convert numbers to beat elements
	~convert_to_beat = {
		arg nums;
		var output;
		output = nums.collect({arg item, i; ~num_to_beat[item]});
		output
	};
	// forward transformation: identity function for neatness
	~get_forward = {
		arg beat_pattern;
		beat_pattern
	};
	// backward transformation: reverse input array
	~get_backward = {
		arg beat_pattern;
		beat_pattern.reverse
	};
	// inversion transformation
	~get_inverted = {
		arg beat_pattern;

		var steps = []; // intervals in beat_pattern
		var inverse_steps; // intervals for inverse
		var inverse_nums = []; // inverse nums

		// get intervals
		for(1, beat_pattern.size - 1, {arg i; steps = steps.add(beat_pattern[i] - beat_pattern[i-1])});
		// get inverse intervals
		inverse_steps = steps * (-1);
		// get inverse nums corresponding to beat elements
		inverse_nums = [beat_pattern[0]];
		for(0, inverse_steps.size - 1, {arg i; inverse_nums = inverse_nums.add(~fixed_degrees.wrapAt(inverse_nums[i] + inverse_steps[i]))});
		inverse_nums
	};
	// shift transformation
	~get_shifted = {
		arg beat_pattern, interval;
		var output = [];
		for(0, beat_pattern.size - 1, {arg i; output = output.add(~fixed_degrees.wrapAt(beat_pattern[i] + interval))});
		output
	};
	// scramble transformation
	~get_scrambled = {
		arg beat_pattern;
		beat_pattern.scramble
	};
	// rotate transformation
	~get_rotated = {
	    arg beat_pattern, distance;
		beat_pattern.rotate(distance)
	};
	// swap transformation
	~get_swapped = {
		arg beat_pattern, index_1, index_2;
		beat_pattern.swap(index_1, index_2)
	};
	// accumulate transformation
	~get_accumulation = {
		arg beat_pattern;
		var output = [beat_pattern[0]];
		// sum two consecutive numbers: output[i] = beat_pattern[i-1] + beat_pattern[i];
		for (1, beat_pattern.size-1, {arg i; output = output.add(~fixed_degrees.wrapAt(beat_pattern[i - 1] + beat_pattern[i]))});
		output
	};
	// multiply each element by its index + 1
	~get_index_product = {
		arg beat_pattern;
		var output = [];
		// multiply each element by its index + 1
		beat_pattern.do({arg item, i; output = output.add(~fixed_degrees.wrapAt(item * (i + 1)))});
		output
	};
	// generate a random 2-beat drum fill
	~get_fill = {
		var selected_rhythm;
		var elements = [];
		//               3     n     a     4     e     n    a       3    n     4    e     a      3     n     a    4     e     n
		var rhythms = [[0.5, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25], [0.5, 0.5, 0.25, 0.5, 0.25], [0.5, 0.25, 0.25, 0.25, 0.25, 0.5]];
		// select a random rhythm pattern
		selected_rhythm = rhythms.choose();
		// populate rhythm with snare, tom1, tom2
		(selected_rhythm.size).do({elements = elements.add([\snare, \tom1, \tom2].choose)});
		// return elements and their corresponding durations
		[elements, selected_rhythm]
	};
	// generate 4 measures of 4-beat solo
	~get_solo = {
		// a bunch of eighth/sixteeth notes/rest
		var rhythm = [0.25].dupEach(16) ++ [0.5].dupEach(8) ++ [Rest(0.25)].dupEach(16) ++ [Rest(0.5)].dupEach(8);
		// crash does not participate in solo, except for the downbeat of first measure of solo
		~crash_start = ~crash_start ++ [0.25] ++ [Rest(0.25)].dupEach(31);
		~crash = ~crash ++ [Rest(0.5)].dupEach(32) ++ 2.0; // end entire piece with a lingering crash
		// for each element, scramble rhythm pattern to populate solo, different elements playing simultaneously
		~closedhh = ~closedhh ++ rhythm.scramble();
		~kick = ~kick ++ rhythm.scramble();
		~openhh = ~openhh ++ rhythm.scramble();
		~snare = ~snare ++ rhythm.scramble();
		~tom1 = ~tom1 ++ rhythm.scramble();
		~tom2 = ~tom2 ++ rhythm.scramble();
	};
	/*==================================================================================================================*/
	/* End of Auxiliary Functions */

    /*==================================================================================================================*/
	/* Start Transformations */

	~input_pattern = ~input[0];
	// convert to nums
	~input_pattern = ~convert_to_num.(~input_pattern);
	~transformations = ~input[1];
	~tempo = ~input[2];

	t = TempoClock.default; // the default clock
	t.tempo = ~tempo/60;

	~input_pattern.postln;
	~transformations.postln;
	~tempo.postln;

	// matrix of transformed patterns
	~beat_pattern = [];

	~crash_start = List[];
	~crash = List[];
	~openhh = List[];
	~closedhh = List[];
	~kick = List[];
	~snare = List[];
	~tom1 = List[];
	~tom2 = List[];

	// map transformation string to actual transformation function
	~transformations_map = Dictionary.newFrom(["forward", ~get_forward, "backward", ~get_backward, "inverse", ~get_inverted, "scramble", ~get_scrambled, "accumulate": ~get_accumulation, "index_product": ~get_index_product]);

	// apply transformations to ~input_pattern and add to matrix
	~transformations.do(
		{
			arg current_set, i;

			var is_repeat = 0;
			var transformed =  ~input_pattern.copy();
			var arg_list;
			var end_index = ~beat_pattern.size - 1;

			current_set.reverseDo(
				{
					arg t, j;
					arg_list = t.split($ );
					switch (arg_list[0],
						// each transformation repeated 4 times to form 4-bar phrases
						"shift", {transformed = ~get_shifted.(transformed, arg_list[1].asInteger);},
						"rotate", {transformed = ~get_rotated.(transformed, arg_list[1].asInteger);},
						"swap", {transformed = ~get_swapped.(transformed, arg_list[1].asInteger, arg_list[2].asInteger);},
						"repeat", { is_repeat = 1;
							for (arg_list[1].asInteger, end_index, {arg i;  ~beat_pattern = ~beat_pattern.add(~beat_pattern[i]);});},
						// default, use ~transformation map
						{transformed = ~transformations_map[t].(transformed);}
					);
 				}
			);
			// 4-bar phrase
			if (is_repeat == 0, {~beat_pattern = ~beat_pattern.add(transformed ++ transformed ++ transformed ++ transformed);});
		}
	);

	// get number of drum fills
	~fill_num = ~beat_pattern.size;
	//~beat_pattern.do({arg item, i; item.postln});

	// add 2-beat fills at the end of every four-bar phrase
	~fills = [];
	~fill_num.do({~fills = ~fills.add(~get_fill.())});

	// replace elements with corresponding numbers
	(~beat_pattern).do({arg item, i;
		var tmp =  ~beat_pattern[i].copy();
		// remove last 4 elements/2 beats of last measure
		4.do({arg i; tmp.pop()});
		// add to durations
		tmp = ~convert_to_beat.(tmp);
		// add regular beats
		tmp.size.do {|i|
			if (i == 0, {~crash_start.add(0.5)}, {~crash_start.add(Rest(0.5))}); // add crash at the first beat of every four measures on TOP of transformed patterns
			if (tmp[i] == \crash, {~crash.add(0.5)}, {~crash.add(Rest(0.5))});
			if (tmp[i] == \openhh, {~openhh.add(0.5)}, {~openhh.add(Rest(0.5))});
			if (tmp[i] == \closedhh, {~closedhh.add(0.5)}, {~closedhh.add(Rest(0.5))});
			if (tmp[i] == \kick, {~kick.add(0.5)}, {~kick.add(Rest(0.5))});
			if (tmp[i] == \snare, {~snare.add(0.5)}, {~snare.add(Rest(0.5))});
			if (tmp[i] == \tom1, {~tom1.add(0.5)}, {~tom1.add(Rest(0.5))});
			if (tmp[i] == \tom2, {~tom2.add(0.5)}, {~tom2.add(Rest(0.5))});
		};
		// add fills
		(~fills[i][0]).do {arg item, j;
			if (~fills[i][0][j] == \snare, {~snare.add(~fills[i][1][j])}, {~snare.add(Rest(~fills[i][1][j]))});
			if (~fills[i][0][j] == \tom1, {~tom1.add(~fills[i][1][j])}, {~tom1.add(Rest(~fills[i][1][j]))});
			if (~fills[i][0][j] == \tom2, {~tom2.add(~fills[i][1][j])}, {~tom2.add(Rest(~fills[i][1][j]))});
			if (~fills[i][0][j] == \kick, {~kick.add(~fills[i][1][j])}, {~kick.add(Rest(~fills[i][1][j]))});
			if (~fills[i][0][j] == \crash, {~crash.add(~fills[i][1][j])}, {~crash.add(Rest(~fills[i][1][j]))});
			if (~fills[i][0][j] == \openhh, {~openhh.add(~fills[i][1][j])}, {~openhh.add(Rest(~fills[i][1][j]))});
			if (~fills[i][0][j] == \closedhh, {~closedhh.add(~fills[i][1][j])}, {~closedhh.add(Rest(~fills[i][1][j]))});
			if (~fills[i][0][j] == \crash_start, {~crash_start.add(~fills[i][1][j])}, {~crash_start.add(Rest(~fills[i][1][j]))});

	 };
    });

	(~beat_pattern).do({arg item, i; item.postln;});

	// add 2-beat pickup
	if (~input[6] == True, {
		~rest = [Rest(0.5), Rest(0.5), Rest(0.5), Rest(0.5)];
		~crash_start = ~rest ++ ~crash_start;
		~crash = ~rest ++ ~crash;
		~closedhh = ~rest ++ ~closedhh;
		~kick = ~rest ++ ~kick;
		~openhh = [Rest(0.2), Rest(0.3), Rest(0.1), 0.4, Rest(0.5), 0.5] ++ ~openhh;
		~snare = [0.2, 0.3, Rest(0.5), 0.2, 0.3, Rest(0.5)] ++ ~snare;
		~tom1 = [Rest(0.2), Rest(0.3), 0.5, Rest(0.5), 0.5] ++ ~tom1;
		~tom2 = [Rest(0.2), Rest(0.3), Rest(0.5), Rest(0.5), 0.5] ++ ~tom2;
	});

	// add solo at the end
	if (~input[4] == True, {~get_solo.()}, {~crash = ~crash ++ [2.0]}); // end entire piece with a lingering crash

	~crash_start.postln;
	~crash.postln;
	~openhh.postln;
	~closedhh.postln;
	~kick.postln;
	~snare.postln;
	~tom1.postln;
	~tom2.postln;

	s.sync;
	/*==================================================================================================================*/
	/* End of Transformations */



	/*==================================================================================================================*/
	/* Playing */

	// accent patterns added to \amp
	~crash_start_track = Pbind(\instrument, \playBuf, \dur, Pseq(~crash_start, 1), \buffer, b[0], \amp, Pseq([5.0], inf));
	~crash_track = Pbind(\instrument, \playBuf, \dur, Pseq(~crash, 1), \buffer, b[0], \amp, Pseq([2.0, 1.0], inf));
	~openhh_track = Pbind(\instrument, \playBuf, \dur, Pseq(~openhh, 1), \buffer, b[1], \amp, Pseq([0.55, 0.35], inf));
	~closedhh_track = Pbind(\instrument, \playBuf, \dur, Pseq(~closedhh, 1), \buffer, b[2], \amp, Pseq([0.55, 0.35], inf));
	~kick_track = Pbind(\instrument, \playBuf, \dur, Pseq(~kick, 1), \buffer, b[3], \amp, Pseq([4.0, 2.0], inf));
	~snare_track = Pbind(\instrument, \playBuf, \dur, Pseq(~snare, 1), \buffer, b[4], \amp, Pseq([1.5, 1.0], inf));
	~tom1_track = Pbind(\instrument, \playBuf, \dur, Pseq(~tom1, 1), \buffer, b[5], \amp, Pseq([4, 1.0, 1.5, 1.0], inf));
	~tom2_track = Pbind(\instrument, \playBuf, \dur, Pseq(~tom2, 1), \buffer, b[6], \amp, Pseq([2.5, 1.0], inf));


	Ppar([~crash_start_track, ~crash_track, ~openhh_track, ~closedhh_track, ~kick_track, ~snare_track, ~tom1_track, ~tom2_track], 1).play;

}
)




// ************************************************************************************************* //
	// for investigation purpose, not used in code execution
	// function to generate transformation matrix for input pattern
	/*~get_transformation_matrix = {
		// function arguments
		arg beat_pattern;

		var beat_nums; // beat_pattern in degrees/numbers
		var matrix = []; // transformation matrix in degrees
		var steps = []; // intervals in beat_pattern
		var inverse_steps; // intervals for inverse
		var nums = (0..6); // degrees of beat elements
		// var current_head;
		var inverse_nums = []; // inverse/1st column of matrix
		var row; // temporary row of
		var element_matrix; // transformatiion matrix in beat elements

	    // convert beat elements to degrees for easier computation
		beat_nums = beat_pattern.collect({arg item, i; ~beat_to_num[item]});

		// get intervals
		for(1, beat_pattern.size - 1, {arg i; steps = steps.add(beat_nums[i] - beat_nums[i-1])});
		// get inverse intervals
		inverse_steps = steps * (-1);
		// get inverse nums corresponding to beat elements
		inverse_nums = [beat_nums[0]];
		for(0, inverse_steps.size - 1, {arg i; inverse_nums = inverse_nums.add(.wrapAt(inverse_nums[i] + inverse_steps[i]))});

		// generate transformation matrix
		for(0, inverse_nums.size - 1, {arg i;
			row = [inverse_nums[i]];
			for(0, steps.size - 1, {arg j;
				row = row.add(nums.wrapAt(row[j] + steps[j]));
			});
			matrix = matrix.add(row);
		});
		// return
		matrix
	};*/
// ************************************************************************************************* //