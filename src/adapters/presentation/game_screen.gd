extends Node2D

const GameState = preload("res://src/domain/game_state.gd")
const PlayGameUseCase = preload("res://src/application/play_game_use_case.gd")
const RandomPitchProvider = preload("res://src/adapters/pitch/random_pitch_provider.gd")

const SKY := Color("#91d8eb")
const GRASS := Color("#57a94b")
const DEEP_GRASS := Color("#328548")
const DIRT := Color("#b8794c")
const WHITE := Color("#fff8e8")
const INK := Color("#162b37")
const GOLD := Color("#ffd55c")

var _game = PlayGameUseCase.new(RandomPitchProvider.new())


func _process(delta: float) -> void:
	if _game.state.phase == GameState.Phase.PLAYING:
		_game.tick(delta)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_tap()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_tap()


func _handle_tap() -> void:
	match _game.state.phase:
		GameState.Phase.TITLE, GameState.Phase.FINISHED:
			_game.start()
		GameState.Phase.PLAYING:
			_game.swing()


func _draw() -> void:
	var bounds := get_viewport_rect()
	var width := bounds.size.x
	var height := bounds.size.y

	_draw_ballpark(width, height)
	if _game.state.phase == GameState.Phase.TITLE:
		_draw_title(width, height)
	elif _game.state.phase == GameState.Phase.PLAYING:
		_draw_hud(width)
		_draw_pitch()
	else:
		_draw_hud(width)
		_draw_game_over(width, height)


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
