extends "res://scripts/entity/Enemy/EntityEnemy.gd"

onready var Detection_Raycast = $RayCast2D
onready var bomb = preload("res://nodes/entity/Projectile/Enemy/proj_enemy_bomb_been_bomb.tscn")
onready var bomb_spawn_point = $Bomb_Spawn_Point


enum state {LOOKING_FOR_TARGET,FIRING,CLOSING,FLYING_AWAY}

var current_state = state.LOOKING_FOR_TARGET


func _ready():
	velocity.x = Movement_Speed * enemy_direction
	
	if enemy_direction == 1:
		bomb_spawn_point.position.x = 6
	else:
		bomb_spawn_point.position.x = -6		
	
func _physics_process(delta):


	ent_sprite.position.y = sin(Global.time * 35)
	#States
	match current_state:
		state.LOOKING_FOR_TARGET:
			velocity.x = lerp(velocity.x,Movement_Speed*enemy_direction,0.1)
			if Detection_Raycast.is_colliding():
				current_state = state.FIRING
		state.FIRING:
			velocity.x = lerp(velocity.x,0,0.17)
			ent_sprite.playing = true
			ent_sprite.play("Open")
			Detection_Raycast.enabled = false
		state.CLOSING:
			ent_sprite.play("Close")


func _on_Float_Anim_Timer_timeout():
	if ent_sprite.position.y == 0:
		ent_sprite.position.y = 1
	else:
		ent_sprite.position.y = 0


func _on_Sprite_animation_finished():
	if ent_sprite.animation == "Open":
	
		$Timer.start(0.2); yield($Timer, "timeout")
		for delay in [0.1,0.125,0.15]:
			$Timer.start(delay); yield($Timer, "timeout")
			var spawn_bomb = bomb.instance()
			spawn_bomb.bomb_direction = enemy_direction
			match delay:
				0.1:
					spawn_bomb.Hspeed = delay * 500
				0.125:
					spawn_bomb.Hspeed = delay * 1400
				0.15:
					spawn_bomb.Hspeed = delay * 2000

			spawn_bomb.global_position = bomb_spawn_point.global_position
			Global.ViewPort.add_child(spawn_bomb)
			velocity.x += 100 * -enemy_direction
		$Timer.start(0.2); yield($Timer, "timeout")
		current_state = state.CLOSING
		
	if ent_sprite.animation == "Close":
		current_state = state.LOOKING_FOR_TARGET
		$Timer.start(2.0); yield($Timer, "timeout")
		Detection_Raycast.enabled = true


