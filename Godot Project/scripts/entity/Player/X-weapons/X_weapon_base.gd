extends Node2D
class_name X_Weapon

signal fire_shot(lvl)

export (int) var Weapon_Icon_Frame

export (Resource) var normal_shot
export (Resource) var charged_shot
export (String) var saber_anim
export (int) var normal_shot_cost
export (int) var charged_shot_cost
export (int) var saber_shot_cost
export (int) var max_on_screen

export (int) var Ammo_capacity

export (Vector2) onready var color_palette_coordinate
export (Vector2) onready var fire_color_palette_coordinate
export (Color) var Weapon_Color

export (bool) var light_up_on_fire


onready var projectile_spawner = $Projectile_spawner
onready var sound_container = $Sound_container
onready var W_manager = get_parent()

onready var ammo : float = Ammo_capacity setget set_ammo, get_ammo

#Only for Spread Blazer
var heat_level = 0

func set_ammo(value):
	if value != ammo:
		ammo = clamp (value, 0, Ammo_capacity)

func get_ammo():
	return ammo

func fire_shot(lvl):
	
	match lvl:
		4:
			
			if (ammo - charged_shot_cost) < 0:
				pass
			else:
				var charge_shot = charged_shot.instance()
				if charge_shot.get("BulletDire"):
					charge_shot.BulletDire = get_parent().Player.PlayerDirection
				charge_shot.position = get_parent().projectile_spawn_point.global_position
				projectile_spawner.add_child(charge_shot)
				if GameProgress.Head_Part:
					if int(round(charged_shot_cost/2)) == 0:
						ammo -= 1
					else:
						ammo -= int(round(charged_shot_cost/2))
				else:
					ammo -= int(charged_shot_cost)
				
			
			

		1:
			if name != "X_weapon_sniper_missle":
				var shot = normal_shot.instance()
				shot.BulletDire = W_manager.Player.PlayerDirection
				shot.position.y = W_manager.projectile_spawn_point.global_position.y
				shot.position.x = global_position.x + (W_manager.projectile_spawn_point.position.x * W_manager.Player.PlayerDirection)

				projectile_spawner.add_child(shot)
				ammo -= int(normal_shot_cost)
				if $Sound.stream:
					add_sound()
	emit_signal("fire_shot",lvl)
	EventBus.emit_signal("UpdateWeaponInfo")


func saber_attack():

	self.ammo -= int(saber_shot_cost)
	EventBus.emit_signal("UpdateWeaponInfo")

func add_sound():
	var sound = SFX.new()
	sound.stream = $Sound.stream
	sound.bus = "Projectiles"
	sound.volume_db = $Sound.volume_db
	sound_container.add_child(sound)

func reset_heat():
	heat_level = 0
