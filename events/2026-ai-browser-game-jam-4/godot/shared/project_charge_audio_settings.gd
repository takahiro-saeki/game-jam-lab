class_name ProjectChargeAudioSettings
extends RefCounted

const SETTINGS_PATH := "user://project_charge_audio.cfg"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const DEFAULT_MASTER_VOLUME := 0.72
const DEFAULT_MUSIC_VOLUME := 0.55
const DEFAULT_SFX_VOLUME := 0.72

var master_volume := DEFAULT_MASTER_VOLUME
var music_volume := DEFAULT_MUSIC_VOLUME
var sfx_volume := DEFAULT_SFX_VOLUME
var screen_shake_intensity := 1.0
var flash_intensity := 1.0
var story_dialogue_enabled := true

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		master_volume = clampf(float(config.get_value("audio", "master_volume", master_volume)), 0.0, 1.0)
		music_volume = clampf(float(config.get_value("audio", "music_volume", music_volume)), 0.0, 1.0)
		sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", sfx_volume)), 0.0, 1.0)
		# Migrate the previous one-button BGM preference without losing it.
		if not bool(config.get_value("audio", "music_enabled", true)):
			music_volume = 0.0
		screen_shake_intensity = clampf(float(config.get_value("accessibility", "screen_shake", screen_shake_intensity)), 0.0, 1.0)
		flash_intensity = clampf(float(config.get_value("accessibility", "flash_intensity", flash_intensity)), 0.0, 1.0)
		story_dialogue_enabled = bool(config.get_value("accessibility", "story_dialogue_enabled", story_dialogue_enabled))
	apply()

func save_settings() -> Error:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "music_enabled", music_volume > 0.001)
	config.set_value("accessibility", "screen_shake", screen_shake_intensity)
	config.set_value("accessibility", "flash_intensity", flash_intensity)
	config.set_value("accessibility", "story_dialogue_enabled", story_dialogue_enabled)
	var error := config.save(SETTINGS_PATH)
	apply()
	return error

func apply() -> void:
	ensure_bus(BUS_MUSIC)
	ensure_bus(BUS_SFX)
	set_bus_linear("Master", master_volume)
	set_bus_linear(BUS_MUSIC, music_volume)
	set_bus_linear(BUS_SFX, sfx_volume)

func reset_defaults() -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	music_volume = DEFAULT_MUSIC_VOLUME
	sfx_volume = DEFAULT_SFX_VOLUME
	screen_shake_intensity = 1.0
	flash_intensity = 1.0
	story_dialogue_enabled = true
	save_settings()

func ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func set_bus_linear(bus_name: String, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, value <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.001)))
