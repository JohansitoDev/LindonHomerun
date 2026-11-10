extends "res://src/application/ports/pitch_provider.gd"

var _random := RandomNumberGenerator.new()


func _init() -> void:
	_random.randomize()


func next_pitch() -> Dictionary:
	return {"travel_time": _random.randf_range(1.15, 1.65)}
