extends Camera3D
@export var target : Node3D
@export var smoothness : float = 5

func _physics_process(delta: float):
	# If no target is set, do nothing
	if not target:
		return

	# 3. Calculate the camera’s target position
	# We want the player’s X and Y,
	# but we want to keep the camera’s original Z (distance).
	var target_pos = Vector3(target.global_position.x, target.global_position.y, global_position.z)

	# 4. Interpolate (smoothly move) the camera position
	# Instead of “teleporting”, it slides toward the target.
	# This gives a polished platformer-style effect.
	global_position = target_pos
