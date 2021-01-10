Config = {}

-- Maximum volume for notes
Config.MaxVolume = 1.0

-- How quickly sound fades out over distance
Config.MinAttenuationFactor = 4.0
Config.MaxAttenuationFactor = 6.0

-- Factor to lower volume by when in a different room
Config.MinVolumeFactor = 1.0
Config.MaxVolumeFactor = 4.0

-- The base octave of notes
Config.BaseOctave = 3

-- Maximum distance at which to interact with stationary instrument objects
Config.MaxInteractDistance = 2.0

-- Maximum distance at which to receive notes
Config.MaxNoteDistance = 30.0

-- Choose a soundfont and accompanying instrument list:

-- Fluid
--Config.SoundfontUrl = 'https://gleitz.github.io/midi-js-soundfonts/FluidR3_GM/'
--Config.InstrumentsUrl = 'https://gleitz.github.io/midi-js-soundfonts/FluidR3_GM/names.json'

-- Musyng Kite
--Config.SoundfontUrl = 'https://gleitz.github.io/midi-js-soundfonts/MusyngKite/'
--Config.InstrumentsUrl = 'https://gleitz.github.io/midi-js-soundfonts/MusyngKite/names.json'

-- FatBoy
Config.SoundfontUrl = 'https://gleitz.github.io/midi-js-soundfonts/FatBoy/'
Config.InstrumentsUrl = 'https://gleitz.github.io/midi-js-soundfonts/FatBoy/names.json'

-- Interactions with instruments
Config.Instruments = {
	['piano'] = {
		midiInstrument = 'acoustic_grand_piano',
		attachTo = {
			models = {
				'p_nbmpiano01x',
				'p_nbxpiano01x',
				'p_piano02x',
				'p_piano03x',
				'sha_man_piano01'
			},
			x = 0.0,
			y = -0.77,
			z = 0.55,
			pitch = 0.0,
			roll = 0.0,
			yaw = 0.0
		},
		inactiveAnimation = {
			dict = 'ai_gestures@instruments@piano@male@normal',
			name = 'piano_base',
			flag = 1
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@piano@male@normal',
			name = 'piano_fast_l_-1_0_+1_r_-1_0_+1_chords_01',
			flag = 1
		}
	},
	['trumpet'] = {
		midiInstrument = 'trumpet',
		prop = {
			model = 'p_trumpet01x',
			bone = 'SKEL_R_Hand',
			x = 0.07,
			y = 0.0,
			z = -0.05,
			pitch = 270.0,
			roll = 10.0,
			yaw = -80.0
		},
		inactiveAnimation = {
			dict = 'amb_misc@world_human_trumpet@male_a@base',
			name = 'base',
			flag = 25
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@trumpet@standing@140bpm',
			name = 'upbeat_cen_002',
			flag = 25
		}
	},
	['guitar'] = {
		midiInstrument = 'acoustic_guitar_nylon',
		prop = {
			model = 'p_guitar01x',
			bone = 'scale_pelvis',
			x = -0.05,
			y = 0.36,
			z = 0.14,
			pitch = -15.0,
			roll = 150.0,
			yaw = 180.0
		},
		inactiveAnimation = {
			dict = 'ai_gestures@instruments@guitar@seated@80bpm',
			name = 'generic_01',
			flag = 25
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@guitar@seated@120bpm',
			name = 'upbeat_picking_fast_chords_rt_0_+1_03',
			flag = 25
		}
	},
	['harp'] = {
		midiInstrument = 'orchestral_harp',
		attachTo = {
			models = {
				'p_harp01x'
			},
			x = 0.5,
			y = -0.15,
			z = 0.55,
			pitch = 0.0,
			roll = 0.0,
			yaw = 90.0
		},
		inactiveAnimation = {
			dict = 'ai_gestures@instruments@band_test',
			name = 'p_base',
			flag = 1
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@band_test',
			name = 'p_playing',
			flag = 1
		}
	},
	['harmonica'] = {
		midiInstrument = 'harmonica',
		prop = {
			model = 'p_harmonica01x',
			bone = 'skel_l_hand',
			x = 0.08,
			y = 0.03,
			z = 0.08,
			pitch = 0.0,
			roll = 90.0,
			yaw = 0.0
		},
		inactiveAnimation = {
			female = {
				dict = 'amb_misc@prop_human_seat_bench@harmonica@resting@female_a@base',
				name = 'base',
				flag = 25
			},
			male = {
				dict = 'amb_misc@prop_human_seat_bench@harmonica@resting@male_a@base',
				name = 'base',
				flag = 25
			},
		},
		activeAnimation = {
			female = {
				dict = 'ai_gestures@instruments@harmonica@seated@female@120bpm',
				name = 'spine_bwd_01',
				flag = 25
			},
			male = {
				dict = 'ai_gestures@instruments@harmonica@seated@120bpm',
				name = 'spine_bwd_01',
				flag = 25
			}
		}
	}
}
