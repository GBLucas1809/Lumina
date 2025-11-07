class_name LuminaMovement
extends Node

# Signals to communicate with main controller
signal started_floating()
signal stopped_floating()
signal jumped()
signal entered_water()
signal exited_water()

# Movement variables - export so they appear in Inspector
@export var max_speed := 8.0
@export var acceleration := 15.0
@export var friction := 8.0
@export var jump_velocity := 10.0
@export var gravity := 30.0

# Buoyancy/Float variables
@export var water_float_duration := 3.0  # Longer float in water
@export var air_float_duration := 0.5    # Short floaty jump in air
@export var float_slow_fall_gravity := 5.0

# Water detection
@export var water_detection_ray_length := 2.0

# Internal state
var is_floating := false
var is_in_water := false
var float_timer := 0.0
var character_body: CharacterBody3D

func _ready():
	# Get reference to the parent CharacterBody3D
	character_body = get_parent()
	if not character_body is CharacterBody3D:
		push_error("LuminaMovement must be a child of CharacterBody3D!")

# Main function called every physics frame
func process_movement(delta: float) -> void:
	# Get input direction
	var direction = get_movement_direction()
	
	# Check for water
	check_water_state()
	
	# Handle all movement systems
	handle_movement(direction, delta)
	handle_gravity(delta)
	handle_jump()
	handle_floating(delta)

func check_water_state():
	# Simple water detection using raycast
	var space_state = character_body.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		character_body.global_position,
		character_body.global_position + Vector3.DOWN * water_detection_ray_length
	)
	query.exclude = [character_body]
	
	var result = space_state.intersect_ray(query)
	
	var was_in_water = is_in_water
	is_in_water = false
	
	if result:
		var collider = result.collider
		# Check if we're standing on water (you can use groups, layers, or name checks)
		if collider and (collider.is_in_group("water") or "water" in collider.name.to_lower()):
			is_in_water = true
	
	# Emit signals when water state changes
	if was_in_water != is_in_water:
		if is_in_water:
			entered_water.emit()
		else:
			exited_water.emit()

func get_movement_direction() -> Vector3:
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#input_dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input_dir.normalized()

func handle_movement(direction: Vector3, delta: float) -> void:
	# Horizontal movement (XZ plane)
	var horizontal_velocity = Vector3(character_body.velocity.x, 0, character_body.velocity.z)
	var target_velocity = direction * max_speed
	
	if direction.length() > 0:
		# Accelerate toward target velocity
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction when no input
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, friction * delta)
	
	# Apply horizontal velocity
	character_body.velocity.x = horizontal_velocity.x
	character_body.velocity.z = horizontal_velocity.z
	
	if character_body.velocity.x > 0:
		character_body.rotation.y = 2 * PI
	elif character_body.velocity.x < 0:
		character_body.rotation.y = PI
	

func handle_gravity(delta: float) -> void:
	if not character_body.is_on_floor():
		var current_gravity = float_slow_fall_gravity if is_floating else gravity
		character_body.velocity.y -= current_gravity * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if character_body.is_on_floor() or is_in_water:
			# Normal jump from ground or water
			character_body.velocity.y = jump_velocity
			start_floating()
			jumped.emit()
		elif is_floating and float_timer > 0:
			# Optional: Double jump while floating (only in water)
			if is_in_water:
				character_body.velocity.y = jump_velocity * 0.8
				start_floating()
				jumped.emit()

func handle_floating(delta: float) -> void:
	if is_floating:
		float_timer -= delta
		if float_timer <= 0:
			stop_floating()

func start_floating() -> void:
	if not is_floating:
		is_floating = true
		# Set float duration based on water state
		if is_in_water:
			float_timer = water_float_duration
		else:
			float_timer = air_float_duration
		started_floating.emit()

func stop_floating() -> void:
	if is_floating:
		is_floating = false
		float_timer = 0.0
		stopped_floating.emit()

# Public methods to check state
func is_currently_floating() -> bool:
	return is_floating

func is_in_water_area() -> bool:
	return is_in_water

func get_remaining_float_time() -> float:
	return float_timer

# Method to force stop floating (useful for abilities that cancel floating)
func cancel_floating() -> void:
	stop_floating()

# Method to manually set water state (for area-based detection)
func set_water_state(in_water: bool):
	if is_in_water != in_water:
		is_in_water = in_water
		if in_water:
			entered_water.emit()
		else:
			exited_water.emit()
