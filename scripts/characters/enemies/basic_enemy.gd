#class_name BasicEnemy
#extends CharacterBody3D
#
#@export var damage_amount := 1
#var attack_area: Area3D
#var player_node: Node3D
#
#func _ready():
	#setup_attack_area()
	#add_visible_mesh()
	#setup_collision()
	#
	## Find player reference
	#find_player()
	#
	#print("Enemy ready - watching for player")
#
#func find_player():
	#var players = get_tree().get_nodes_in_group("player")
	#if players.size() > 0:
		#player_node = players[0]
		#print("Enemy found player: ", player_node.name)
	#else:
		#print("Enemy: No player found in group")
#
#func setup_attack_area():
	#attack_area = find_child("AttackArea")
	#
	#if attack_area == null:
		#create_attack_area()
	#else:
		#setup_attack_area_signals()
#
#func create_attack_area():
	#attack_area = Area3D.new()
	#attack_area.name = "AttackArea"
	#
	#var collision_shape = CollisionShape3D.new()
	#var shape = SphereShape3D.new()
	#shape.radius = 2.0  # Larger detection area
	#collision_shape.shape = shape
	#
	#attack_area.add_child(collision_shape)
	#add_child(attack_area)
	#
	#setup_attack_area_signals()
	#debug_attack_area()
#
#func setup_attack_area_signals():
	#if attack_area:
		## Clear any existing connections
		#if attack_area.area_entered.is_connected(_on_attack_area_entered):
			#attack_area.area_entered.disconnect(_on_attack_area_entered)
		#if attack_area.body_entered.is_connected(_on_body_entered):
			#attack_area.body_entered.disconnect(_on_body_entered)
		#
		## Connect both area and body entered signals
		#attack_area.area_entered.connect(_on_attack_area_entered)
		#attack_area.body_entered.connect(_on_body_entered)
		#
		#attack_area.add_to_group("enemy_attack")
		#
		## Set collision layers/masks properly
		#attack_area.collision_mask = 1  # Layer 1
		#attack_area.collision_layer = 2  # Layer 2
#
#func setup_collision():
	## Make sure main collision exists
	#var main_collision = find_child("CollisionShape3D")
	#if not main_collision or main_collision.get_parent() == attack_area:
		#main_collision = CollisionShape3D.new()
		#var shape = CapsuleShape3D.new()
		#shape.radius = 0.5
		#shape.height = 2.0
		#main_collision.shape = shape
		#add_child(main_collision)
		#
		## Set collision layers for movement
		#collision_mask = 1  # Layer 1
		#collision_layer = 2  # Layer 2
#
#func add_visible_mesh():
	#var existing_mesh = find_child("EnemyMesh")
	#if existing_mesh:
		#return
	#
	#var mesh_instance = MeshInstance3D.new()
	#mesh_instance.name = "EnemyMesh"
	#
	#var box_mesh = BoxMesh.new()
	#box_mesh.size = Vector3(1, 1, 1)
	#mesh_instance.mesh = box_mesh
	#
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color.RED
	#mesh_instance.material_override = material
	#
	#add_child(mesh_instance)
#
#func _physics_process(delta):
	## Simple movement toward player
	#if player_node and is_alive:
		#var direction = (player_node.global_position - global_position).normalized()
		#
		## Only move if not too close (to avoid pushing)
		#var distance_to_player = global_position.distance_to(player_node.global_position)
		#if distance_to_player > 1.5:  # Stop moving when very close
			#velocity = direction * 3.0  # Movement speed
		#else:
			#velocity = Vector3.ZERO  # Stop moving when close enough
		#
		#move_and_slide()
		#
		## Check for collision with player
		#if distance_to_player < 2.0:
			#attempt_attack()
#
#var is_alive = true
#var attack_cooldown = 1.0  # 1 second between attacks
#var last_attack_time = 0.0
#
#func attempt_attack():
	#var current_time = Time.get_ticks_msec() / 1000.0
	#if current_time - last_attack_time >= attack_cooldown:
		#if player_node and player_node.has_method("take_damage_from_enemy"):
			#player_node.take_damage_from_enemy(damage_amount)
			#print("Enemy attacked player! Time: ", current_time)
			#last_attack_time = current_time
#
#func check_collision_with_player():
	#if player_node:
		#var distance = global_position.distance_to(player_node.global_position)
		#if distance < 2.0:  # If very close to player
			#print("Enemy is very close to player! Distance: ", distance)
			## Try to damage player
			#attempt_attack()
#
## Signal handlers
#func _on_attack_area_entered(area: Area3D):
	#print("Enemy attack area entered by: ", area.name)
	#if area.is_in_group("player_hitbox"):
		#print("ENEMY HIT PLAYER HITBOX!")
		## Damage player through hitbox
		#if area.has_method("take_damage"):
			#area.take_damage(damage_amount)
#
#func _on_body_entered(body: Node3D):
	#print("Enemy body collided with: ", body.name)
	#if body.is_in_group("player"):
		#print("ENEMY DIRECT COLLISION WITH PLAYER!")
		#if body.has_method("take_damage_from_enemy"):
			#body.take_damage_from_enemy(damage_amount)
#
#func debug_attack_area():
	## Print attack area info
	#if attack_area:
		#var shape = attack_area.get_child(0)
		#if shape is CollisionShape3D:
			#print("Attack area shape: ", shape.shape.get_class())
			#print("Attack area radius: ", shape.shape.radius)
#
## Debug: Draw attack area in game
#func _process(_delta):
	#if Input.is_key_pressed(KEY_F1):
		#print("Enemy position: ", global_position)
		#if player_node:
			#print("Player position: ", player_node.global_position)
			#print("Distance to player: ", global_position.distance_to(player_node.global_position))


class_name BasicEnemy
extends CharacterBody3D

@export var damage_amount := 1
var attack_area: Area3D
var player_node: Node3D
var is_alive = true
var attack_cooldown = 2.0  # 2 seconds between attacks
var last_attack_time = 0.0
var initial_position = Vector3.ZERO

func _ready():
	initial_position = global_position
	setup_attack_area()
	add_visible_mesh()
	setup_collision()
	find_player()
	
	print("Enemy ready at position: ", global_position)

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	
	# Filter to only find CharacterBody3D nodes (the actual player)
	for potential_player in players:
		if potential_player is CharacterBody3D:  # Make sure it's the actual player character
			player_node = potential_player
			print("Enemy found player: ", player_node.name)
			return
	
	# If we get here, no proper player was found
	print("Enemy: No valid player found in group")
	player_node = null

func setup_attack_area():
	attack_area = find_child("AttackArea")
	if attack_area == null:
		create_attack_area()
	else:
		setup_attack_area_signals()

func create_attack_area():
	attack_area = Area3D.new()
	attack_area.name = "AttackArea"
	
	var collision_shape = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 2.0
	collision_shape.shape = shape
	
	attack_area.add_child(collision_shape)
	add_child(attack_area)
	setup_attack_area_signals()

func setup_attack_area_signals():
	if attack_area:
		if attack_area.area_entered.is_connected(_on_attack_area_entered):
			attack_area.area_entered.disconnect(_on_attack_area_entered)
		
		attack_area.area_entered.connect(_on_attack_area_entered)
		attack_area.add_to_group("enemy_attack")

func setup_collision():
	var main_collision = find_child("CollisionShape3D")
	if not main_collision or main_collision.get_parent() == attack_area:
		main_collision = CollisionShape3D.new()
		var shape = CapsuleShape3D.new()
		shape.radius = 0.5
		shape.height = 2.0
		main_collision.shape = shape
		add_child(main_collision)

func add_visible_mesh():
	var existing_mesh = find_child("EnemyMesh")
	if existing_mesh:
		return
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "EnemyMesh"
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1, 1, 1)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	mesh_instance.material_override = material
	
	add_child(mesh_instance)

func _physics_process(delta):
	if not is_alive:
		return
		
	if player_node and is_player_alive():
		var direction = (player_node.global_position - global_position).normalized()
		var distance_to_player = global_position.distance_to(player_node.global_position)
		
		# Move toward player but stop at a reasonable distance
		if distance_to_player > 1.5:
			velocity = direction * 3.0
		else:
			velocity = Vector3.ZERO
			# Attack when close enough
			attempt_attack()
		
		move_and_slide()
	else:
		# Stop moving if player is dead or doesn't exist
		velocity = Vector3.ZERO

func is_player_alive() -> bool:
	if player_node and player_node.has_method("get_is_alive"):
		return player_node.get_is_alive()
	return false

func attempt_attack():
	if not is_player_alive():
		return  # Don't attack if player is dead
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time >= attack_cooldown:
		if player_node and player_node.has_method("take_damage_from_enemy"):
			player_node.take_damage_from_enemy(damage_amount)
			print("Enemy attacked player!")
			last_attack_time = current_time

func _on_attack_area_entered(area: Area3D):
	if area.is_in_group("player_hitbox") and is_player_alive():
		print("Enemy detected player in attack area")

# Debug position tracking
func _process(delta):
	if Input.is_key_pressed(KEY_P):
		print("Enemy position: ", global_position)
		if player_node:
			print("Distance to player: ", global_position.distance_to(player_node.global_position))
			print("Player alive: ", is_player_alive())
