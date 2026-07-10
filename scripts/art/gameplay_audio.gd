class_name GameplayAudio
extends Node

const MIX_RATE := 11025

var playback_enabled: bool = true
var footstep_player: AudioStreamPlayer
var effect_player: AudioStreamPlayer
var travel_player: AudioStreamPlayer
var footstep_streams: Array[AudioStreamWAV] = []
var interaction_stream: AudioStreamWAV
var arrival_stream: AudioStreamWAV
var travel_stream: AudioStreamWAV
var footstep_variant: int = 0
var travel_active: bool = false


func setup(enabled: bool) -> void:
	playback_enabled = enabled
	name = "GameplayAudio"


func _ready() -> void:
	footstep_streams = [_build_footstep(0), _build_footstep(1)]
	interaction_stream = _build_chime(523.25, 659.25, 0.22)
	arrival_stream = _build_chime(659.25, 783.99, 0.32)
	travel_stream = _build_travel_loop()
	footstep_player = _add_player("Footsteps", -15.0)
	effect_player = _add_player("Effects", -12.0)
	travel_player = _add_player("ShuttleEngine", -21.0)


func set_enabled(enabled: bool) -> void:
	playback_enabled = enabled
	if not enabled:
		_stop_players()
	elif travel_active:
		_start_travel_playback()


func play_footstep() -> void:
	if not playback_enabled or footstep_player == null:
		return
	footstep_variant = 1 - footstep_variant
	footstep_player.stream = footstep_streams[footstep_variant]
	if _can_output_audio():
		footstep_player.play()


func play_interaction() -> void:
	_play_effect(interaction_stream)


func play_arrival() -> void:
	_play_effect(arrival_stream)


func start_travel() -> void:
	travel_active = true
	if playback_enabled:
		_start_travel_playback()


func stop_travel() -> void:
	travel_active = false
	if travel_player != null:
		travel_player.stop()


func shutdown() -> void:
	travel_active = false
	_stop_players()
	if footstep_player != null:
		footstep_player.stream = null
	if effect_player != null:
		effect_player.stream = null
	if travel_player != null:
		travel_player.stream = null
	footstep_streams.clear()
	interaction_stream = null
	arrival_stream = null
	travel_stream = null


func _add_player(player_name: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.volume_db = volume
	add_child(player)
	return player


func _play_effect(sound: AudioStreamWAV) -> void:
	if not playback_enabled or effect_player == null:
		return
	effect_player.stream = sound
	if _can_output_audio():
		effect_player.play()


func _start_travel_playback() -> void:
	if travel_player == null:
		return
	travel_player.stream = travel_stream
	if _can_output_audio() and not travel_player.playing:
		travel_player.play()


func _stop_players() -> void:
	for player in [footstep_player, effect_player, travel_player]:
		if player != null:
			player.stop()


func _can_output_audio() -> bool:
	return DisplayServer.get_name() != "headless"


func _build_footstep(variant: int) -> AudioStreamWAV:
	var duration := 0.13
	var frame_count := roundi(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	for frame in range(frame_count):
		var time := float(frame) / MIX_RATE
		var envelope := pow(1.0 - time / duration, 2.4)
		var body_frequency := 94.0 + float(variant) * 23.0
		var sample := sin(TAU * body_frequency * time) * envelope * 0.52
		sample += sin(TAU * 410.0 * time) * pow(envelope, 2.0) * 0.12
		bytes.encode_s16(frame * 2, roundi(clampf(sample, -1.0, 1.0) * 32767.0))
	return _make_mono_wav(bytes, frame_count, false)


func _build_chime(first_frequency: float, second_frequency: float, duration: float) -> AudioStreamWAV:
	var frame_count := roundi(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	for frame in range(frame_count):
		var time := float(frame) / MIX_RATE
		var attack := minf(1.0, time / 0.015)
		var envelope := attack * pow(1.0 - time / duration, 2.0)
		var sample := sin(TAU * first_frequency * time) * envelope * 0.34
		sample += sin(TAU * second_frequency * time) * envelope * 0.24
		bytes.encode_s16(frame * 2, roundi(clampf(sample, -1.0, 1.0) * 32767.0))
	return _make_mono_wav(bytes, frame_count, false)


func _build_travel_loop() -> AudioStreamWAV:
	var frame_count := MIX_RATE
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	for frame in range(frame_count):
		var time := float(frame) / MIX_RATE
		var pulse := 0.72 + sin(TAU * 4.0 * time) * 0.12
		var sample := sin(TAU * 55.0 * time) * 0.34
		sample += sin(TAU * 82.0 * time) * 0.16
		sample += sin(TAU * 137.0 * time) * 0.06
		bytes.encode_s16(frame * 2, roundi(clampf(sample * pulse, -1.0, 1.0) * 32767.0))
	return _make_mono_wav(bytes, frame_count, true)


func _make_mono_wav(bytes: PackedByteArray, frame_count: int, loop: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = frame_count
	wav.data = bytes
	return wav
