class_name JamSynth
extends Node

const MIX_RATE := 22050.0

var variation_index := 0

func play_tone(frequency: float, duration: float = 0.1, volume_db: float = -16.0, waveform: int = 0) -> void:
	# Headless CI has no audio consumer; skipping synthesis avoids playback objects
	# remaining alive when a short smoke-test process exits immediately.
	if DisplayServer.get_name() == "headless":
		return
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	# AudioStreamGenerator is a live stream, not a preloaded sample. Godot's Web
	# backend otherwise follows the project default and rejects it as unsampleable.
	player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = maxf(0.2, duration + 0.08)
	player.stream = generator
	player.volume_db = volume_db
	add_child(player)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	var frame_count := int(MIX_RATE * duration)
	for frame in range(frame_count):
		var t := float(frame) / MIX_RATE
		var phase := TAU * frequency * t
		var sample := sin(phase)
		if waveform == 1:
			sample = 1.0 if sin(phase) >= 0.0 else -1.0
		elif waveform == 2:
			sample = 2.0 * (frequency * t - floor(frequency * t + 0.5))
		elif waveform == 3:
			sample = asin(sin(phase)) * (2.0 / PI)
		elif waveform == 4:
			# Deterministic metallic noise; stable across Web and native builds.
			sample = sin(phase * 1.73 + sin(phase * 0.37) * 8.0) * 0.72 + sin(phase * 4.11) * 0.28
		var attack := minf(1.0, t / 0.012)
		var release := minf(1.0, (duration - t) / maxf(0.03, duration * 0.35))
		var envelope := attack * release
		playback.push_frame(Vector2.ONE * sample * envelope * 0.32)
	get_tree().create_timer(duration + 0.12).timeout.connect(player.queue_free)

func play_sweep(start_frequency: float, end_frequency: float, duration: float = 0.12, volume_db: float = -20.0, waveform: int = 0) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var player := AudioStreamPlayer.new()
	player.bus = "SFX"
	player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = maxf(0.2, duration + 0.08)
	player.stream = generator
	player.volume_db = volume_db
	add_child(player)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	var frame_count := int(MIX_RATE * duration)
	var phase := 0.0
	for frame in range(frame_count):
		var t := float(frame) / MIX_RATE
		var ratio := clampf(t / duration, 0.0, 1.0)
		var frequency := lerpf(start_frequency, end_frequency, ratio * ratio)
		phase += TAU * frequency / MIX_RATE
		var sample := sin(phase)
		if waveform == 1:
			sample = 1.0 if sin(phase) >= 0.0 else -1.0
		elif waveform == 2:
			sample = 2.0 * (phase / TAU - floor(phase / TAU + 0.5))
		elif waveform == 3:
			sample = asin(sin(phase)) * (2.0 / PI)
		elif waveform == 4:
			sample = sin(phase * 1.71 + sin(phase * 0.41) * 7.0) * 0.7 + sin(phase * 3.93) * 0.3
		var attack := minf(1.0, t / 0.008)
		var release := minf(1.0, (duration - t) / maxf(0.025, duration * 0.45))
		playback.push_frame(Vector2.ONE * sample * attack * release * 0.26)
	get_tree().create_timer(duration + 0.12).timeout.connect(player.queue_free)

func play_chord(frequencies: Array[float], duration: float = 0.18, volume_db: float = -22.0) -> void:
	for frequency in frequencies:
		play_tone(frequency, duration, volume_db, 3)

func click() -> void:
	variation_index += 1
	var pitch := 690.0 + float(variation_index % 3) * 34.0
	play_tone(pitch, 0.035, -25.0, 1)
	play_sweep(2400.0, 900.0, 0.025, -32.0, 4)

func confirm() -> void:
	play_sweep(392.0, 659.25, 0.10, -22.0, 3)
	play_tone(987.77, 0.12, -27.0, 3)

func error() -> void:
	play_sweep(196.0, 72.0, 0.18, -19.0, 2)
	play_tone(47.0, 0.14, -25.0, 4)

func charge_attack(critical: bool, generating: bool) -> void:
	variation_index += 1
	if generating:
		play_sweep(180.0, 840.0 + float(variation_index % 3) * 45.0, 0.09, -22.0, 3)
		play_tone(1046.5, 0.07, -31.0, 0)
		return
	var body_pitch := 176.0 + float(variation_index % 4) * 11.0
	play_sweep(body_pitch * 1.35, body_pitch * 0.62, 0.075, -20.0, 2)
	play_sweep(2600.0, 620.0, 0.045, -28.0, 4)
	if critical:
		play_tone(659.25, 0.12, -23.0, 3)
		play_tone(987.77, 0.10, -27.0, 3)

func auto_shot() -> void:
	variation_index += 1
	var pitch := 118.0 + float(variation_index % 5) * 8.0
	play_sweep(pitch * 1.6, pitch, 0.038, -31.0, 1)
	play_sweep(1500.0, 520.0, 0.025, -36.0, 4)

func purchase(tier: int, capstone: bool) -> void:
	var base := 329.63 * pow(1.25, float(maxi(0, tier - 1)))
	play_sweep(base * 0.72, base * 1.4, 0.16 if capstone else 0.10, -21.0, 3)
	play_tone(base * 2.0, 0.16 if capstone else 0.09, -27.0, 0)
	if capstone:
		play_tone(base * 3.0, 0.24, -30.0, 3)

func warning() -> void:
	play_sweep(164.81, 123.47, 0.22, -18.0, 1)
	play_tone(73.42, 0.24, -24.0, 4)

func enemy_defeat() -> void:
	play_sweep(92.5, 46.25, 0.34, -18.0, 4)
	play_chord([196.0, 293.66, 392.0, 587.33], 0.42, -22.0)

func boss_engage() -> void:
	play_sweep(55.0, 110.0, 0.42, -19.0, 4)
	play_chord([110.0, 146.83, 220.0], 0.48, -22.0)
