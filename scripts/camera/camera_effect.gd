#class_name CameraEffects
#extends CanvasLayer
#
## Screen darkening effect for health system
#@onready var screen_darkness: ColorRect = $ScreenDarkness
#
## Reference to player's health component
#var health_component: SelfFrequency
#
#func _ready():
	## Make sure we're on top of everything
	#layer = 100
	#
	## Create the screen darkness overlay
	#create_screen_darkness_overlay()
	#
	## Connect to viewport resize signal
	#get_viewport().size_changed.connect(_on_viewport_resized)
	#
	## Try to find the player health component
	#find_health_component()
#
#func create_screen_darkness_overlay():
	## Create ColorRect that covers entire screen
	#screen_darkness = ColorRect.new()
	#screen_darkness.name = "ScreenDarkness"
	#screen_darkness.size = get_viewport().size
	#screen_darkness.color = Color.TRANSPARENT
	#screen_darkness.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#
	## Create the vignette shader material
	#var shader = Shader.new()
	#shader.code = """
	#shader_type canvas_item;
#
	#uniform float darkness_intensity : hint_range(0.0, 1.0) = 0.0;
	#uniform vec4 dark_color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
	#uniform float edge_start : hint_range(0.0, 1.0) = 0.3;
	#uniform float edge_width : hint_range(0.0, 1.0) = 0.4;
#
	#void fragment() {
		#vec4 original_color = texture(TEXTURE, UV);
		#
		#// Calculate distance from center (0.5, 0.5)
		#vec2 center_vec = UV - vec2(0.5, 0.5);
		#float dist_from_center = length(center_vec) * 2.0; // Multiply to get range 0-1
		#
		#// Create vignette effect
		#float vignette = smoothstep(edge_start, edge_start + edge_width, dist_from_center);
		#vignette *= darkness_intensity;
		#
		#// Mix original color with dark color based on vignette
		#vec4 final_color = mix(original_color, dark_color, vignette);
		#COLOR = final_color;
	#}
	#"""
	#
	#var darkness_material = ShaderMaterial.new()
	#darkness_material.shader = shader
	#darkness_material.set_shader_parameter("darkness_intensity", 0.0)
	#darkness_material.set_shader_parameter("dark_color", Color(0.0, 0.0, 0.0, 0.8))
	#darkness_material.set_shader_parameter("edge_start", 0.3)
	#darkness_material.set_shader_parameter("edge_width", 0.4)
	#
	#screen_darkness.material = darkness_material
	#add_child(screen_darkness)
#
#func _on_viewport_resized():
	## Update the darkness overlay when viewport size changes
	#if screen_darkness:
		#screen_darkness.size = get_viewport().size
#
#func find_health_component():
	## Wait a frame for the scene to load properly
	#await get_tree().process_frame
	#
	## Look for the player node with health component
	#var players = get_tree().get_nodes_in_group("player")
	#if players.size() > 0:
		#var player = players[0]
		#if player.has_node("SelfFrequency"):
			#health_component = player.get_node("SelfFrequency")
			#
			#if health_component:
				#health_component.health_changed.connect(_on_health_changed)
				#health_component.damage_taken.connect(_on_damage_taken)
				#print("Camera effects connected to health system")
			#else:
				#print("Health component not found on player")
	#else:
		#print("No player found in group 'player'")
#
#func _on_health_changed(current_health: int, max_health: int):
	#update_darkness_effect(current_health, max_health)
#
#func _on_damage_taken():
	## Optional: Add screen shake or flash effect when taking damage
	#trigger_damage_flash()
#
#func update_darkness_effect(current_health: int, max_health: int):
	#if screen_darkness and screen_darkness.material is ShaderMaterial:
		#var health_percent = float(current_health) / float(max_health)
		## More dramatic darkening as health gets lower
		#var darkness = (1.0 - health_percent) * (1.0 - health_percent)  # Quadratic for more dramatic effect
		#screen_darkness.material.set_shader_parameter("darkness_intensity", darkness)
		#print("Screen darkness: ", darkness)
#
#func trigger_damage_flash():
	## Optional: Add a quick red flash when taking damage
	## You can expand this later
	#pass
#
## Call this manually if auto-connect doesn't work
#func set_health_component(health_comp: SelfFrequency):
	#health_component = health_comp
	#health_component.health_changed.connect(_on_health_changed)
	#health_component.damage_taken.connect(_on_damage_taken)

class_name CameraEffects
extends CanvasLayer

# Don't use @onready - we'll create this node ourselves
var screen_darkness: ColorRect

# Health component reference
var health_component: SelfFrequency

func _ready():
	print("CameraEffects: Starting setup...")
	
	# Make sure we're on top
	layer = 100
	
	# Create the darkness overlay FIRST
	create_screen_darkness_overlay()
	
	# Connect resize
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Find health component
	find_health_component()

func create_screen_darkness_overlay():
	print("CameraEffects: Creating screen darkness overlay...")
	
	# Create ColorRect that covers entire screen
	screen_darkness = ColorRect.new()
	screen_darkness.name = "ScreenDarkness"
	screen_darkness.size = get_viewport().size
	screen_darkness.color = Color(0, 0, 0, 0)  # Start completely transparent
	screen_darkness.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(screen_darkness)
	print("CameraEffects: Screen darkness overlay created")

func _on_viewport_resized():
	if screen_darkness:
		screen_darkness.size = get_viewport().size

func find_health_component():
	print("CameraEffects: Looking for player health component...")
	
	# Wait for scene to load
	await get_tree().process_frame
	
	# Find player - make sure we get the CharacterBody3D, not other nodes in player group
	var players = get_tree().get_nodes_in_group("player")
	var actual_player = null
	
	for potential_player in players:
		if potential_player is CharacterBody3D:
			actual_player = potential_player
			break
	
	if actual_player:
		print("CameraEffects: Found actual player: ", actual_player.name)
		
		# Look for SelfFrequency component
		health_component = actual_player.get_node("SelfFrequency")
		if health_component:
			print("CameraEffects: Found health component!")
			
			# Connect signals
			health_component.health_changed.connect(_on_health_changed)
			health_component.damage_taken.connect(_on_damage_taken)
			health_component.health_depleted.connect(_on_health_depleted)
			
			# Set initial darkness
			var current_health = health_component.get_current_health()
			var max_health = health_component.get_max_health()
			update_darkness_effect(current_health, max_health)
		else:
			print("CameraEffects: ERROR - No SelfFrequency node found on player")
	else:
		print("CameraEffects: ERROR - No actual player character found in 'player' group")

func _on_health_changed(current_health: int, max_health: int):
	print("CameraEffects: Health changed to ", current_health, "/", max_health)
	update_darkness_effect(current_health, max_health)

func _on_damage_taken():
	print("CameraEffects: Damage taken!")

func _on_health_depleted():
	print("CameraEffects: Health depleted! Starting game over darkness...")
	trigger_game_over_darkness()

func update_darkness_effect(current_health: int, max_health: int):
	if not screen_darkness:
		print("CameraEffects: ERROR - screen_darkness is null!")
		return
	
	var health_percent = float(current_health) / float(max_health)
	
	# Calculate darkness (0 = no darkness, 1 = completely black)
	var darkness = 1.0 - health_percent
	
	# Make it more dramatic at low health
	darkness = darkness * darkness
	
	# Set the overlay color (black with transparency based on darkness)
	var alpha = darkness * 0.8  # Max 80% opacity at 0 health
	screen_darkness.color = Color(0, 0, 0, alpha)
	
	print("CameraEffects: Darkness updated - Health: ", current_health, "/", max_health, " Alpha: ", alpha)

func trigger_game_over_darkness():
	print("CameraEffects: Starting game over sequence...")
	
	# Create a tween to gradually darken the entire screen
	var tween = create_tween()
	tween.tween_method(update_game_over_darkness, 0.0, 1.0, 3.0)  # 3 seconds to full black
	tween.tween_callback(game_over_complete)

func update_game_over_darkness(progress: float):
	if screen_darkness:
		# Gradually increase to full black
		screen_darkness.color = Color(0, 0, 0, progress)
		print("Game over progress: ", progress)

func game_over_complete():
	print("CameraEffects: Game over darkness complete!")

# Manual test function
#func _input(event):
	## Manual test - press T to toggle full darkness
	#if event.is_action_pressed("ui_accept"):  # Space bar
		#if screen_darkness:
			#if screen_darkness.color.a > 0:
				## Make transparent
				#screen_darkness.color = Color(0, 0, 0, 0)
				#print("Manual test: Screen darkness OFF")
			#else:
				## Make dark
				#screen_darkness.color = Color(0, 0, 0, 0.8)
				#print("Manual test: Screen darkness ON")
