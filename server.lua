RegisterNetEvent('instruments:playNote')

AddEventHandler('instruments:playNote', function(channel, instrument, note, octave, duration)
	TriggerClientEvent('instruments:playNote', -1, source, channel, instrument, note, octave, duration)
end)
