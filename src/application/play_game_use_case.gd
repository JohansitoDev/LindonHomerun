extends RefCounted

const GameState = preload("res://src/domain/game_state.gd")
const PitchProvider = preload("res://src/application/ports/pitch_provider.gd")

var state = GameState.new()
var _pitch_provider: PitchProvider


func _init(pitch_provider: PitchProvider) -> void:
	_pitch_provider = pitch_provider


func start() -> void:
	state.start_round()
	_install_next_pitch()


func tick(delta: float) -> void:
	var pitch_expired: bool = state.advance(delta)
	if pitch_expired and state.phase == GameState.Phase.PLAYING:
		state.register_pitch_miss()
		if state.phase == GameState.Phase.PLAYING:
			_install_next_pitch()


func swing() -> void:
	if state.resolve_swing() and state.phase == GameState.Phase.PLAYING:
		_install_next_pitch()


func _install_next_pitch() -> void:
	var pitch: Dictionary = _pitch_provider.next_pitch()
	state.install_pitch(float(pitch["travel_time"]))
