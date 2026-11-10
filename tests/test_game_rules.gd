extends SceneTree

const PlayGameUseCase = preload("res://src/application/play_game_use_case.gd")


class FixedPitchProvider extends "res://src/application/ports/pitch_provider.gd":
	func next_pitch() -> Dictionary:
		return {"travel_time": 1.0}


func _initialize() -> void:
	_test_round_duration_and_homerun()
	_test_missed_swing_uses_opportunity()
	_test_round_ends_when_time_runs_out()
	_test_round_ends_after_three_misses()
	print("All game rule tests passed.")
	quit()


func _test_round_duration_and_homerun() -> void:
	var game = PlayGameUseCase.new(FixedPitchProvider.new())
	game.start()
	assert(is_equal_approx(game.state.remaining_time, 90.0))
	game.tick(0.78)
	game.swing()
	assert(game.state.homeruns == 1)
	assert(game.state.opportunities == 3)


func _test_missed_swing_uses_opportunity() -> void:
	var game = PlayGameUseCase.new(FixedPitchProvider.new())
	game.start()
	game.tick(0.2)
	game.swing()
	assert(game.state.homeruns == 0)
	assert(game.state.opportunities == 2)


func _test_round_ends_when_time_runs_out() -> void:
	var game = PlayGameUseCase.new(FixedPitchProvider.new())
	game.start()
	game.tick(90.0)
	assert(game.state.phase == game.state.Phase.FINISHED)
	assert(game.state.finish_reason == "time")


func _test_round_ends_after_three_misses() -> void:
	var game = PlayGameUseCase.new(FixedPitchProvider.new())
	game.start()
	for _opportunity in range(3):
		game.tick(0.2)
		game.swing()
	assert(game.state.phase == game.state.Phase.FINISHED)
	assert(game.state.finish_reason == "opportunities")
