class_name JamSynth
extends Node

const MIX_RATE := 22050.0

func play_tone(frequency: float, duration: float = 0.1, volume_db: float = -16.0, waveform: int = 0) -> void:
	# Headless CI has no audio consumer; skipping synthesis avoids playback objects
	# remaining alive when a short smoke-test process exits immediately.
	if DisplayServer.get_name() == "headless":
		return
	var player := AudioStreamPlayer.new()
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
		var attack := minf(1.0, t / 0.012)
		var release := minf(1.0, (duration - t) / maxf(0.03, duration * 0.35))
		var envelope := attack * release
		playback.push_frame(Vector2.ONE * sample * envelope * 0.32)
	get_tree().create_timer(duration + 0.12).timeout.connect(player.queue_free)

func play_chord(frequencies: Array[float], duration: float = 0.18, volume_db: float = -22.0) -> void:
	for frequency in frequencies:
		play_tone(frequency, duration, volume_db, 3)

func click() -> void:
	play_tone(720.0, 0.045, -22.0, 1)

func confirm() -> void:
	play_tone(523.25, 0.08, -20.0, 3)
	play_tone(783.99, 0.12, -23.0, 3)

func error() -> void:
	play_tone(110.0, 0.16, -17.0, 2)
