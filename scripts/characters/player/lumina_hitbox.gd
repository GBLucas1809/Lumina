class_name LuminaHitbox
extends Area3D

signal hit_received(damage_amount)

@export var damage_amount := 1

func _ready():
	# Connect signals
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Make sure collision is enabled
	if has_node("CollisionShape3D"):
		$CollisionShape3D.disabled = false
	
	# Set collision layers
	collision_mask = 2  # Detect layer 2 (enemies)
	collision_layer = 4 # We're on layer 4 (player hitbox)
	
	# Add to player hitbox group
	add_to_group("player_hitbox")
	
	print("Player hitbox ready - watching for enemies")

func _on_area_entered(area: Area3D):
	print("Hitbox detected area: ", area.name)
	if area.is_in_group("enemy_attack"):
		print("PLAYER HIT BY ENEMY ATTACK!")
		hit_received.emit(damage_amount)

func _on_body_entered(body: Node3D):
	print("Hitbox detected body: ", body.name)
	if body.is_in_group("enemy"):
		print("PLAYER HIT BY ENEMY BODY!")
		hit_received.emit(damage_amount)

# Public method to take damage
func take_damage(amount: int):
	print("Hitbox taking damage: ", amount)
	hit_received.emit(amount)
