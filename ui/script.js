const keys = {
	90: 'key-C1',
	83: 'key-Db1',
	88: 'key-D1',
	68: 'key-Eb1',
	67: 'key-E1',
	86: 'key-F1',
	71: 'key-Gb1',
	66: 'key-G1',
	72: 'key-Ab1',
	78: 'key-A1',
	74: 'key-Bb1',
	77: 'key-B1',
	188: 'key-C2',
	76: 'key-Db2',
	190: 'key-D2',
	186: 'key-Eb2',
	191: 'key-E2',
	81: 'key-F2',
	50: 'key-Gb2',
	87: 'key-G2',
	51: 'key-Ab2',
	69: 'key-A2',
	52: 'key-Bb2',
	82: 'key-B2',
	84: 'key-C3',
	54: 'key-Db3',
	89: 'key-D3',
	55: 'key-Eb3',
	85: 'key-E3',
	73: 'key-F3',
	57: 'key-Gb3',
	79: 'key-G3',
	48: 'key-Ab3',
	80: 'key-A3',
	189: 'key-Bb3',
	219: 'key-B3',

};

const notes = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

const minOctave = 1;
const maxOctave = 7;

const minDuration = 0;
const maxDuration = 2000;

var baseOctave = 3;

var noteDuration = 500;

var maxVolume = 1.0;

var minAttenuationFactor = 4.0;
var maxAttenuationFactor = 6.0;

var minVolumeFactor = 1.0;
var maxVolumeFactor = 4.0;

var attenuationFactor = minAttenuationFactor;
var volumeFactor = minVolumeFactor;

var midiChannel = 0;

var channels = {};

function sendMessage(name, params) {
	return fetch('https://' + GetParentResourceName() + '/' + name, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(params)
	});
}

function showUi() {
	document.getElementById('ui').style.display = 'flex';
}

function hideUi() {
	document.getElementById('ui').style.display = 'none';
}

function setAttenuationFactor(target) {
	if (attenuationFactor != target) {
		if (attenuationFactor > target) {
			attenuationFactor -= 0.1;
		} else {
			attenuationFactor += 0.1;
		}

		setTimeout(() => setAttenuationFactor(target), 5);
	}
}

function setVolumeFactor(target) {
	if (volumeFactor != target) {
		if (volumeFactor > target) {
			volumeFactor -= 0.1;
		} else {
			volumeFactor += 0.1;
		}

		setTimeout(() => setVolumeFactor(target), 5);
	}
}

function setInstrument(channel, instrument) {
	return new Promise(function(resolve, reject) {
		if (channels[channel] == instrument) {
			return resolve();
		}

		MIDI.loadResource({
			instrument: instrument,
			onsuccess: function() {
				MIDI.programChange(channel, MIDI.GM.byName[instrument].number);

				channels[channel] = instrument;

				if (channel == midiChannel) {
					document.getElementById('instrument').value = instrument;
				}

				return resolve();
			},
			onerror: function() {
				return reject();
			}
		});
	});
}

function playNote(data) {
	var noteName = `${data.note}${data.octave}`;
	var note = MIDI.keyToNote[noteName];

	if (data.sameRoom) {
		setAttenuationFactor(minAttenuationFactor);
		setVolumeFactor(minVolumeFactor);
	} else {
		setAttenuationFactor(maxAttenuationFactor);
		setVolumeFactor(maxVolumeFactor);
	}

	var volume = ((127 - data.distance * attenuationFactor) / volumeFactor) * maxVolume;

	setInstrument(data.channel, data.instrument).then(() => {
		MIDI.programChange(data.channel, MIDI.GM.byName[data.instrument].number);
		MIDI.setVolume(data.channel, volume);
		MIDI.noteOn(data.channel, note, 127, 0);
		MIDI.noteOff(data.channel, note, data.duration / 1000);
	});
}

function sendNote(channel, note, octave, echo) {
	var instrument;
	
	if (channels[channel]) {
		instrument = channels[channel];
	} else {
		instrument = document.getElementById('instrument').value;
	}

	sendMessage('playNote', {
		echo: echo,
		channel: channel,
		instrument: instrument,
		note: note,
		octave: octave,
		duration: noteDuration
	});
}

function activateKey(key, echo) {
	var note = key.getAttribute('data-note');
	var octave = key.getAttribute('data-octave');

	octave = parseInt(octave) + baseOctave;

	sendNote(midiChannel, note, octave, echo);

	key.style.fill = 'red';
	setTimeout(() => key.style.fill = null, 50);

}

function midiNoteName(note) {
	return notes[note % 12];
}

function midiNoteOctave(note) {
	return Math.floor(note / 12);
}

function midiNoteToKey(note) {
	var noteName = midiNoteName(note);
	var octave = midiNoteOctave(note);

	return document.getElementById(`key-${noteName}${octave - baseOctave}`);
}

function setSoundfont(soundfontUrl, instrumentsUrl) {
	fetch(instrumentsUrl).then(resp => resp.json()).then(resp => {
		var select = document.getElementById('instrument');
		select.innerHTML = '';

		resp.forEach(instrument => {
			var option = document.createElement('option');
			option.value = instrument;
			option.innerHTML = instrument;
			select.appendChild(option);
		});

		MIDI.loadPlugin({
			soundfontUrl: soundfontUrl,
			instrument: resp[0]
		});

		MIDI.Player.addListener(function(data) {
			if (data.message == 144) {
				var key = midiNoteToKey(data.note);

				if (key && data.channel == midiChannel) {
					activateKey(key, false);
				} else {
					var noteName = midiNoteName(data.note);
					var octave = midiNoteOctave(data.note);

					sendNote(data.channel, noteName, octave, false);
				}
			}
		});
	});
}

function setInstrumentPreset(data) {
	document.getElementById('instrument').value = data.instrument;
	setInstrument(midiChannel, data.instrument);

	document.getElementById('duration').value = data.noteDuration;
	noteDuration = data.noteDuration;
}

function timeToString(time) {
	var secs = time / 1000;
	var h = Math.floor(secs / 3600);
	var m = Math.floor(secs / 60) % 60;
	var s = Math.floor(secs) % 60;

	return String(h).padStart(2, '0') + ':' + String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
}

function updateMidiPlayTime() {
	if (MIDI.Player.playing) {
		document.getElementById('time').innerHTML = timeToString(MIDI.Player.currentTime) + '/' + timeToString(MIDI.Player.endTime);
		setTimeout(updateMidiPlayTime, 1000);
	} else {
		document.getElementById('time').innerHTML = '00:00:00/00:00:00';
	}
}

function playMidi(url) {
	MIDI.Player.loadFile(url, function() {
		var instruments = MIDI.Player.getFileInstruments();
		var promises = [];

		for (var i = 0; i < instruments.length; ++i) {
			promises.push(setInstrument(i, instruments[i]));
		}

		Promise.all(promises).then(() => {
			MIDI.Player.start();
			updateMidiPlayTime();
		});
	});
}

window.addEventListener('message', event => {
	switch (event.data.type) {
		case 'showUi':
			showUi();
			break;
		case 'hideUi':
			hideUi();
			break;
		case 'playNote':
			playNote(event.data);
			break;
		case 'setInstrumentPreset':
			setInstrumentPreset(event.data);
			break;
	}
});

window.addEventListener('load', event => {
	sendMessage('init', {}).then(resp => resp.json()).then(resp => {
		baseOctave = resp.baseOctave;
		document.getElementById('octave').value = baseOctave;

		maxVolume = resp.maxVolume;

		noteDuration = resp.noteDuration;
		document.getElementById('duration').value = noteDuration;

		minAttenuationFactor = resp.minAttenuationFactor;
		maxAttenuationFactor = resp.maxAttenuationFactor;
		attenuationFactor = minAttenuationFactor;

		minVolumeFactor = resp.minVolumeFactor;
		maxVolumeFactor = resp.maxVolumeFactor;
		volumeFactor = minVolumeFactor;

		setSoundfont(resp.soundfontUrl, resp.instrumentsUrl);

		document.getElementById('channel').value = midiChannel;
	});

	document.querySelectorAll('.piano-key').forEach(key => {
		key.addEventListener('click', function(event) {
			activateKey(this, true);
		});
	});

	document.getElementById('close').addEventListener('click', function(event) {
		sendMessage('closeUi', {})
	});

	document.getElementById('instrument').addEventListener('input', function(event) {
		var channel = parseInt(document.getElementById('channel').value);

		setInstrument(channel, this.value);
		
		this.blur();
	});

	document.getElementById('octave').addEventListener('input', function(event) {
		var octave = parseInt(this.value);

		if (octave != NaN && octave >= minOctave && octave <= maxOctave) {
			baseOctave = octave;
		}

		this.value = baseOctave;
		
		this.blur();
	});

	document.getElementById('channel').addEventListener('input', function(event) {
		var channel = parseInt(this.value);

		if (channel != NaN && channel >= 0 && channel < 16) {
			midiChannel = channel;
		}

		this.value = midiChannel;

		if (channels[channel]) {
			document.getElementById('instrument').value = channels[channel];
		}
		
		this.blur();
	});

	document.getElementById('duration').addEventListener('input', function(event) {
		var duration = parseInt(this.value);

		if (duration != NaN && duration >= minDuration && duration <= maxDuration) {
			noteDuration = duration;
		}

		this.value = noteDuration;

		this.blur();
	});

	document.getElementById('play').addEventListener('click', function(event) {
		playMidi(document.getElementById('url').value);
		this.blur();
	});

	document.getElementById('stop').addEventListener('click', function(event) {
		MIDI.Player.stop();
		this.blur();
	});

	document.getElementById('keyboard').addEventListener('keyup', event => {
		switch (event.keyCode) {
			case 33:
				if (baseOctave < maxOctave) {
					++baseOctave;
				}
				document.getElementById('octave').value = baseOctave;
				break;
			case 34:
				if (baseOctave > minOctave) {
					--baseOctave;
				}
				document.getElementById('octave').value = baseOctave;
				break;
			case 45:
				if (midiChannel < 15) {
					++midiChannel;
				}
				document.getElementById('channel').value = midiChannel;
				break;
			case 46:
				if (midiChannel > 0) {
					--midiChannel;
				}
				document.getElementById('channel').value = midiChannel;
				break;
			case 36:
				if (noteDuration < maxDuration) {
					noteDuration += 100;
				}
				document.getElementById('duration').value = noteDuration;
				break;
			case 35:
				if (noteDuration > minDuration) {
					noteDuration -= 100;
				}
				document.getElementById('duration').value = noteDuration;
				break;
			default:
				var id = keys[event.keyCode];
				var key = document.getElementById(id);

				if (key) {
					activateKey(key, true);
				}

				break;
		}
	});
});
