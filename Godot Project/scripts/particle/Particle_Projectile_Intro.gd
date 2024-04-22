extends "res://scripts/particle/ParticleBase.gd"

var projectile
var projectile_direction
var spawn_point
var follower

func _process(_delta):
	if follower != null:
		global_position.y = follower.global_position.y
		if projectile_direction > 0:
			global_position.x = follower.global_position.x
		else:
			global_position.x = follower.global_position.x - follower.position.x*2

func _on_ParticleBase_tree_exiting():
	var spawn_projectile = projectile.instance()
	spawn_projectile.BulletDire = projectile_direction
	spawn_projectile.global_position = global_position
	spawn_point.add_child(spawn_projectile)
