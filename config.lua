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

-- Default length of notes
Config.NoteDuration = 500

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
		noteDuration = 500,
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
			name = 'piano_base'
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@piano@male@normal',
			name = 'piano_fast_l_-1_0_+1_r_-1_0_+1_chords_01'
		}
	},
	['trumpet'] = {
		midiInstrument = 'trumpet',
		noteDuration = 200,
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
			name = 'base'
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@trumpet@standing@140bpm',
			name = 'upbeat_cen_002'
		}
	},
	['guitar'] = {
		midiInstrument = 'acoustic_guitar_nylon',
		noteDuration = 500,
		prop = {
			model = 'p_guitar01x',
			bone = 'SM_L_pistol',
			x = -0.2,
			y = -0.6,
			z = 0.3,
			pitch = 270.0,
			roll = 0.0,
			yaw = 20.0
		},
		inactiveAnimation = {
			dict = 'ai_gestures@instruments@guitar@standing@male@normal',
			name = 'guitar_base'
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@guitar@standing@male@normal',
			name = 'guitar_med_melody_-1_0_+1_01'
		}
	},
	['harp'] = {
		midiInstrument = 'orchestral_harp',
		noteDuration = 1000,
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
			name = 'p_base'
		},
		activeAnimation = {
			dict = 'ai_gestures@instruments@band_test',
			name = 'p_playing'
		}
	}
}
