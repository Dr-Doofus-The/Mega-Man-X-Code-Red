extends "res://scripts/entity/Player/EntityPlayer.gd"

onready var ent_sprite_mat = ent_sprite.get_material()
onready var WeaponManager = $Z_Saber_Manager
onready var charge_fxs = $Sprite/Charge_fxs

func _ready():
	EventBus.emit_signal("PlayerInitialized")
	return_to_normal_palette()

func _physics_process(_delta):
	if Engine.get_physics_frames() % 3 == 0:
		if ent_sprite_mat.get_shader_param("frame_coordinate") != Vector2(0.01,0.01):
			return_to_normal_palette()
		else:
			set_flash_coordinate()

func return_to_normal_palette():
	if GameProgress.current_zero_armor == 0:
		ent_sprite_mat.set_shader_param("frame_coordinate", Vector2(0.01,0.01))
		charge_fxs.get_material().set_shader_param("frame_coordinate",Vector2(0.784, 0.056))
	else:
		ent_sprite_mat.set_shader_param("frame_coordinate", Vector2(0.223,0.01))

func set_flash_coordinate():
	if i_frame_timer.time_left > 0:
			if ent_sprite_mat.get_shader_param("frame_coordinate") != Vector2(0.428,0.01):
				ent_sprite_mat.set_shader_param("frame_coordinate", Vector2(0.428,0.01))
				return
			else:
				return_to_normal_palette()
				return
	if WeaponManager.charge_timer > WeaponManager.charge_threshold[1]:
		ent_sprite_mat.set_shader_param("frame_coordinate", Vector2(0.617,0.01))
		charge_fxs.get_material().set_shader_param("frame_coordinate",Vector2(0.667, 0.056))
		return
	if WeaponManager.charge_timer > WeaponManager.charge_threshold[0]:
		ent_sprite_mat.set_shader_param("frame_coordinate", Vector2(0.832,0.01))
		charge_fxs.get_material().set_shader_param("frame_coordinate",Vector2(0.92, 0.056))
		return
	else:
		return_to_normal_palette()
		return
