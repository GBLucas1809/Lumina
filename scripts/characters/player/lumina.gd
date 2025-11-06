extends CharacterBody3D

# Reference to our movement component
@onready var movement_component: LuminaMovement = $LuminaMovement

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

func _physics_process(delta):
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
	# Add water visual effects here

func _on_exited_water():
	print("Lumina exited water - buoyancy disabled!")
	# Remove water visual effects here

# Public method to check if player is floating (for other systems)
func is_floating() -> bool:
	return movement_component.is_currently_floating()

func is_in_water() -> bool:
	return movement_component.is_in_water_area()

# Example: If you need to cancel floating from another system (like taking damage)
func cancel_floating():
	movement_component.cancel_floating()
