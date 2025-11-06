# camera_follow.gd
extends Camera3D

@export var target: Node3D
@export var follow_distance := 8.0
@export var follow_height := 4.0
@export var follow_speed := 5.0

func _ready():
	if not target:
		push_error("Camera target not set!")

func _process(delta):
	if target:
		# Calculate desired camera position
		var target_position = target.global_position
		var camera_position = target_position + Vector3(0, follow_height, follow_distance)
		
		# Smoothly move camera toward desired position
		global_position = global_position.lerp(camera_position, follow_speed * delta)
		
		# Always look at the player
		look_at(target_position)
