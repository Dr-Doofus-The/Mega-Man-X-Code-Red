extends Node

onready var PLAYER_X = preload("res://nodes/entity/Players/EntityPlayer_X.tscn")
onready var PLAYER_ZERO = preload("res://nodes/entity/Players/EntityPlayer_Zero.tscn")
onready var PLAYER_AXL = preload("res://nodes/entity/Players/EntityPlayer_Axl.tscn")

onready var PAR_EXPLOSION_STANDARD = preload("res://nodes/particles/other/Par_Explosion_Standard.tscn")
onready var PAR_SLASH_STANDARD = preload("res://nodes/particles/projectiles/player/Zero/par_z_saber_slash_standard.tscn")
onready var PAR_SLASH_STANDARD_X6_EFFECT = preload("res://nodes/particles/projectiles/player/Zero/par_z_saber_slash_standard_x6_thing.tscn")
onready var PAR_TELEPORT_SPARK = preload("res://nodes/particles/player/par_player_teleport_spark.tscn")
onready var PAR_TELEPORT_TRAIL = preload("res://nodes/particles/player/par_player_teleport_trail.tscn")
onready var PAR_DASHSMOKE_TRAIL = preload("res://nodes/particles/player/par_player_dashsmoke_trail.tscn")
onready var PAR_SMOKE_PUFF_SMALL = preload("res://nodes/particles/other/Par_smoke_puff_small.tscn")
onready var PAR_SMOKE_PL_WALL = preload("res://nodes/particles/player/par_player_wall_smoke.tscn")
onready var PAR_SHIELD_HIT = preload("res://nodes/particles/par_shield_hit_impact.tscn")

onready var PROJ_X_BUSTER_1 = preload("res://nodes/entity/Projectile/proj_x_buster_level_1.tscn")
onready var PROJ_X_BUSTER_2 = preload("res://nodes/entity/Projectile/proj_x_buster_level_2.tscn")
onready var PROJ_X_BUSTER_3 = preload("res://nodes/entity/Projectile/proj_x_buster_level_3.tscn")
onready var PROJ_X_BUSTER_ULTIMATE = preload("res://nodes/entity/Projectile/Player/X/proj_x_buster_plasma.tscn")
onready var PROJ_X_BUSTER_GLIDE = preload("res://nodes/entity/Projectile/Player/X/proj_x_buster_glide.tscn")
onready var PROJ_X_WIND_CUTTER = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_wind_cutter.tscn")
onready var PROJ_X_VOLT_TORNADO_SABER = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_volt_tornado_ball.tscn")
onready var PROJ_X_SPREAD_BLAZER = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_Spread_Blazer.tscn")
onready var PROJ_Z_BUSTER_1 = preload("res://nodes/entity/Projectile/Player/Zero/proj_z_buster.tscn")
onready var PROJ_Z_BUSTER_2 = preload("res://nodes/entity/Projectile/Player/Zero/proj_z_buster_level_2.tscn")
onready var PROJ_AXL_COPY_SHOT = preload("res://nodes/entity/Projectile/Player/Axl/proj_axl_copy_shot.tscn")

onready var PROJ_EXP_TOWER = preload("res://nodes/entity/Projectile/Universal/prj_exp_tower_explosion.tscn")
onready var PROJ_ARTILLERY_EXPLOSION = preload("res://nodes/entity/Projectile/Universal/prj_artillery_explosion_spawner.tscn")


onready var PROJ_ENE_GIGADEATH_MISSLE = preload("res://nodes/entity/Projectile/Enemy/proj_enemy_giga_death_missle.tscn")
onready var PROJ_ENE_FLY = preload("res://nodes/entity/Projectile/Enemy/proj_enemy_frog_fly.tscn")


onready var ITEM_DNA_BOOST = preload("res://nodes/entity/Items/Item_Dna_Boost.tscn")



onready var X_WEAP_WINDCUTTER = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Wind_Cutter.tscn")
onready var X_WEAP_VOLTTORNADO = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Volt_Tornado.tscn")
onready var X_WEAP_ARTILLERYMISSLE = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Artillery_Missle.tscn")
onready var X_WEAP_SPLASHLASER = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Splash_Laser.tscn")
onready var X_WEAP_SPREADBLAZER = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Spread_Blazer.tscn")

onready var SPR_FRAME_ARMOR_FOOT_ULT = preload("res://sprites/character/Player/X/sprite_sheet/Armor_parts/Ultimate_Armor/spr_frame_armor_foot_ult.tres")

onready var PROJ_BUSTER_PLASMA_BALL = preload("res://nodes/entity/Projectile/Player/X/proj_x_buster_plasma_ball.tscn")
onready var PROJ_ENE_FLAMETHROWER = preload("res://nodes/entity/Projectile/Enemy/Proj_FlameThrower.tscn")


func _ready():
	pass
