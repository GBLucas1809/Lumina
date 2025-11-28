#extends CharacterBody3D
#
## Reference to our movement component
#@onready var movement_component: LuminaMovement = $LuminaMovement
#@onready var health_component: SelfFrequency = $SelfFrequency
#@onready var hitbox: LuminaHitbox = $Hitbox
#
## Game over scene (you'll need to create this)
#@export var game_over_scene: PackedScene
#
#func _ready():
	## Check if movement component exists
	#if not movement_component:
		#push_error("LuminaMovement component not found!")
	#
	## Connect to movement component signals
	#movement_component.started_floating.connect(_on_started_floating)
	#movement_component.stopped_floating.connect(_on_stopped_floating)
	#movement_component.jumped.connect(_on_jumped)
	#movement_component.entered_water.connect(_on_entered_water)
	#movement_component.exited_water.connect(_on_exited_water)
	#
	## Connect health signals
	#if health_component:
		#health_component.health_changed.connect(_on_health_changed)
		#health_component.health_depleted.connect(_on_health_depleted)
		#health_component.damage_taken.connect(_on_damage_taken)
	#
	## Connect hitbox signal
	#if hitbox:
		#hitbox.hit_received.connect(_on_hit_received)
#
#func _physics_process(delta):
	## Let the movement component handle all movement logic
	#movement_component.process_movement(delta)
	#
	## Move the character (this applies the velocity calculated by movement component)
	#move_and_slide()
#
## Health system signal handlers
#func _on_health_changed(current_health: int, max_health: int):
	#print("Health: ", current_health, "/", max_health)
	## This will be connected to your HUD later
#
#func _on_health_depleted():
	#print("Lumina has fallen... Game Over!")
	## Trigger game over sequence
	#trigger_game_over()
#
#func _on_damage_taken():
	#print("Lumina took damage!")
	## Add visual feedback here (screen shake, flash, etc.)
#
#func _on_hit_received(damage_amount: int):
	#if health_component:
		#health_component.take_damage(damage_amount)
#
#func trigger_game_over():
	## Simple game over - you can make this more elaborate
	#if game_over_scene:
		#get_tree().change_scene_to_packed(game_over_scene)
	#else:
		## Fallback: reload current scene
		#get_tree().reload_current_scene()
#
## Existing signal handlers...
#func _on_started_floating():
	#if movement_component.is_in_water_area():
		#print("Lumina started water buoyancy!")
	#else:
		#print("Lumina started short floaty jump!")
#
#func _on_stopped_floating():
	#print("Lumina stopped floating!")
#
#func _on_jumped():
	#print("Lumina jumped!")
#
#func _on_entered_water():
	#print("Lumina entered water - buoyancy enabled!")
#
#func _on_exited_water():
	#print("Lumina exited water - buoyancy disabled!")
#
## Public method to check if player is floating (for other systems)
#func is_floating() -> bool:
	#return movement_component.is_currently_floating()
#
#func is_in_water() -> bool:
	#return movement_component.is_in_water_area()
#
## Example: If you need to cancel floating from another system (like taking damage)
#func cancel_floating():
	#movement_component.cancel_floating()
	#
#func take_damage_from_enemy(damage: int):
	#print("Lumina taking damage from enemy: ", damage)
	#if health_component:
		#health_component.take_damage(damage)
	#
	## Optional: Add knockback or visual effects
	#apply_damage_effects()
#
#func apply_damage_effects():
	## Get the enemy that hit us
	#var enemies = get_tree().get_nodes_in_group("enemy")
	#if enemies.size() > 0:
		#var enemy = enemies[0]
		#var direction_away_from_enemy = (global_position - enemy.global_position).normalized()
		#
		## Apply knockback AWAY from enemy, not fixed direction
		#velocity.y = 8.0  # Upward bounce
		#velocity.x = direction_away_from_enemy.x * 10.0  # Horizontal knockback
		#velocity.z = direction_away_from_enemy.z * 10.0  # Forward/backward knockback
		#
		#print("Knockback applied away from enemy")
	#else:
		## Fallback if no enemy found
		#velocity.y = 8.0
		#velocity.x = -5.0
		#
	## You can add screen shake, flash, etc. here
	#print("Damage effects applied")
	
	
	
extends CharacterBody3D

# Reference to our movement component
@onready var movement_component: LuminaMovement = $LuminaMovement
@onready var health_component: SelfFrequency = $SelfFrequency
@onready var hitbox: LuminaHitbox = $Hitbox

# Game over scene (you'll need to create this)
@export var game_over_scene: PackedScene

# Track if Lumina is alive
var is_alive := true

func _ready():

	# Check if movement component exists
	if not movement_component:
		push_error("LuminaMovement component not found!")
	
	# Connect to movement component signals
	movement_component.started_floating.connect(_on_started_floating)
	movement_component.stopped_floating.connect(_on_stopped_floating)
	movement_component.jumped.connect(_on_jumped)
	movement_component.entered_water.connect(_on_entered_water)
	movement_component.exited_water.connect(_on_exited_water)
	
	# Connect health signals
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.health_depleted.connect(_on_health_depleted)
		health_component.damage_taken.connect(_on_damage_taken)
	
	# Connect hitbox signal
	if hitbox:
		hitbox.hit_received.connect(_on_hit_received)
	
	add_to_group("player")

func _physics_process(delta):
	if not is_alive:
		return  # Don't process movement if dead
	
	# Let the movement component handle all movement logic
	movement_component.process_movement(delta)
	
	# Move the character (this applies the velocity calculated by movement component)
	move_and_slide()


# Signal handlers for movement events
func _on_started_floating():
	if movement_component.is_in_water_area():
		print("Lumina started water buoyancy!")
	else:
		print("Lumina started short floaty jump!")

func _on_stopped_floating():
	print("Lumina stopped floating!")

func _on_jumped():
	print("Lumina jumped!")

func _on_entered_water():
	print("Lumina entered water - buoyancy enabled!")

func _on_exited_water():
	print("Lumina exited water - buoyancy disabled!")

# Public method to check if player is floating (for other systems)
func is_floating() -> bool:
	return movement_component.is_currently_floating()

func is_in_water() -> bool:
	return movement_component.is_in_water_area()

# Example: If you need to cancel floating from another system (like taking damage)
func cancel_floating():
	movement_component.cancel_floating()
	
func _on_started_glowing():
	print("Lumina started glowing!")

func _on_stopped_glowing():
	print("Lumina stopped glowing!")

func _on_hurt_box_hurt(damage: Variant) -> void:
	print("Lumina toke some damage!!")
