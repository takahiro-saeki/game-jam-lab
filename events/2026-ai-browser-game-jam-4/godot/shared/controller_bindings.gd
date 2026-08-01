class_name JamControllerBindings
extends RefCounted

const SETTINGS_PATH := "user://gamepad_bindings.cfg"
const SECTION := "gamepad"

const ACTIONS := [
	{"id": "primary", "ja": "決定・使用・ジャンプ", "en": "CONFIRM / USE / JUMP"},
	{"id": "secondary", "ja": "サブ操作・ダッシュ・次ツール", "en": "SECONDARY / DASH / NEXT TOOL"},
	{"id": "combat_action", "ja": "攻撃・アクティブ能力", "en": "ATTACK / ACTIVE ABILITY"},
	{"id": "menu", "ja": "ターン終了・ウェーブ開始", "en": "END TURN / LAUNCH WAVE"},
	{"id": "back", "ja": "戻る", "en": "BACK"},
	{"id": "language", "ja": "言語切替", "en": "SWITCH LANGUAGE"},
	{"id": "previous_tool", "ja": "前のツール", "en": "PREVIOUS TOOL"},
	{"id": "next_tool", "ja": "次のツール", "en": "NEXT TOOL"},
]

const DEFAULTS := {
	"primary": JOY_BUTTON_A,
	"secondary": JOY_BUTTON_X,
	"combat_action": JOY_BUTTON_Y,
	"menu": JOY_BUTTON_START,
	"back": JOY_BUTTON_B,
	"language": JOY_BUTTON_BACK,
	"previous_tool": JOY_BUTTON_LEFT_SHOULDER,
	"next_tool": JOY_BUTTON_RIGHT_SHOULDER,
}

const ALLOWED_BUTTONS := [
	JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y,
	JOY_BUTTON_BACK, JOY_BUTTON_START,
	JOY_BUTTON_LEFT_STICK, JOY_BUTTON_RIGHT_STICK,
	JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER,
]

var bindings: Dictionary = {}

func _init() -> void:
	bindings = default_bindings()

static func default_bindings() -> Dictionary:
	return DEFAULTS.duplicate(true)

static func button_label(button: int) -> String:
	match button:
		JOY_BUTTON_A: return "A / ×"
		JOY_BUTTON_B: return "B / ○"
		JOY_BUTTON_X: return "X / □"
		JOY_BUTTON_Y: return "Y / △"
		JOY_BUTTON_BACK: return "VIEW / SHARE"
		JOY_BUTTON_START: return "MENU / OPTIONS"
		JOY_BUTTON_LEFT_STICK: return "L3"
		JOY_BUTTON_RIGHT_STICK: return "R3"
		JOY_BUTTON_LEFT_SHOULDER: return "LB / L1"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB / R1"
		_: return "BUTTON %d" % button

static func is_allowed(button: int) -> bool:
	return button in ALLOWED_BUTTONS

func get_button(action: String) -> int:
	return int(bindings.get(action, DEFAULTS.get(action, JOY_BUTTON_A)))

func load_settings() -> void:
	bindings = default_bindings()
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		var loaded: Dictionary = {}
		var valid := true
		for action in ACTIONS:
			var id := str(action.id)
			var button := int(config.get_value(SECTION, id, DEFAULTS[id]))
			if not is_allowed(button) or button in loaded.values():
				valid = false
				break
			loaded[id] = button
		if valid:
			bindings = loaded
	apply_input_map()

func reset_defaults(save_after: bool = true) -> void:
	bindings = default_bindings()
	apply_input_map()
	if save_after:
		save_settings()

func rebind(action: String, button: int, save_after: bool = true) -> bool:
	if not bindings.has(action) or not is_allowed(button):
		return false
	var previous := get_button(action)
	for other_action in bindings.keys():
		if str(other_action) != action and int(bindings[other_action]) == button:
			bindings[other_action] = previous
			break
	bindings[action] = button
	apply_input_map()
	if save_after:
		save_settings()
	return true

func save_settings() -> void:
	var config := ConfigFile.new()
	for action in ACTIONS:
		var id := str(action.id)
		config.set_value(SECTION, id, get_button(id))
	config.save(SETTINGS_PATH)

func apply_input_map() -> void:
	replace_action_buttons("jump", [get_button("primary"), JOY_BUTTON_DPAD_UP])
	replace_action_buttons("dash", [get_button("secondary"), JOY_BUTTON_DPAD_DOWN])
	replace_action_buttons("attack", [get_button("combat_action")])

func replace_action_buttons(action: StringName, buttons: Array[int]) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			InputMap.action_erase_event(action, event)
	for button in buttons:
		var event := InputEventJoypadButton.new()
		event.button_index = button
		InputMap.action_add_event(action, event)
