class_name JamPalette
extends RefCounted

const UI_FONT_FILE: FontFile = preload("res://assets/fonts/NotoSansJP-Variable.ttf")
static var UI_FONT: FontVariation = make_ui_font()

const INK := Color("09111f")
const PANEL := Color("111d31")
const PANEL_2 := Color("182b43")
const PAPER := Color("f5f0db")
const MUTED := Color("91a4b7")
const CYAN := Color("4deeea")
const BLUE := Color("3a86ff")
const VIOLET := Color("9b5de5")
const MAGENTA := Color("f15bb5")
const AMBER := Color("ffb703")
const CORAL := Color("ff5c5c")
const MINT := Color("55efc4")
const GREEN := Color("71f79f")

static func with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)

static func make_ui_font() -> FontVariation:
	var font := FontVariation.new()
	font.base_font = UI_FONT_FILE
	font.variation_opentype = {"wght": 500.0}
	font.variation_embolden = 0.3
	return font

static func rounded_box(color: Color, radius: int = 16, border_color: Color = Color.TRANSPARENT, border_width: int = 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	if border_width > 0:
		box.border_color = border_color
		box.border_width_left = border_width
		box.border_width_top = border_width
		box.border_width_right = border_width
		box.border_width_bottom = border_width
	return box
