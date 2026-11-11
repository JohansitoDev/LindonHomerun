extends RefCounted

const AppFlowState = preload("res://src/domain/app_flow_state.gd")

var state = AppFlowState.new()


func tick(delta: float) -> void:
	if state.screen != AppFlowState.Screen.SPLASH:
		return

	state.splash_elapsed = minf(state.splash_elapsed + delta, 10.0)
	if state.splash_elapsed >= 10.0:
		state.screen = AppFlowState.Screen.LOGIN


func sign_in(email: String, password: String) -> bool:
	if state.screen != AppFlowState.Screen.LOGIN:
		return false
	if email.strip_edges().is_empty() or password.strip_edges().is_empty():
		state.message = "Escribe tu correo y tu contraseña para continuar."
		return false

	state.message = ""
	state.screen = AppFlowState.Screen.TEAM_SELECTION
	return true


func show_registration_message() -> void:
	if state.screen == AppFlowState.Screen.LOGIN:
		state.message = "El registro estará disponible en una próxima versión."


func return_to_login() -> void:
	if state.screen != AppFlowState.Screen.SPLASH:
		state.screen = AppFlowState.Screen.LOGIN
		state.message = ""


func select_team(team_index: int) -> bool:
	if state.screen != AppFlowState.Screen.TEAM_SELECTION:
		return false
	if team_index < 0 or team_index >= AppFlowState.TEAM_NAMES.size():
		return false

	state.selected_team_index = team_index
	state.message = ""
	return true


func confirm_team() -> bool:
	if state.screen != AppFlowState.Screen.TEAM_SELECTION:
		return false
	if state.selected_team_index < 0:
		state.message = "Selecciona un equipo para continuar."
		return false

	state.message = ""
	state.screen = AppFlowState.Screen.HOME
	return true


func navigate_to(screen: int) -> bool:
	var allowed_screens: Array[int] = [
		AppFlowState.Screen.HOME,
		AppFlowState.Screen.SHOP,
		AppFlowState.Screen.TEAM_ROSTER,
		AppFlowState.Screen.SETTINGS,
		AppFlowState.Screen.RANKING,
		AppFlowState.Screen.PROFILE,
	]
	if not allowed_screens.has(screen):
		return false

	state.screen = screen
	state.message = ""
	return true


func start_game() -> bool:
	if state.screen != AppFlowState.Screen.HOME and state.screen != AppFlowState.Screen.RESULTS:
		return false

	state.screen = AppFlowState.Screen.GAMEPLAY
	state.message = ""
	return true


func finish_game() -> bool:
	if state.screen != AppFlowState.Screen.GAMEPLAY:
		return false

	state.screen = AppFlowState.Screen.RESULTS
	state.message = ""
	return true


func return_to_home() -> void:
	if state.screen != AppFlowState.Screen.SPLASH and state.screen != AppFlowState.Screen.LOGIN:
		state.screen = AppFlowState.Screen.HOME
		state.message = ""
