extends "res://scripts/entity/Enemy/EntityEnemy.gd"

var player_range = []
var firing = false
onready var cannon_sprite = $Sprite/Cannon_Sprites


func _ready():
	player_range = [global_position.y - 20, global_position.y + 20]

func _physics_process(_delta):
	ent_sprite.position.y = sin(lifetime * 7) * 3

	
	if Global.Player.global_position.y < player_range[0]:
		cannon_sprite.frame = 2
	elif Global.Player.global_position.y > player_range[1]:
		cannon_sprite.frame = 0
	else:
		cannon_sprite.frame = 1


func fire(count):
	var shot : Projectile = Assets.PROJ_X_BUSTER_1.instance()
	ent_sprite.frame = 0
	shot.rotation = deg2rad(20 * ($Sprite/Cannon_Sprites.frame - 1)) * -enemy_direction
	if count % 2 == 0:
		shot.global_position = Vector2(global_position.x + (6 * enemy_direction), global_position.y + ((ent_sprite.frame - 1 ) * -15))
	else:
		shot.global_position = Vector2(global_position.x + (16 * enemy_direction), global_position.y + ((ent_sprite.frame - 1 ) * -10))

	shot.BulletDire = enemy_direction
	shot.hitbox_layer = 2
	shot.auto_rotate_sprite = false
	shot.projectile_speed = 4
	shot.stay = true
	shot.projectile_impact_fx = null
	shot.projectile_impact_sound = null
	

	Global.ViewPort.add_child(shot)
	var puff = Assets.PAR_SMOKE_PUFF_SMALL.instance()
	
	puff.global_position = shot.global_position + Vector2(0,4)
	Global.ViewPort.add_child(puff)
	shot.Hitbox.damage = 2
	Sound.SND_PRJ_X_BUSTER_1_FIRE.play()
	if count > 0:
		$shot_cooldown_timer.start(); yield($shot_cooldown_timer,"timeout")
		fire(count - 1)
	else:
		$reaction_time.start(1.4)
		firing = false



func _on_reaction_time_timeout():
	fire(2)
	firing = true

