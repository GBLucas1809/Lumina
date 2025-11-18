extends Area3D

# ----- EXPORT VARIABLES -----
@export var speed: float = 10.0
@export var damage: int = 10

# ----- INTERNAL VARIABLES -----
var target_position: Vector3
var direction: Vector3
var is_launched: bool = false

# ----- LAUNCH FUNCTION -----
func launch(target: Vector3):
	target_position = target
	direction = (target_position - global_position).normalized()
	is_launched = true

# ----- PHYSICS PROCESS -----
func _physics_process(delta):
	if is_launched:
		global_translate(direction * speed * delta)

		# Check if close enough to target
		if global_position.distance_to(target_position) < 0.5:
			queue_free()

# ----- COLLISION DETECTION -----
func _on_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(damage)
	queue_free()
