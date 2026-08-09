extends Node2D

const ControllerConfig = preload("res://shared/controller_bindings.gd")
const ChargeClicker = preload("res://games/charge_clicker/charge_clicker.gd")

var active_game: Node
var is_japanese := false
var controller_config
var controller_bindings: Dictionary = ControllerConfig.default_bindings()

func _ready() -> void:
	is_japanese = OS.get_locale_language().to_lower().begins_with("ja")
	controller_config = ControllerConfig.new()
	controller_config.load_settings()
	controller_bindings = controller_config.bindings.duplicate(true)
	call_deferred("launch_project_charge")

func launch_project_charge() -> void:
	if active_game != null:
		return
	active_game = ChargeClicker.new()
	active_game.set("is_japanese", is_japanese)
	active_game.set("controller_bindings", controller_bindings.duplicate(true))
	active_game.return_to_menu.connect(return_to_title)
	if active_game.has_signal("language_changed"):
		active_game.connect("language_changed", sync_language)
	add_child(active_game)

func return_to_title() -> void:
	if active_game == null:
		return
	active_game.queue_free()
	active_game = null
	call_deferred("launch_project_charge")

func sync_language(value: bool) -> void:
	is_japanese = value
