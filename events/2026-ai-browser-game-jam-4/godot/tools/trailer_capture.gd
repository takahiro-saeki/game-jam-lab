extends Node2D

# Deterministic 60-second gameplay-first marketing capture. Run through Godot Movie Maker:
# godot --path godot --scene res://tools/trailer_capture.tscn \
#   --write-movie ../submission/trailer/volt-nomad-trailer-v2-silent.avi \
#   --resolution 1920x1080 --fixed-fps 30 --disable-vsync --audio-driver Dummy
#
# The game is the real ChargeClicker node. Only progression and presentation are
# staged; combat, UI, particles, skill trees, and defeat VFX are drawn by the game.

const ChargeClicker = preload("res://games/charge_clicker/charge_clicker.gd")
const StageCatalog = preload("res://games/charge_clicker/stage_catalog.gd")
const DisplayFont = preload("res://assets/fonts/DotGothic16-Regular.ttf")
const UIFont = preload("res://assets/fonts/NotoSansJP-Variable.ttf")

const VIEW := Vector2(1280, 720)
const DURATION := 60.0
const CYAN := Color("4deeea")
const AMBER := Color("ffbd32")
const VIOLET := Color("b96cff")
const PAPER := Color("f5f0db")
const MUTED := Color("9aabc1")
const INK := Color("030713")

var game: Node2D
var elapsed := 0.0
var phase := -1
var phase_started := 0.0
var attack_timer := 0.0
var key_art: Texture2D
var prime_art: Texture2D

var beats := [
	{"start": 0.0, "end": 4.5, "id": "hunt_intro", "caption": "CLICK. DEAL DAMAGE. BANK CHARGE.", "accent": CYAN},
	{"start": 4.5, "end": 10.0, "id": "hunt_growth", "caption": "SPEND IT. BUILD AN ARSENAL THAT HUNTS WITHOUT YOU.", "accent": AMBER},
	{"start": 10.0, "end": 16.0, "id": "tree", "caption": "FIVE INTERLOCKING GEAR TREES. 317 RANKS TO REBUILD.", "accent": VIOLET},
	{"start": 16.0, "end": 21.0, "id": "map", "caption": "CHOOSE ANY THREE BEASTS FOR A FAST ENDING.", "accent": CYAN},
	{"start": 21.0, "end": 27.0, "id": "hunt_alt", "caption": "EVERY BEAST CHANGES THE RHYTHM — AND LEAVES ITS CORE.", "accent": AMBER},
	{"start": 27.0, "end": 34.0, "id": "world_engine", "caption": "HUNT ALL SIX TO BREAK THE WORLD ENGINE.", "accent": CYAN},
	{"start": 34.0, "end": 40.0, "id": "prime_one", "caption": "THEN ANSWER THE SIGNAL BENEATH IT.", "accent": VIOLET},
	{"start": 40.0, "end": 47.0, "id": "prime_three", "caption": "FIVE OVERLIMITS. THREE FORMS. ONE LAST CURRENT.", "accent": Color("ff5d68")},
	{"start": 47.0, "end": 51.5, "id": "collapse", "caption": "BREAK THE LAST LAW.", "accent": PAPER},
	{"start": 51.5, "end": 55.0, "id": "prime_art", "caption": "RECOVER EVERY MEMORY.", "accent": VIOLET},
	{"start": 55.0, "end": 60.0, "id": "final", "caption": "PLAY IN BROWSER", "accent": AMBER},
]


func _ready() -> void:
	# Recording must never send unexpected sound to the desktop. Music is mixed
	# into the finished trailer in a separate, level-controlled pass.
	AudioServer.set_bus_mute(0, true)
	key_art = load_submission_texture("key-art/volt-nomad-key-art-master.png")
	prime_art = load_submission_texture("trailer/prime-current-reveal-1920x1080.png")
	game = ChargeClicker.new()
	game.set("persistence_enabled", false)
	game.set("browser_test_muted", true)
	game.set("is_japanese", false)
	game.set("art_preview_enabled", true)
	game.set("campaign_preview_screen", "title")
	game.z_index = -100
	add_child(game)
	set_phase(0)
	queue_redraw()


func load_submission_texture(relative_path: String) -> Texture2D:
	var path := ProjectSettings.globalize_path("res://../submission/%s" % relative_path)
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		push_error("Trailer asset could not be loaded: %s" % path)
		return null
	return ImageTexture.create_from_image(image)


func _process(delta: float) -> void:
	elapsed += delta
	var next_phase := beat_index_at(elapsed)
	if next_phase != phase:
		set_phase(next_phase)
	var id := str(beats[phase].id)
	if id in ["hunt_intro", "hunt_growth", "hunt_alt", "world_engine", "prime_one", "prime_three"]:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = 0.24 if id == "hunt_intro" else 0.18 if id == "hunt_growth" else 0.32 if id == "hunt_alt" else 0.46
			game.call("perform_charge", false, -1)
	if elapsed >= DURATION:
		get_tree().quit()
	queue_redraw()


func beat_index_at(time: float) -> int:
	for index in range(beats.size()):
		if time < float(beats[index].end):
			return index
	return beats.size() - 1


func set_phase(index: int) -> void:
	phase = clampi(index, 0, beats.size() - 1)
	phase_started = elapsed
	attack_timer = 0.05
	var id := str(beats[phase].id)
	game.visible = id not in ["prime_art", "final"]
	game.set("title_screen_open", false)
	game.set("gear_tree_open", false)
	game.set("story_event_open", false)
	game.set("story_log_open", false)
	game.set("tutorial_open", false)
	game.set("defeat_preview_open", false)
	game.call("clear_comms")
	match id:
		"hunt_intro":
			configure_intro_fight()
		"hunt_growth":
			configure_fight("gearmaw", false)
		"map":
			game.set("campaign_preview_screen", "map")
			game.get("run").call("reset")
			game.get("campaign_route").call("reset")
			game.set("campaign_selected", 0)
		"hunt_alt":
			configure_fight("relay_hydra", false)
		"tree":
			configure_skill_tree()
		"world_engine":
			configure_fight("arch_singularity", false)
		"prime_one":
			configure_fight("prime_current_form_1", true)
		"prime_three":
			configure_fight("prime_current_form_3", true)
		"collapse":
			configure_fight("prime_current_form_3", true)
			game.call("start_encounter_defeat_preview", "prime_current_form_3", false, 4.4)
		"prime_art", "final":
			pass
	game.queue_redraw()


func configure_intro_fight() -> void:
	game.set("campaign_preview_screen", "")
	game.set("art_preview_encounter", "gearmaw")
	game.get("run").call("reset")
	game.get("campaign_route").call("reset")
	game.get("campaign_route").call("select_stage", "gearmaw")
	var definition: Dictionary = StageCatalog.stage("gearmaw")
	game.get("run").call("begin_stage", "gearmaw", str(definition.build_tag), 1.0, StageCatalog.stage_hp("gearmaw", 0), 0)
	game.get("run").set("boss_hp", float(game.get("run").get("boss_max_hp")) * 0.82)
	game.get("run").set("credits", 8.0)
	game.set("title_screen_open", false)
	game.set("gear_tree_open", false)
	game.set("story_event_open", false)
	game.call("clear_comms")


func configure_fight(encounter_id: String, final_boss: bool) -> void:
	game.set("campaign_preview_screen", "")
	game.set("art_preview_encounter", encounter_id)
	if final_boss:
		game.set("debug_battle_id", encounter_id)
		game.set("debug_battle_overlimit_count", 5)
		game.call("configure_debug_battle")
		game.set("story_event_open", false)
		game.call("clear_comms")
		game.get("run").set("boss_hp", float(game.get("run").get("boss_max_hp")) * 0.68)
	else:
		game.call("configure_art_preview_state")
	game.set("title_screen_open", false)
	game.set("gear_tree_open", false)


func configure_skill_tree() -> void:
	game.set("campaign_preview_screen", "")
	game.set("art_preview_encounter", "gearmaw")
	game.call("configure_art_preview_state")
	game.set("art_preview_tree_gear", "autogun")
	game.set("art_preview_tree_tier", 3)
	game.call("configure_art_preview_tree")
	game.set("selected_tree_tier", 3)
	game.set("selected_gear_index", 2)
	game.set("gear_tree_open", true)


func _draw() -> void:
	var beat: Dictionary = beats[phase]
	var id := str(beat.id)
	var local := elapsed - float(beat.start)
	var length := float(beat.end) - float(beat.start)
	var progress := clampf(local / maxf(0.01, length), 0.0, 1.0)
	if id in ["prime_art", "final"]:
		draw_art_frame(prime_art if id == "prime_art" else key_art, progress, id == "final")
	draw_scanlines()
	if id == "final":
		draw_final_card(progress)
	else:
		draw_caption(str(beat.caption), Color(beat.accent), progress)
	draw_transition(local, length)


func draw_art_frame(texture: Texture2D, progress: float, darken: bool) -> void:
	if texture == null:
		draw_rect(Rect2(Vector2.ZERO, VIEW), INK)
		return
	var zoom := lerpf(1.02, 1.105, progress)
	var size := VIEW * zoom
	var drift := Vector2(lerpf(-18.0, 18.0, progress), lerpf(8.0, -10.0, progress))
	var rect := Rect2((VIEW - size) * 0.5 + drift, size)
	draw_texture_rect(texture, rect, false, Color.WHITE)
	if darken:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.005, 0.009, 0.025, 0.72))


func draw_scanlines() -> void:
	for y in range(0, 720, 5):
		draw_line(Vector2(0, y), Vector2(1280, y), Color(0.1, 0.28, 0.38, 0.035), 1.0)
	draw_rect(Rect2(18, 18, 1244, 684), Color(0.2, 0.9, 0.95, 0.13), false, 1.0)
	draw_string(DisplayFont, Vector2(34, 44), "VOLT NOMAD // TRANSMISSION 06", HORIZONTAL_ALIGNMENT_LEFT, 420, 12, Color(PAPER, 0.68))
	draw_string(DisplayFont, Vector2(1060, 44), "%02d:%02d" % [int(elapsed) / 60, int(elapsed) % 60], HORIZONTAL_ALIGNMENT_RIGHT, 180, 12, Color(CYAN, 0.72))


func draw_caption(text: String, accent: Color, progress: float) -> void:
	var reveal := smoothstep(0.0, 0.16, progress)
	draw_rect(Rect2(0, 616, 1280, 104), Color(0.003, 0.007, 0.019, 0.88 * reveal))
	draw_rect(Rect2(0, 610, lerpf(0.0, 1280.0, reveal), 5), Color(accent, 0.94))
	draw_string(DisplayFont, Vector2(54, 670), text, HORIZONTAL_ALIGNMENT_LEFT, 1172, 22, Color(PAPER, reveal))
	draw_string(UIFont, Vector2(56, 699), "CLICK · BUILD · EVOLVE · DESCEND", HORIZONTAL_ALIGNMENT_LEFT, 760, 11, Color(MUTED, reveal * 0.9))


func draw_final_card(progress: float) -> void:
	var reveal := smoothstep(0.0, 0.22, progress)
	var title_y := lerpf(338.0, 318.0, reveal)
	draw_string(DisplayFont, Vector2(0, title_y - 48.0), "VOLT", HORIZONTAL_ALIGNMENT_CENTER, 1280, 34, Color(CYAN, reveal))
	draw_string(DisplayFont, Vector2(0, title_y + 34.0), "NOMAD", HORIZONTAL_ALIGNMENT_CENTER, 1280, 76, Color(PAPER, reveal))
	draw_line(Vector2(380, title_y + 62), Vector2(900, title_y + 62), Color(AMBER, reveal), 3.0)
	draw_string(DisplayFont, Vector2(0, title_y + 112), "PLAY IN BROWSER", HORIZONTAL_ALIGNMENT_CENTER, 1280, 24, Color(AMBER, reveal))
	draw_string(UIFont, Vector2(0, title_y + 148), "TWO ENDINGS · FULL STORY ARCHIVE · INFINITE MODE", HORIZONTAL_ALIGNMENT_CENTER, 1280, 13, Color(PAPER, reveal * 0.92))
	draw_string(DisplayFont, Vector2(0, 652), "TSGAMESTUDIO.ITCH.IO/VOLT-NOMAD", HORIZONTAL_ALIGNMENT_CENTER, 1280, 15, Color(CYAN, reveal))


func draw_transition(local: float, length: float) -> void:
	var edge := minf(local, length - local)
	var alpha := clampf(1.0 - edge / 0.34, 0.0, 1.0)
	if phase == 0:
		alpha = clampf(1.0 - local / 0.8, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.0, 0.0, 0.0, alpha))
