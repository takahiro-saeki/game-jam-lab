extends RefCounted

const DEFAULT_PATH := "user://project_charge_phase2.cfg"
const SECTION := "run"
const KEY := "snapshot"

var save_path := DEFAULT_PATH

func _init(path: String = DEFAULT_PATH) -> void:
	save_path = path

func save(run) -> Error:
	var config := ConfigFile.new()
	config.set_value(SECTION, KEY, run.snapshot())
	return config.save(save_path)

func load_into(run) -> bool:
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return false
	var snapshot: Variant = config.get_value(SECTION, KEY, {})
	if snapshot is not Dictionary:
		return false
	return run.restore_snapshot(snapshot)

func clear() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
