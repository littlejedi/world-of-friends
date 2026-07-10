class_name AmbientAudio
extends AudioStreamPlayer

const MIX_RATE := 11025
const LOOP_SECONDS := 8.0

var playback_enabled: bool = true


func setup(profile: String, enabled: bool) -> void:
	playback_enabled = enabled
	name = "AmbientAudio"
	volume_db = -24.0
	stream = _build_loop(profile)


func _ready() -> void:
	if playback_enabled and _can_output_audio():
		play()


func set_enabled(enabled: bool) -> void:
	playback_enabled = enabled
	if not is_inside_tree():
		return
	if enabled:
		if _can_output_audio() and not playing:
			play()
		stream_paused = false
	else:
		stream_paused = true


func shutdown() -> void:
	stream_paused = false
	stop()
	stream = null


func _can_output_audio() -> bool:
	return DisplayServer.get_name() != "headless"


func _build_loop(profile: String) -> AudioStreamWAV:
	var frame_count := roundi(MIX_RATE * LOOP_SECONDS)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 4)
	for frame in range(frame_count):
		var time := float(frame) / MIX_RATE
		var left := _sample_profile(profile, time, -0.28)
		var right := _sample_profile(profile, time, 0.28)
		bytes.encode_s16(frame * 4, roundi(clampf(left, -1.0, 1.0) * 32767.0))
		bytes.encode_s16(frame * 4 + 2, roundi(clampf(right, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = true
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = frame_count
	wav.data = bytes
	return wav


func _sample_profile(profile: String, time: float, stereo_phase: float) -> float:
	var loop_phase := TAU * time / LOOP_SECONDS
	var slow_swell := 0.5 + 0.5 * sin(loop_phase + stereo_phase)
	if profile == "shanghai":
		var city_bed := sin(TAU * 42.0 * time + stereo_phase) * 0.16
		city_bed += sin(TAU * 67.0 * time - stereo_phase) * 0.10
		city_bed += sin(TAU * 93.0 * time + 1.2) * 0.055
		var chime_envelope := pow(maxf(0.0, sin(loop_phase * 2.0 - 0.7)), 14.0)
		var distant_chime := sin(TAU * 660.0 * time) * chime_envelope * 0.12
		return (city_bed * (0.45 + slow_swell * 0.25) + distant_chime) * 0.48
	var water_bed := sin(TAU * 36.0 * time + stereo_phase) * 0.15
	water_bed += sin(TAU * 58.0 * time - stereo_phase) * 0.11
	water_bed += sin(TAU * 82.0 * time + 0.8) * 0.05
	var gull_envelope := pow(maxf(0.0, sin(loop_phase - 1.15)), 18.0)
	var gull := sin(TAU * (740.0 + sin(loop_phase) * 110.0) * time) * gull_envelope * 0.08
	return (water_bed * (0.35 + slow_swell * 0.42) + gull) * 0.50
