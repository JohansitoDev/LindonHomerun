extends Node2D

const GameState = preload("res://src/domain/game_state.gd")
const PlayGameUseCase = preload("res://src/application/play_game_use_case.gd")
const RandomPitchProvider = preload("res://src/adapters/pitch/random_pitch_provider.gd")
const AppFlowState = preload("res://src/domain/app_flow_state.gd")
const StartupFlowUseCase = preload("res://src/application/startup_flow_use_case.gd")
const SPLASH_TEXTURE = preload("res://assets/startup_splash.png")
const LOGIN_TEXTURE = preload("res://assets/login_reference.png")
const TEAM_SELECTION_TEXTURE = preload("res://assets/team_selection.png")
const HOME_TEXTURE = preload("res://assets/home_menu.png")
const GAMEPLAY_TEXTURE = preload("res://assets/gameplay_reference.png")
const VICTORY_TEXTURE = preload("res://assets/victory_reference.png")
const SHOP_TEXTURE = preload("res://assets/shop_reference.png")
const ROSTER_TEXTURE = preload("res://assets/roster_reference.png")
const SETTINGS_TEXTURE = preload("res://assets/settings_reference.png")
const RANKING_TEXTURE = preload("res://assets/ranking_reference.png")
const PROFILE_TEXTURE = preload("res://assets/profile_reference.png")

const SKY := Color("#91d8eb")
const GRASS := Color("#57a94b")
const DEEP_GRASS := Color("#328548")
const DIRT := Color("#b8794c")
const WHITE := Color("#fff8e8")
const INK := Color("#162b37")
const GOLD := Color("#ffd55c")
const LOGIN_PANEL := Rect2(620.0, 54.0, 610.0, 612.0)

var _game = PlayGameUseCase.new(RandomPitchProvider.new())
var _startup = StartupFlowUseCase.new()
var _email_input: LineEdit
var _password_input: LineEdit
var _login_button: Button
var _register_button: Button
var _back_button: Button
var _confirm_team_button: Button
var _pause_button: Button
var _navigation_controls: Dictionary = {}
var _visible_screen: int = -1


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_create_login_controls()
	_sync_controls()


func _process(delta: float) -> void:
	var previous_screen: int = _startup.state.screen
	if previous_screen == AppFlowState.Screen.SPLASH:
		_startup.tick(delta)
		if _startup.state.screen != previous_screen:
			_sync_controls()
	elif _startup.state.screen == AppFlowState.Screen.GAMEPLAY:
		_game.tick(delta)
		if _game.state.phase == GameState.Phase.FINISHED:
			_startup.finish_game()
			_sync_controls()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_screen_touch(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_screen_touch(event.position)


func _handle_screen_touch(position: Vector2) -> void:
	if _startup.state.screen == AppFlowState.Screen.TEAM_SELECTION:
		_select_team_at(position)
	elif _startup.state.screen == AppFlowState.Screen.GAMEPLAY:
		if _pause_button.get_global_rect().has_point(position):
			return
		match _game.state.phase:
			GameState.Phase.TITLE, GameState.Phase.FINISHED:
				_game.start()
			GameState.Phase.PLAYING:
				_game.swing()


func _draw() -> void:
	var bounds := get_viewport_rect()
	var width := bounds.size.x
	var height := bounds.size.y

	match _startup.state.screen:
		AppFlowState.Screen.SPLASH:
			_draw_splash(width, height)
		AppFlowState.Screen.LOGIN:
			_draw_login(width, height)
		AppFlowState.Screen.TEAM_SELECTION:
			_draw_team_selection(width, height)
		AppFlowState.Screen.HOME:
			_draw_reference_screen(HOME_TEXTURE, width, height)
		AppFlowState.Screen.GAMEPLAY:
			_draw_game(width, height)
		AppFlowState.Screen.RESULTS:
			_draw_reference_screen(VICTORY_TEXTURE, width, height)
			_draw_text(
				"Home runs: %d" % _game.state.homeruns,
				width * 0.41,
				height * 0.82,
				18,
				WHITE
			)
		AppFlowState.Screen.SHOP:
			_draw_reference_screen(SHOP_TEXTURE, width, height)
		AppFlowState.Screen.TEAM_ROSTER:
			_draw_reference_screen(ROSTER_TEXTURE, width, height)
		AppFlowState.Screen.SETTINGS:
			_draw_reference_screen(SETTINGS_TEXTURE, width, height)
		AppFlowState.Screen.RANKING:
			_draw_reference_screen(RANKING_TEXTURE, width, height)
		AppFlowState.Screen.PROFILE:
			_draw_reference_screen(PROFILE_TEXTURE, width, height)


func _draw_game(width: float, height: float) -> void:
	draw_texture_rect(GAMEPLAY_TEXTURE, Rect2(0.0, 0.0, width, height), false)
	draw_rect(
		Rect2(width * 0.2, height * 0.015, width * 0.62, height * 0.19),
		Color(0.04, 0.12, 0.28, 0.95)
	)
	_draw_text("HOME RUNS  %02d" % _game.state.homeruns, width * 0.25, height * 0.09, 29, GOLD)
	_draw_text(
		"TIEMPO  %02d" % ceili(_game.state.remaining_time),
		width * 0.49,
		height * 0.09,
		28,
		WHITE
	)
	_draw_text(
		"OPORTUNIDADES  %d" % _game.state.opportunities,
		width * 0.65,
		height * 0.09,
		21,
		WHITE
	)
	_draw_text(
		"TOCA PARA BATEAR",
		width * 0.435,
		height * 0.935,
		18,
		WHITE
	)
	if not _game.state.last_result.is_empty():
		_draw_text(_game.state.last_result, width * 0.45, height * 0.26, 22, GOLD)
	_draw_pitch()


func _draw_reference_screen(texture: Texture2D, width: float, height: float) -> void:
	draw_texture_rect(
		SPLASH_TEXTURE, Rect2(0.0, 0.0, width, height), false, Color(0.35, 0.45, 0.62, 1.0)
	)
	draw_rect(Rect2(0.0, 0.0, width, height), Color(0.02, 0.06, 0.14, 0.48))
	draw_texture_rect(texture, _get_reference_rect(texture, Vector2(width, height)), false)
	if not _startup.state.message.is_empty():
		var message_bounds := Rect2(width * 0.3, height * 0.9, width * 0.4, height * 0.07)
		draw_rect(message_bounds, Color(0.03, 0.1, 0.2, 0.88))
		_draw_text(_startup.state.message, message_bounds.position.x + 14.0, message_bounds.end.y - 12.0, 15, WHITE)


func _get_reference_rect(texture: Texture2D, viewport_size: Vector2) -> Rect2:
	var scale: float = minf(
		viewport_size.x / texture.get_width(), viewport_size.y / texture.get_height()
	)
	var texture_size: Vector2 = texture.get_size() * scale
	return Rect2((viewport_size - texture_size) * 0.5, texture_size)


func _draw_splash(width: float, height: float) -> void:
	draw_texture_rect(SPLASH_TEXTURE, Rect2(0.0, 0.0, width, height), false)
	var progress: float = _startup.state.get_loading_progress()
	var bar_bounds := Rect2(width * 0.22, height * 0.9, width * 0.56, 20.0)
	draw_rect(
		Rect2(bar_bounds.position - Vector2(7.0, 35.0), bar_bounds.size + Vector2(14.0, 49.0)),
		Color(0.03, 0.1, 0.2, 0.8)
	)
	_draw_text("CARGANDO... %d%%" % roundi(progress * 100.0), width * 0.45, height * 0.89, 20, WHITE)
	draw_rect(bar_bounds, Color("#243754"))
	draw_rect(
		Rect2(bar_bounds.position, Vector2(bar_bounds.size.x * progress, bar_bounds.size.y)),
		Color("#ffd55c")
	)


func _draw_login(width: float, height: float) -> void:
	draw_texture_rect(SPLASH_TEXTURE, Rect2(0.0, 0.0, width, height), false, Color(0.42, 0.55, 0.72, 1.0))
	draw_rect(Rect2(0.0, 0.0, width, height), Color(0.02, 0.07, 0.17, 0.52))
	draw_texture_rect_region(
		LOGIN_TEXTURE,
		Rect2(22.0, 52.0, 570.0, 456.0),
		Rect2(0.0, 0.0, 768.0, 615.0)
	)
	for band in range(8):
		var fade_position := Vector2(22.0, 424.0 + band * 7.0)
		var fade_color := Color(0.02, 0.07, 0.17, float(band + 1) / 8.0)
		draw_rect(Rect2(fade_position, Vector2(570.0, 7.0)), fade_color)

	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("#fffdfa")
	panel.corner_radius_top_left = 28
	panel.corner_radius_top_right = 28
	panel.corner_radius_bottom_left = 28
	panel.corner_radius_bottom_right = 28
	draw_style_box(panel, LOGIN_PANEL)
	_draw_text("Iniciar sesión", 755.0, 169.0, 38, Color("#13417b"))
	_draw_text("Correo", 684.0, 245.0, 20, INK)
	_draw_text("Contraseña", 684.0, 354.0, 20, INK)
	if not _startup.state.message.is_empty():
		_draw_text(_startup.state.message, 683.0, 640.0, 15, Color("#9b3434"))
	_draw_text("Demo local: el acceso no requiere conexión.", 690.0, 618.0, 14, Color("#41566b"))


func _draw_team_selection(width: float, height: float) -> void:
	draw_texture_rect(TEAM_SELECTION_TEXTURE, Rect2(0.0, 0.0, width, height), false)
	var selected_index: int = _startup.state.selected_team_index
	if selected_index >= 0:
		var selection_rect: Rect2 = _get_team_card_rect(selected_index, width, height)
		draw_rect(selection_rect, Color(1.0, 0.82, 0.22, 0.18), true)
		draw_rect(selection_rect, GOLD, false, 5.0)
	if not _startup.state.message.is_empty():
		_draw_text(_startup.state.message, width * 0.31, height * 0.98, 16, Color("#fff4d6"))


func _create_login_controls() -> void:
	_email_input = LineEdit.new()
	_email_input.position = Vector2(686.0, 266.0)
	_email_input.size = Vector2(472.0, 58.0)
	_email_input.placeholder_text = "tucorreo@email.com"
	_style_login_input(_email_input)
	add_child(_email_input)

	_password_input = LineEdit.new()
	_password_input.position = Vector2(686.0, 375.0)
	_password_input.size = Vector2(472.0, 58.0)
	_password_input.placeholder_text = "Contraseña"
	_password_input.secret = true
	_style_login_input(_password_input)
	add_child(_password_input)

	_login_button = _create_button(
		"Entrar", Vector2(686.0, 474.0), Vector2(472.0, 72.0), Color("#147ce0"), 29
	)
	_login_button.pressed.connect(_on_login_pressed)

	_register_button = _create_button(
		"¿No tienes cuenta?  Regístrate",
		Vector2(686.0, 552.0),
		Vector2(472.0, 48.0),
		Color("#eaf2fb"),
		17
	)
	_register_button.add_theme_color_override("font_color", Color("#17477b"))
	_register_button.pressed.connect(_on_register_pressed)

	_back_button = _create_overlay_button(
		_get_fullscreen_reference_rect(
			Rect2(13.0, 12.0, 68.0, 66.0), Vector2(1152.0, 768.0)
		)
	)
	_back_button.pressed.connect(_on_back_pressed)

	_confirm_team_button = _create_overlay_button(
		_get_fullscreen_reference_rect(
			Rect2(438.0, 690.0, 286.0, 73.0), Vector2(1152.0, 768.0)
		)
	)
	_confirm_team_button.pressed.connect(_on_confirm_team_pressed)

	_add_reference_button(
		"home_play",
		AppFlowState.Screen.HOME,
		HOME_TEXTURE,
		Rect2(24.0, 1134.0, 350.0, 234.0),
		Callable(self, "_on_start_game_pressed")
	)
	_add_reference_button(
		"home_roster",
		AppFlowState.Screen.HOME,
		HOME_TEXTURE,
		Rect2(397.0, 1134.0, 350.0, 234.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.TEAM_ROSTER)
	)
	_add_reference_button(
		"home_shop",
		AppFlowState.Screen.HOME,
		HOME_TEXTURE,
		Rect2(24.0, 1370.0, 350.0, 240.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.SHOP)
	)
	_add_reference_button(
		"home_ranking",
		AppFlowState.Screen.HOME,
		HOME_TEXTURE,
		Rect2(397.0, 1370.0, 350.0, 240.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.RANKING)
	)
	_add_reference_button(
		"home_settings",
		AppFlowState.Screen.HOME,
		HOME_TEXTURE,
		Rect2(658.0, 166.0, 95.0, 104.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.SETTINGS)
	)

	_add_reference_button(
		"game_pause",
		AppFlowState.Screen.GAMEPLAY,
		GAMEPLAY_TEXTURE,
		Rect2(10.0, 10.0, 80.0, 76.0),
		Callable(self, "_on_return_home_pressed")
	)

	_add_reference_button(
		"results_replay",
		AppFlowState.Screen.RESULTS,
		VICTORY_TEXTURE,
		Rect2(31.0, 1150.0, 338.0, 190.0),
		Callable(self, "_on_start_game_pressed")
	)
	_add_reference_button(
		"results_home",
		AppFlowState.Screen.RESULTS,
		VICTORY_TEXTURE,
		Rect2(399.0, 1150.0, 339.0, 190.0),
		Callable(self, "_on_return_home_pressed")
	)

	_add_reference_button(
		"shop_back",
		AppFlowState.Screen.SHOP,
		SHOP_TEXTURE,
		Rect2(12.0, 12.0, 102.0, 102.0),
		Callable(self, "_on_return_home_pressed")
	)
	for purchase_index in range(4):
		var purchase_x := 44.0 if purchase_index % 2 == 0 else 300.0
		var purchase_y := 420.0 if purchase_index < 2 else 820.0
		_add_reference_button(
			"shop_purchase_%d" % purchase_index,
			AppFlowState.Screen.SHOP,
			SHOP_TEXTURE,
			Rect2(purchase_x, purchase_y, 220.0, 104.0),
			Callable(self, "_on_unavailable_action_pressed")
		)

	_add_reference_button(
		"roster_back",
		AppFlowState.Screen.TEAM_ROSTER,
		ROSTER_TEXTURE,
		Rect2(12.0, 12.0, 94.0, 110.0),
		Callable(self, "_on_return_home_pressed")
	)
	_add_reference_button(
		"roster_statistics",
		AppFlowState.Screen.TEAM_ROSTER,
		ROSTER_TEXTURE,
		Rect2(240.0, 210.0, 480.0, 88.0),
		Callable(self, "_on_unavailable_action_pressed")
	)

	_add_reference_button(
		"settings_music",
		AppFlowState.Screen.SETTINGS,
		SETTINGS_TEXTURE,
		Rect2(505.0, 602.0, 180.0, 88.0),
		Callable(self, "_on_unavailable_action_pressed")
	)
	_add_reference_button(
		"settings_sound",
		AppFlowState.Screen.SETTINGS,
		SETTINGS_TEXTURE,
		Rect2(505.0, 750.0, 180.0, 88.0),
		Callable(self, "_on_unavailable_action_pressed")
	)
	_add_reference_button(
		"settings_logout",
		AppFlowState.Screen.SETTINGS,
		SETTINGS_TEXTURE,
		Rect2(68.0, 1150.0, 310.0, 122.0),
		Callable(self, "_on_logout_pressed")
	)
	_add_reference_button(
		"settings_help",
		AppFlowState.Screen.SETTINGS,
		SETTINGS_TEXTURE,
		Rect2(399.0, 1150.0, 310.0, 122.0),
		Callable(self, "_on_unavailable_action_pressed")
	)

	_add_reference_button(
		"ranking_home",
		AppFlowState.Screen.RANKING,
		RANKING_TEXTURE,
		Rect2(8.0, 1460.0, 142.0, 162.0),
		Callable(self, "_on_return_home_pressed")
	)
	_add_reference_button(
		"ranking_roster",
		AppFlowState.Screen.RANKING,
		RANKING_TEXTURE,
		Rect2(308.0, 1460.0, 146.0, 162.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.TEAM_ROSTER)
	)
	_add_reference_button(
		"ranking_shop",
		AppFlowState.Screen.RANKING,
		RANKING_TEXTURE,
		Rect2(458.0, 1460.0, 146.0, 162.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.SHOP)
	)
	_add_reference_button(
		"ranking_profile",
		AppFlowState.Screen.RANKING,
		RANKING_TEXTURE,
		Rect2(605.0, 1460.0, 158.0, 162.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.PROFILE)
	)

	_add_reference_button(
		"profile_back",
		AppFlowState.Screen.PROFILE,
		PROFILE_TEXTURE,
		Rect2(14.0, 20.0, 110.0, 112.0),
		Callable(self, "_on_navigate_pressed").bind(AppFlowState.Screen.RANKING)
	)
	_add_reference_button(
		"profile_edit",
		AppFlowState.Screen.PROFILE,
		PROFILE_TEXTURE,
		Rect2(50.0, 1130.0, 328.0, 190.0),
		Callable(self, "_on_unavailable_action_pressed")
	)
	_add_reference_button(
		"profile_achievements",
		AppFlowState.Screen.PROFILE,
		PROFILE_TEXTURE,
		Rect2(394.0, 1130.0, 326.0, 190.0),
		Callable(self, "_on_unavailable_action_pressed")
	)

	_pause_button = _navigation_controls["game_pause"]["button"]


func _add_reference_button(
	key: String,
	screen: int,
	texture: Texture2D,
	source_bounds: Rect2,
	callback: Callable
) -> void:
	var button := _create_overlay_button(_map_reference_rect(texture, source_bounds))
	button.pressed.connect(callback)
	_navigation_controls[key] = {"button": button, "screen": screen}


func _map_reference_rect(texture: Texture2D, source_bounds: Rect2) -> Rect2:
	var image_bounds: Rect2 = _get_reference_rect(
		texture, get_viewport_rect().size
	)
	return Rect2(
		image_bounds.position
		+ Vector2(
			source_bounds.position.x * image_bounds.size.x / texture.get_width(),
			source_bounds.position.y * image_bounds.size.y / texture.get_height()
		),
		Vector2(
			source_bounds.size.x * image_bounds.size.x / texture.get_width(),
			source_bounds.size.y * image_bounds.size.y / texture.get_height()
		)
	)


func _get_fullscreen_reference_rect(source_bounds: Rect2, source_size: Vector2) -> Rect2:
	var viewport_size := get_viewport_rect().size
	return Rect2(
		Vector2(
			source_bounds.position.x * viewport_size.x / source_size.x,
			source_bounds.position.y * viewport_size.y / source_size.y
		),
		Vector2(
			source_bounds.size.x * viewport_size.x / source_size.x,
			source_bounds.size.y * viewport_size.y / source_size.y
		)
	)


func _style_login_input(input: LineEdit) -> void:
	input.add_theme_font_size_override("font_size", 19)
	input.add_theme_color_override("font_color", INK)
	input.add_theme_color_override("font_placeholder_color", Color("#8290a2"))
	input.add_theme_stylebox_override("normal", _make_input_style(Color("#ffffff")))
	input.add_theme_stylebox_override("focus", _make_input_style(Color("#f7fbff")))


func _make_input_style(background: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = Color("#cbd3df")
	style.set_border_width_all(2)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	return style


func _create_button(
	label: String, button_position: Vector2, button_size: Vector2, background: Color, font_size: int
) -> Button:
	var button := Button.new()
	button.text = label
	button.position = button_position
	button.size = button_size
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", WHITE)
	button.add_theme_color_override("font_hover_color", WHITE)
	button.add_theme_color_override("font_pressed_color", WHITE)
	button.add_theme_stylebox_override("normal", _make_button_style(background))
	button.add_theme_stylebox_override("hover", _make_button_style(background.lightened(0.1)))
	button.add_theme_stylebox_override("pressed", _make_button_style(background.darkened(0.12)))
	add_child(button)
	return button


func _make_button_style(background: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style


func _create_overlay_button(button_bounds: Rect2) -> Button:
	var button := Button.new()
	button.position = button_bounds.position
	button.size = button_bounds.size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	add_child(button)
	return button


func _sync_controls() -> void:
	_visible_screen = _startup.state.screen
	_email_input.visible = _visible_screen == AppFlowState.Screen.LOGIN
	_password_input.visible = _visible_screen == AppFlowState.Screen.LOGIN
	_login_button.visible = _visible_screen == AppFlowState.Screen.LOGIN
	_register_button.visible = _visible_screen == AppFlowState.Screen.LOGIN
	_back_button.visible = _visible_screen == AppFlowState.Screen.TEAM_SELECTION
	_confirm_team_button.visible = _visible_screen == AppFlowState.Screen.TEAM_SELECTION
	for control_data in _navigation_controls.values():
		var button: Button = control_data["button"]
		button.visible = control_data["screen"] == _visible_screen


func _on_login_pressed() -> void:
	if _startup.sign_in(_email_input.text, _password_input.text):
		_sync_controls()
	queue_redraw()


func _on_register_pressed() -> void:
	_startup.show_registration_message()
	queue_redraw()


func _on_back_pressed() -> void:
	_startup.return_to_login()
	_sync_controls()
	queue_redraw()


func _on_confirm_team_pressed() -> void:
	if _startup.confirm_team():
		_sync_controls()
	queue_redraw()


func _on_navigate_pressed(destination: int) -> void:
	if _startup.navigate_to(destination):
		_sync_controls()
	queue_redraw()


func _on_start_game_pressed() -> void:
	if _startup.start_game():
		_game.start()
		_sync_controls()
	queue_redraw()


func _on_return_home_pressed() -> void:
	_startup.return_to_home()
	_sync_controls()
	queue_redraw()


func _on_logout_pressed() -> void:
	_startup.return_to_login()
	_email_input.clear()
	_password_input.clear()
	_sync_controls()
	queue_redraw()


func _on_unavailable_action_pressed() -> void:
	_startup.state.message = "Esta opcion estara disponible en una proxima version."
	queue_redraw()


func _select_team_at(position: Vector2) -> void:
	if _confirm_team_button.get_global_rect().has_point(position):
		return
	if _back_button.get_global_rect().has_point(position):
		return

	for team_index in range(AppFlowState.TEAM_NAMES.size()):
		if _get_team_card_rect(
			team_index, get_viewport_rect().size.x, get_viewport_rect().size.y
		).has_point(position):
			_startup.select_team(team_index)
			queue_redraw()
			return


func _get_team_card_rect(team_index: int, width: float, height: float) -> Rect2:
	var column: int = team_index % 5
	var row: int = int(team_index / 5)
	var card_x_positions: Array[float] = [52.0, 267.0, 482.0, 693.0, 907.0]
	var card_y_positions: Array[float] = [158.0, 428.0]
	var card_width := 191.0
	var card_height := 251.0
	return Rect2(
		card_x_positions[column] * width / 1152.0,
		card_y_positions[row] * height / 768.0,
		card_width * width / 1152.0,
		card_height * height / 768.0
	)


func _draw_ballpark(width: float, height: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(width, height)), SKY)
	draw_circle(Vector2(width * 0.84, height * 0.17), 38.0, Color("#ffe28a"))
	draw_rect(Rect2(0, height * 0.34, width, height * 0.16), Color("#507a80"))
	draw_rect(Rect2(0, height * 0.39, width, height * 0.045), Color("#f1a75e"))

	for seat_index in range(13):
		var seat_x := float(seat_index) * width / 12.0
		draw_line(
			Vector2(seat_x, height * 0.34),
			Vector2(seat_x + 24.0, height * 0.47),
			Color("#e9d39b"),
			3.0
		)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(width * 0.5, height * 0.42),
			Vector2(width * 0.95, height * 0.72),
			Vector2(width * 0.5, height * 1.08),
			Vector2(width * 0.05, height * 0.72),
		]),
		GRASS
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(width * 0.5, height * 0.54),
			Vector2(width * 0.77, height * 0.72),
			Vector2(width * 0.5, height * 0.93),
			Vector2(width * 0.23, height * 0.72),
		]),
		DEEP_GRASS
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(width * 0.5, height * 0.66),
			Vector2(width * 0.69, height * 0.72),
			Vector2(width * 0.5, height * 0.88),
			Vector2(width * 0.31, height * 0.72),
		]),
		DIRT
	)
	_draw_diamond(width, height)
	_draw_batter(width, height)
	_draw_pitcher(width, height)


func _draw_diamond(width: float, height: float) -> void:
	var home := Vector2(width * 0.5, height * 0.86)
	var first := Vector2(width * 0.62, height * 0.73)
	var second := Vector2(width * 0.5, height * 0.61)
	var third := Vector2(width * 0.38, height * 0.73)
	draw_line(home, first, WHITE, 3.0)
	draw_line(first, second, WHITE, 3.0)
	draw_line(second, third, WHITE, 3.0)
	draw_line(third, home, WHITE, 3.0)

	for base in [home, first, second, third]:
		draw_colored_polygon(
			PackedVector2Array([
				base + Vector2(0.0, -9.0),
				base + Vector2(9.0, 0.0),
				base + Vector2(0.0, 9.0),
				base + Vector2(-9.0, 0.0),
			]),
			WHITE
		)


func _draw_batter(width: float, height: float) -> void:
	var x := width * 0.32
	var ground := height * 0.78
	draw_line(Vector2(x, ground - 58.0), Vector2(x - 6.0, ground - 24.0), INK, 17.0)
	draw_line(Vector2(x, ground - 58.0), Vector2(x + 24.0, ground - 24.0), INK, 15.0)
	draw_line(Vector2(x, ground - 104.0), Vector2(x - 25.0, ground - 57.0), Color("#f0a76e"), 19.0)
	draw_line(Vector2(x + 4.0, ground - 102.0), Vector2(x + 29.0, ground - 68.0), Color("#f0a76e"), 18.0)
	draw_line(Vector2(x, ground - 108.0), Vector2(x + 12.0, ground - 59.0), Color("#276194"), 37.0)
	draw_circle(Vector2(x + 4.0, ground - 132.0), 22.0, Color("#f0a76e"))
	draw_arc(Vector2(x + 2.0, ground - 142.0), 24.0, PI, TAU, 16, Color("#e64743"), 11.0)
	draw_line(Vector2(x + 24.0, ground - 72.0), Vector2(x + 55.0, ground - 110.0), Color("#613d26"), 7.0)


func _draw_pitcher(width: float, height: float) -> void:
	var x := width * 0.69
	var ground := height * 0.58
	draw_line(Vector2(x, ground - 48.0), Vector2(x - 8.0, ground - 5.0), Color("#274e6d"), 13.0)
	draw_line(Vector2(x, ground - 48.0), Vector2(x + 15.0, ground - 5.0), Color("#274e6d"), 13.0)
	draw_line(Vector2(x, ground - 82.0), Vector2(x - 22.0, ground - 53.0), Color("#f0a76e"), 10.0)
	draw_line(Vector2(x + 2.0, ground - 82.0), Vector2(x + 21.0, ground - 70.0), Color("#f0a76e"), 10.0)
	draw_line(Vector2(x, ground - 86.0), Vector2(x + 4.0, ground - 48.0), Color("#f1f0e8"), 25.0)
	draw_circle(Vector2(x, ground - 104.0), 12.0, Color("#f0a76e"))
	draw_arc(Vector2(x, ground - 109.0), 14.0, PI, TAU, 12, Color("#345d39"), 6.0)


func _draw_title(width: float, height: float) -> void:
	_draw_panel(width * 0.5 - 260.0, height * 0.5 - 140.0, 520.0, 280.0)
	_draw_text("LINDON HOMERUN", width * 0.5 - 206.0, height * 0.5 - 66.0, 40, GOLD)
	_draw_text("90 segundos para conectar el mejor batazo", width * 0.5 - 207.0, height * 0.5 - 14.0, 19, WHITE)
	_draw_text("Toca cuando la pelota llegue a la zona", width * 0.5 - 188.0, height * 0.5 + 24.0, 18, WHITE)
	_draw_text("3 oportunidades  |  Toca para comenzar", width * 0.5 - 180.0, height * 0.5 + 79.0, 18, GOLD)


func _draw_hud(width: float) -> void:
	_draw_panel(20.0, 18.0, width - 40.0, 76.0)
	_draw_text("HOME RUNS  %02d" % _game.state.homeruns, 48.0, 64.0, 27, GOLD)
	_draw_text("TIEMPO  %02d" % ceili(_game.state.remaining_time), width * 0.5 - 72.0, 64.0, 27, WHITE)
	_draw_text("OPORTUNIDADES  %d" % _game.state.opportunities, width - 315.0, 64.0, 21, WHITE)
	if not _game.state.last_result.is_empty():
		_draw_text(_game.state.last_result, width * 0.5 - 82.0, 132.0, 22, GOLD)
	_draw_text("TOCA PARA BATEAR", width * 0.5 - 115.0, 690.0, 18, WHITE)


func _draw_pitch() -> void:
	var progress: float = _game.state.get_pitch_progress()
	var start := Vector2(get_viewport_rect().size.x * 0.69, 292.0)
	var target := Vector2(get_viewport_rect().size.x * 0.505, 526.0)
	var ball_position := start.lerp(target, progress)
	var ball_radius := lerpf(6.0, 20.0, progress)
	draw_circle(ball_position, ball_radius + 3.0, Color(1.0, 1.0, 1.0, 0.24))
	draw_circle(ball_position, ball_radius, WHITE)
	draw_line(
		ball_position + Vector2(-ball_radius * 0.45, -ball_radius * 0.35),
		ball_position + Vector2(ball_radius * 0.45, ball_radius * 0.35),
		Color("#da5b4b"),
		2.0
	)
	draw_arc(
		Vector2(get_viewport_rect().size.x * 0.505, 526.0),
		49.0,
		0.15,
		PI - 0.15,
		28,
		Color(1.0, 0.94, 0.54, 0.8),
		3.0
	)


func _draw_game_over(width: float, height: float) -> void:
	_draw_panel(width * 0.5 - 230.0, height * 0.5 - 120.0, 460.0, 240.0)
	var headline := "TIEMPO!" if _game.state.finish_reason == "time" else "SIN OPORTUNIDADES"
	_draw_text(headline, width * 0.5 - 146.0, height * 0.5 - 42.0, 30, GOLD)
	_draw_text("Home runs: %d" % _game.state.homeruns, width * 0.5 - 79.0, height * 0.5 + 7.0, 23, WHITE)
	_draw_text("Toca para volver a jugar", width * 0.5 - 121.0, height * 0.5 + 62.0, 18, GOLD)


func _draw_panel(x: float, y: float, width: float, height: float) -> void:
	draw_rect(Rect2(x, y, width, height), Color(0.06, 0.12, 0.17, 0.88))
	draw_rect(Rect2(x, y, width, 4.0), GOLD)


func _draw_text(text: String, x: float, y: float, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
