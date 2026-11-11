extends RefCounted

enum Screen {
	SPLASH,
	LOGIN,
	TEAM_SELECTION,
	HOME,
	GAMEPLAY,
	RESULTS,
	SHOP,
	TEAM_ROSTER,
	SETTINGS,
	RANKING,
	PROFILE,
}

const TEAM_NAMES: Array[String] = [
	"Tigres del Licey",
	"Águilas Cibaeñas",
	"Águilas Cibaeñas",
	"Leones del Escogido",
	"Leones del Escogido",
	"Toros del Este",
	"Toros del Este",
	"Estrellas Orientales",
	"Gigantes del Cibao",
	"Gigantes del Cibao",
]

var screen := Screen.SPLASH
var splash_elapsed := 0.0
var selected_team_index := -1
var message := ""


func get_loading_progress() -> float:
	return clampf(splash_elapsed / 10.0, 0.0, 1.0)


func get_selected_team_name() -> String:
	if selected_team_index < 0 or selected_team_index >= TEAM_NAMES.size():
		return ""
	return TEAM_NAMES[selected_team_index]
