extends Node2D


func _ready():
	Global.Player.invulnerable = true
	var _con = EventBus.connect("PlayerSpawned",self,"_on_Timer_timeout")

func _physics_process(_delta):
	if $Timer.time_left < 1.5:
		if Engine.get_physics_frames() % 3 == 0:
			if Global.Player.ent_sprite.self_modulate == Color(1,1,1):
				Global.Player.ent_sprite.self_modulate = Color(3.5,3.5,3.5)
			else:
				Global.Player.ent_sprite.self_modulate = Color(1,1,1)


func _on_Timer_timeout():
	Global.Player.invulnerable = false
	Global.Player.ent_sprite.self_modulate = Color(1,1,1)
	Global.Player.current_color_palette = Global.Player.WeaponManager.current_weapons.color_palette
	queue_free()
