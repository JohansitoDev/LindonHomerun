extends RefCounted

enum Phase {
	TITLE,
	PLAYING,
	FINISHED,
}

const ROUND_DURATION := 90.0
const STARTING_OPPORTUNITIES := 3
const HIT_WINDOW := 0.13
const HIT_TARGET := 0.78

var phase: int = Phase.TITLE
var remaining_time := ROUND_DURATION
var homeruns := 0
var opportunities := STARTING_OPPORTUNITIES
var pitch_elapsed := 0.0
var pitch_duration := 1.35
var last_result := ""
var finish_reason := ""


func start_round() -> void:
	phase = Phase.PLAYING
	remaining_time = ROUND_DURATION
	homeruns = 0
	opportunities = STARTING_OPPORTUNITIES
	pitch_elapsed = 0.0
	last_result = ""
	finish_reason = ""


func install_pitch(duration: float) -> void:
	pitch_duration = maxf(duration, 0.1)
	pitch_elapsed = 0.0


func advance(delta: float) -> bool:
	if phase != Phase.PLAYING:
		return false

	remaining_time = maxf(remaining_time - delta, 0.0)
	if remaining_time <= 0.0:
		_finish("time")
		return false

	pitch_elapsed += delta
	if pitch_elapsed >= pitch_duration:
		pitch_elapsed = pitch_duration
		return true
	return false


func resolve_swing() -> bool:
	if phase != Phase.PLAYING:
		return false

	var timing_error := absf(get_pitch_progress() - HIT_TARGET)
	if timing_error <= HIT_WINDOW:
		homeruns += 1
		last_result = "HOME RUN!"
	else:
		_lose_opportunity()
	return true


func register_pitch_miss() -> void:
	if phase == Phase.PLAYING:
		_lose_opportunity()


func get_pitch_progress() -> float:
	if pitch_duration <= 0.0:
		return 1.0
	return clampf(pitch_elapsed / pitch_duration, 0.0, 1.0)


func _lose_opportunity() -> void:
	opportunities -= 1
	last_result = "STRIKE!"
	if opportunities <= 0:
		_finish("opportunities")


func _finish(reason: String) -> void:
	phase = Phase.FINISHED
	finish_reason = reason
