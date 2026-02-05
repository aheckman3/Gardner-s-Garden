extends Camera2D

@export var follow_target: CharacterBody2D
@export var smooth_speed := 10


func _process(delta):
	if follow_target:
		global_position = global_position.lerp(follow_target.global_position, delta * smooth_speed)
