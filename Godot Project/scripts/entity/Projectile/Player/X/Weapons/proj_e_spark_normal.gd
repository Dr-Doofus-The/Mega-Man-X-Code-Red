extends "res://scripts/entity/ProjectileBase.gd"

onready var e_spark_impact_fx = preload("res://nodes/particles/projectiles/player/X/par_e_spark_impact.tscn")
onready var e_spark_split = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_e_spark_split.tscn")

onready var e_spark_spawn = preload("res://sound_assests/projectiles/snd_elec_spark_1.wav")
onready var e_spark_split_1 = preload("res://sound_assests/projectiles/snd_elec_spark_2.wav")
onready var e_spark_split_2 = preload("res://sound_assests/projectiles/snd_elec_spark_3.wav")

onready var split = true

func _ready():
	
	sprite.playing = true
	var _con = $Hitbox.connect("damage_dealt",self,"on_damage")
	add_sound(0)

func _physics_process(_delta):
	
	if $Timer.time_left == 0:
		
		if Engine.get_physics_frames() % 2 == 0:
			projectile_speed += 1
	else:
		projectile_speed = 0
	projectile_speed = int(clamp(projectile_speed,0,6))

func on_damage(_1,_2,_3):
	start_split()

func _on_Area2D_body_entered(_body):
	start_split()

func start_split():
	spawn_fx()
	add_sound(1)
	visible = false
	$Timer.start();yield($Timer,"timeout")
	spawn_split_shot()
	queue_free()	


func add_sound(sound : int):
	var snd = SFX.new()
	match sound:
		0:
			snd.stream = e_spark_spawn
		1:
			snd.stream = e_spark_split_1 if randi() % 2 == 0 else e_spark_split_2
				
	snd.pitch_scale = rand_range(0.95,1.05)
	snd.bus = "Projectiles"
	snd.volume_db = 8
	Global.ViewPort.add_child(snd)

func spawn_fx():
	var fx = e_spark_impact_fx.instance()
	fx.global_position = global_position
	Global.ViewPort.get_child(0).add_child(fx)

func spawn_split_shot():
	for n in [-90, 90]:
		var shot = e_spark_split.instance()
		shot.global_position = global_position
		shot.rotation = deg2rad(n)
		Global.ViewPort.get_child(0).add_child(shot)


