extends Area3D

@export var damage = 1
@onready var collision = $CollisionShape3D
@onready var disableTimer = $DisableTimer

func tempdisable():
	collision.call_deferred("set","disable",true)
	disableTimer.start()

func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set","disabled",false)
