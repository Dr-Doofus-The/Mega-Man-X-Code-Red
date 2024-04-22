extends "res://scripts/entity/Enemy/EntityEnemy.gd"

onready var parachute_bomb = preload("res://nodes/entity/Projectile/Enemy/proj_enemy_parachute_bomb.tscn")

func _ready():
	var _connect = connect("stop_behavior",self,"stop_doing_things")

func _on_Timer_timeout():
	if [Global.Player.state.DYING, Global.Player.state.SPAWNING].has(Global.Player.current_state):
		pass
	else:
		ent_sprite.play("fire")
		$Timer.stop()

func _on_Sprite_animation_finished():
	if ent_sprite.animation == "fire":
		ent_sprite.play("default")
		$Timer.start()


func _on_Sprite_frame_changed():
	if ent_sprite.animation == "fire":
		match ent_sprite.frame:
			4:
				spawn_bomb(0)
			9:
				spawn_bomb(1)
	
func spawn_bomb(pos : int):
	var bombo = parachute_bomb.instance()
	var smoke_fx = puff_fx.instance()
	var spawn_pos
	if pos == 0:
		spawn_pos = global_position + Vector2(16 * enemy_direction, -30)
	else:
		spawn_pos = global_position + Vector2(-13 * enemy_direction, -30)
	
	bombo.global_position = spawn_pos
	smoke_fx.global_position = spawn_pos
	smoke_fx.y_movement = -1
	Global.ViewPort.get_child(0).add_child(bombo)
	Global.ViewPort.get_child(0).add_child(smoke_fx)


func stop_doing_things():
	$Timer.stop()
