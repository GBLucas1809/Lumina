extends CharacterBody3D

# -------------------- EXPORT VARIABLES --------------------
@export var speed: float = 4.0
@export var gravity: float = 9.8
@export var jump_velocity: float = 6.0
@export var attack_range: float = 2.0
@export var damage_melee: int = 15
@export var damage_ranged: int = 10
@export var blink_count: int = 3
@export var blink_duration: float = 0.15
@export var patrol_point_a: Vector3
@export var patrol_point_b: Vector3
@export var player_path: NodePath
@export var projectile_scene: PackedScene
@export var max_health: int = 50

# -------------------- INTERNAL VARIABLES --------------------
var player: CharacterBody3D
var last_player_position: Vector3
var has_attacked: bool = false
var is_attacking: bool = false
var move_direction: int = 1
var state: int = 0  # 0=PATROL,1=CHASE,2=RANGED_ATTACK,3=MELEE_ATTACK,4=DEAD
var health: int

# -------------------- MESH & MATERIAL --------------------
@onready var mesh: MeshInstance3D = $MeshInstance3D
var mat: StandardMaterial3D
var original_color: Color

# -------------------- READY --------------------
func _ready():
	health = max_health

	if player_path != null:
		player = get_node(player_path)

	# Ensure material exists
	var existing = mesh.get_active_material(0)
	if existing:
		mat = existing.duplicate()
	else:
		mat = StandardMaterial3D.new()
	mesh.set_surface_override_material(0, mat)
	original_color = mat.albedo_color


# -------------------- PHYSICS PROCESS --------------------
func _physics_process(delta):
	if state == 4:  # DEAD
		return

	# Update last player position
	if player != null:
		last_player_position = player.global_position

	match state:
		0: _patrol(delta)
		1: _chase(delta)
		2: pass
		3: pass

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if not is_attacking:
			velocity.y = 0

	# Move using CharacterBody3D built-in velocity
	move_and_slide()


# -------------------- PATROL --------------------
func _patrol(delta):
	var target = patrol_point_b if move_direction == 1 else patrol_point_a
	var direction = (target - global_position)
	direction.y = 0

	if direction.length() < 0.1:
		move_direction *= -1
	else:
		velocity.x = direction.normalized().x * speed
		velocity.z = direction.normalized().z * speed

	# Switch to chase if player is close
	if player != null and global_position.distance_to(player.global_position) <= attack_range * 3:
		state = 1


# -------------------- CHASE --------------------
func _chase(delta):
	if player == null:
		state = 0
		return

	var direction = (player.global_position - global_position)
	direction.y = 0
	var distance = direction.length()
	if distance > 0:
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO

	# Move toward player
	if not is_attacking and distance > attack_range:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

	# Attack when in range
	if distance <= attack_range and not has_attacked:
		if randi() % 2 == 0:
			state = 2
			start_ranged_attack()
		else:
			state = 3
			start_melee_attack()


# -------------------- RANGED ATTACK --------------------
func start_ranged_attack():
	is_attacking = true
	has_attacked = true
	print("Enemy performs RANGED attack!")

	await blink_red()

	if projectile_scene != null:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position + Vector3(0, 1.5, 0)
		if projectile.has_method("launch"):
			projectile.launch(last_player_position)

	is_attacking = false
	state = 0


# -------------------- MELEE ATTACK --------------------
func start_melee_attack():
	is_attacking = true
	has_attacked = true
	print("Enemy performs MELEE attack!")

	await blink_red()

	var jump_direction = (last_player_position - global_position)
	jump_direction.y = 0
	if jump_direction.length() > 0:
		jump_direction = jump_direction.normalized()
	else:
		jump_direction = Vector3.ZERO

	velocity.y = jump_velocity
	velocity.x = jump_direction.x * speed
	velocity.z = jump_direction.z * speed

	await get_tree().create_timer(0.5).timeout
	if player != null and global_position.distance_to(player.global_position) <= attack_range + 1:
		if player.has_method("take_damage"):
			player.take_damage(damage_melee)

	is_attacking = false
	state = 0


# -------------------- BLINKING --------------------
func blink_red() -> void:
	for i in range(blink_count):
		mat.albedo_color = Color(1, 0, 0)
		await get_tree().create_timer(blink_duration).timeout
		mat.albedo_color = original_color
		await get_tree().create_timer(blink_duration).timeout


# -------------------- DAMAGE & DEATH --------------------
func take_damage(amount: int):
	health -= amount
	if health <= 0 and state != 4:
		state = 4
		start_death()


func start_death():
	print("Enemy defeated! Fading out...")
	var fade_time = 1.0
	var tween = Tween.new()
	add_child(tween)
	tween.tween_property(mat, "albedo_color", Color(0,0,0,0), fade_time)
	tween.tween_callback(Callable(self, "queue_free"))
	tween.play()
