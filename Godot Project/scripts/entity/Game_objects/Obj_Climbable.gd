extends Area2D

onready var coll_shape = $Ladder_Zone
onready var top_collision = $StaticBody2D/CollisionShape2D
onready var top_point = $Top

func _physics_process(_delta):
	if Global.Player.current_state == Global.Player.state.CLIMBING:
		top_collision.disabled = true
	else:
		top_collision.disabled = false
