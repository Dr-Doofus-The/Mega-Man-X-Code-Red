extends "res://scripts/entity/Player/EntityPlayer.gd"


#onready var flash_anim_player : AnimationPlayer = $Flash_AnimationPlayer

onready var FX_CHARGE_PARTICLES = $Sprite/Charge_fxs

onready var saber_animator = $Saber_AnimPlayer

onready var WeaponManager = $X_Weapon_manager
onready var flash_fire_timer = $Flash_Fire_TImer

onready var current_color_palette : Vector2 = $X_Weapon_manager/X_buster.color_palette_coordinate
onready var current_color_palette_fire = $X_Weapon_manager/X_buster.fire_color_palette_coordinate

onready var flash_coordinate = Vector2.ZERO
onready var charge_fxs_mat = $Sprite/Charge_fxs.get_material()


func _ready():
	EventBus.emit_signal("PlayerInitialized")
	#charge_fxs_mat.set_shader_param("frame_count",ent_sprite.get_material().get_shader_param("frame_count"))
	#charge_fxs_mat.set_shader_param("palette",ent_sprite.get_material().get_shader_param("palette"))
	return_to_standard_palette()

	#Armor Stuff
	match GameProgress.Body_Part:
		GameProgress.Armor.GLIDE:
			damage_resistance = 1.5
	
	match GameProgress.Leg_Part:
		GameProgress.Armor.ULTIMATE:
			$Sprite/Armor/Foot_sprite.frames = Assets.SPR_FRAME_ARMOR_FOOT_ULT
	
	match GameProgress.Head_Part:
		GameProgress.Armor.GLIDE:
			$X_armor_nodes/Glide_Item_detection.set_deferred("monitoring",true)


func _on_Entity_Player_X_Damage_taken(_i_frame,_damage_dealer):
	pass

#func switch_to_fire_palette():
#	ent_sprite.get_material().set_shader_param("frame_coordinate", current_color_palette_fire)	

func return_to_standard_palette():
	if flash_fire_timer.time_left > 0:
		switch_palette(current_color_palette_fire)
	else:
	
		switch_palette(current_color_palette)
	charge_fxs_mat.set_shader_param("frame_coordinate", WeaponManager.current_weapons.color_palette_coordinate)
	

func switch_palette(Coordinates : Vector2):
	ent_sprite.get_material().set_shader_param("frame_coordinate", Coordinates)
	$Sprite/Armor.get_material().set_shader_param("frame_coordinate", Coordinates)


func _on_Glide_Item_detection_body_entered(body):
	if body.has_method("magnetize"):
		body.magnetize()

