# test_environment.gd
extends Node3D

@onready var player = $Lumina

func _ready():
	print("Test Environment Ready!")
	print("WASD - Move")
	print("Space - Jump and Float")
	print("Test the platforms and floating mechanics!")

func _input(event):
	# Quick reset if player falls off
	if Input.is_key_pressed(KEY_R):
		reset_player()

func reset_player():
	player.global_position = Vector3(0, 2, 0)
	print("Player reset!")
