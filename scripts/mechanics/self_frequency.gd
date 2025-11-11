#class_name SelfFrequency
#extends Node
#
## Signals for health events
#signal health_changed(current_health, max_health)
#signal health_depleted()
#signal damage_taken()
#
## Health variables
#@export var max_health := 10
#var current_health: int
#
## We'll remove the shader from here and handle it in the camera effects
#func _ready():
	#current_health = max_health
	#print("Health system ready: ", current_health, "/", max_health)
#
#func take_damage(amount: int = 1):
	#if current_health <= 0:
		#return
	#
	#current_health -= amount
	#current_health = max(0, current_health)
	#
	#print("Took damage! Health: ", current_health, "/", max_health)
	#damage_taken.emit()
	#health_changed.emit(current_health, max_health)
	#
	#if current_health <= 0:
		#health_depleted.emit()
#
#func heal(amount: int = 1):
	#current_health += amount
	#current_health = min(current_health, max_health)
	#print("Healed! Health: ", current_health, "/", max_health)
	#health_changed.emit(current_health, max_health)
#
#func get_health_percent() -> float:
	#return float(current_health) / float(max_health)
#
#func is_alive() -> bool:
	#return current_health > 0
#
## Get current health for other systems
#func get_current_health() -> int:
	#return current_health
#
#func get_max_health() -> int:
	#return max_health



class_name SelfFrequency
extends Node

# Signals for health events
signal health_changed(current_health, max_health)
signal health_depleted()
signal damage_taken()

# Health variables
@export var max_health := 10
var current_health: int

func _ready():
	current_health = max_health
	print("Health system ready: ", current_health, "/", max_health)

func take_damage(amount: int = 1):
	if current_health <= 0:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	
	print("Took damage! Health: ", current_health, "/", max_health)
	damage_taken.emit()
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		health_depleted.emit()

func heal(amount: int = 1):
	current_health += amount
	current_health = min(current_health, max_health)
	print("Healed! Health: ", current_health, "/", max_health)
	health_changed.emit(current_health, max_health)

func get_health_percent() -> float:
	return float(current_health) / float(max_health)

func is_alive() -> bool:
	return current_health > 0

func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health
