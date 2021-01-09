local UiIsOpen = false

local CurrentInstrument
local NotesPlaying = 0
local ActivelyPlayingTimer = 0

RegisterNetEvent('instruments:noteOn')
RegisterNetEvent('instruments:noteOff')

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(firstFunc, nextFunc, endFunc)
	return coroutine.wrap(function()
		local iter, id = firstFunc()

		if not id or id == 0 then
			endFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = endFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
			coroutine.yield(id)
			next, id = nextFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		endFunc(iter)
	end)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function IsInstrument(object, info)
	local model = GetEntityModel(object)

	for _, instrumentModel in ipairs(info.models) do
		if model == GetHashKey(instrumentModel) then
			return true
		end
	end

	return false
end

function GetClosestInstrumentObject(ped, info)
	local pos = GetEntityCoords(ped)

	local minDist, closest

	for object in EnumerateObjects() do
		if IsInstrument(object, info) then
			local instrumentPos = GetEntityCoords(object)
			local distance = #(pos - instrumentPos)

			if distance <= Config.MaxInteractDistance and (not minDist or distance < minDist) then
				minDist = distance
				closest = object
			end
		end
	end

	return closest
end

function AttachToInstrument(ped, info)
	local object = GetClosestInstrumentObject(ped, info)

	if object then
		AttachEntityToEntity(ped, object, 0, info.x, info.y, info.z, info.pitch, info.roll, info.yaw, false, false, true, false, 0, true, false, false)
		return true
	else
		return false
	end
end

function DetachFromInstrument(ped)
	DetachEntity(ped)
end

function StartPlayingInstrument(instrument)
	if CurrentInstrument then
		StopPlayingInstrument()
	end

	CurrentInstrument = Config.Instruments[instrument]

	if not CurrentInstrument then
		return
	end

	local ped = PlayerPedId()

	SendNUIMessage({
		type = 'setInstrumentPreset',
		instrument = CurrentInstrument.midiInstrument,
	})

	if CurrentInstrument.attachTo and not AttachToInstrument(ped, CurrentInstrument.attachTo) then
		CurrentInstrument = nil
		return
	end

	if CurrentInstrument.prop then
		local model = CurrentInstrument.prop.model
		local bone = CurrentInstrument.prop.bone
		local x = CurrentInstrument.prop.x
		local y = CurrentInstrument.prop.y
		local z = CurrentInstrument.prop.z
		local pitch = CurrentInstrument.prop.pitch
		local roll = CurrentInstrument.prop.roll
		local yaw = CurrentInstrument.prop.yaw

		if type(bone) == 'string' then
			bone = GetEntityBoneIndexByName(ped, bone)
		end

		local obj = CreateObjectNoOffset(GetHashKey(model), 0.0, 0.0, 0.0, true, false, false, false)
		AttachEntityToEntity(obj, ped, bone, x, y, z, pitch, roll, yaw, false, false, true, false, 0, true, false, false)
		CurrentInstrument.prop.handle = obj
	end
end

function StopPlayingInstrument()
	if not CurrentInstrument then
		return
	end

	local ped = PlayerPedId()

	if CurrentInstrument.attachTo then
		DetachFromInstrument(ped)
	end

	if CurrentInstrument.prop and CurrentInstrument.prop.handle then
		DeleteObject(CurrentInstrument.prop.handle)
	end

	local anim = GetAnimation()

	StopAnimTask(ped, anim.dict, anim.name)

	CurrentInstrument = nil
end

function ShowUi()
	SendNUIMessage({
		type = 'showUi'
	})
	SetNuiFocus(true, true)
	UiIsOpen = true
end

function HideUi()
	SendNUIMessage({
		type = 'hideUi'
	})
	SetNuiFocus(false, false)
	UiIsOpen = false
end

function ToggleUi()
	if UiIsOpen then
		HideUi()
	else
		ShowUi()
	end
end

function IsInSameRoom(entity1, entity2)
	local interior1 = GetInteriorFromEntity(entity1)
	local interior2 = GetInteriorFromEntity(entity2)

	if interior1 ~= interior2 then
		return false
	end

	local roomHash1 = GetRoomKeyFromEntity(entity1)
	local roomHash2 = GetRoomKeyFromEntity(entity2)

	if roomHash1 ~= roomHash2 then
		return false
	end

	return true
end

function GetListenerInfo()
	local cam = GetRenderingCam()
	local ped = PlayerPedId()

	local listenerCoords

	if cam == -1 then
		if IsPedDeadOrDying(ped) then
			listenerCoords = GetGameplayCamCoord()
		else
			listenerCoords = GetEntityCoords(ped)
		end
	else
		listenerCoords = GetCamCoord(cam)
	end

	return ped, listenerCoords
end

function GetAnimation()
	if NotesPlaying > 0 or GetSystemTime() < ActivelyPlayingTimer then
		return CurrentInstrument.activeAnimation
	else
		return CurrentInstrument.inactiveAnimation
	end
end

function PlayAnimation(ped, dict, name)
	RequestAnimDict(dict)

	while not HasAnimDictLoaded(dict) do
		Wait(0)
	end

	TaskPlayAnim(ped, dict, name, 1.0, 1.0, -1, 1, 0, false, false, false, '', false)

	RemoveAnimDict(dict)
end

function GetInstrumentList()
	local instruments = {}

	for instrument, _ in pairs(Config.Instruments) do
		table.insert(instruments, instrument)
	end

	table.sort(instruments)

	return instruments
end

RegisterCommand('instrument', function(source, args, raw)
	if args[1] == 'quit' then
		StopPlayingInstrument()
	else
		ShowUi()

		if args[1] then
			StartPlayingInstrument(args[1])
		end
	end
end)

RegisterNUICallback('init', function(data, cb)
	cb({
		maxVolume = Config.MaxVolume,
		baseOctave = Config.BaseOctave,
		minAttenuationFactor = Config.MinAttenuationFactor,
		maxAttenuationFactor = Config.MaxAttenuationFactor,
		minVolumeFactor = Config.MinVolumeFactor,
		maxVolumeFactor = Config.MaxVolumeFactor,
		soundfontUrl = Config.SoundfontUrl,
		instrumentsUrl = Config.InstrumentsUrl
	})
end)

RegisterNUICallback('noteOn', function(data, cb)
	TriggerServerEvent('instruments:noteOn', data.channel, data.instrument, data.note, data.octave)

	NotesPlaying = NotesPlaying + 1

	cb({})
end)

RegisterNUICallback('noteOff', function(data, cb)
	TriggerServerEvent('instruments:noteOff', data.channel, data.note, data.octave)

	NotesPlaying = NotesPlaying - 1

	if NotesPlaying == 0 then
		ActivelyPlayingTimer = GetSystemTime() + 500
	end

	cb({})
end)

RegisterNUICallback('closeUi', function(data, cb)
	HideUi()
	cb({})
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then
		return
	end

	if UiIsOpen then
		StopPlayingInstrument()
		HideUi()
	end
end)

AddEventHandler('instruments:noteOn', function(serverId, channel, instrument, note, octave)
	local player = GetPlayerFromServerId(serverId)

	if player == PlayerId() then
		return
	end

	local listener, listenerCoords = GetListenerInfo()
	local soundSource = GetPlayerPed(player)
	local distance = #(listenerCoords - GetEntityCoords(soundSource))

	if distance <= Config.MaxNoteDistance then
		SendNUIMessage({
			type = 'noteOn',
			channel = channel,
			instrument = instrument,
			note = note,
			octave = octave,
			distance = distance,
			sameRoom = IsInSameRoom(listener, soundSource)
		})
	end
end)

AddEventHandler('instruments:noteOff', function(serverId, channel, note, octave)
	local player = GetPlayerFromServerId(serverId)

	if player == PlayerId() then
		return
	end

	SendNUIMessage({
		type = 'noteOff',
		channel = channel,
		note = note,
		octave = octave
	})
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/instrument', 'Play an instrument', {
		{name = 'instrument', help = table.concat(GetInstrumentList(), ', ') .. ', quit'}
	})

	while true do
		Wait(250)

		if CurrentInstrument then
			local ped = PlayerPedId()
			local anim = GetAnimation()

			if not IsEntityPlayingAnim(ped, anim.dict, anim.name, 1) then
				PlayAnimation(ped, anim.dict, anim.name)
			end
		end
	end
end)
