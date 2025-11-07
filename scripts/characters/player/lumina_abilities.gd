extends Node

var character_body: CharacterBody3D

@onready var cooldownTimer = $GlowCooldown

var is_glowing := false
var is_on_cooldown := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_body = get_parent()
	if not character_body is CharacterBody3D:
		push_error("LuminaMovement must be a child of CharacterBody3D!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_pressed("glow") and !is_glowing and !is_on_cooldown:
		character_body._on_started_glowing()
		is_glowing = true
		character_body.set_collision_layer_value(2, false)
		character_body.set_collision_mask_value(2, false)
	
	if Input.is_action_just_released("glow") and is_glowing:
		character_body._on_stopped_glowing()
		is_glowing = false
		is_on_cooldown = true
		character_body.set_collision_layer_value(2, true)
		character_body.set_collision_mask_value(2, true)
		cooldownTimer.start()


func _on_glow_cooldown_timeout() -> void:
	is_on_cooldown = false
