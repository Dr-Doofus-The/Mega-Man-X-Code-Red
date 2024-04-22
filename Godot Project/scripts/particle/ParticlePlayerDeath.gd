extends AnimatedSprite

onready var particlebase = preload("res://nodes/particles/ParticleBase.tscn")
var ring_spawn_count = 3
var ball_spawn_count = 11

func _ready():
	var _con = EventBus.connect("PlayerSpawned",self,"delete")
	spawn_balls()
	spawn_rings()
	
func spawn_balls():
	while ball_spawn_count > 0:
		for _n in range(4):
			var angle = rand_range(-360,360)
			var particle = particlebase.instance()
			particle.frames = frames
			match Global.Player.character_name:
				0:
					particle.animation = "ball_x"
				1:
					particle.animation = "ball_zero"
				2:
					particle.animation = "ball_axl"
			particle.x_movement = sin(angle) * 8
			particle.y_movement = cos(angle) * 8
			particle.oneshot = false
			particle.z_index = 10
			add_child(particle)
		ball_spawn_count -= 1
		yield(get_tree().create_timer(0.09),"timeout")

func spawn_rings():
	while ring_spawn_count > 0:
		var ballspawn = 8 if ring_spawn_count != 1 else 16
		for n in range(ballspawn):
			var additional_angle = 22.5 if ring_spawn_count % 2 == 0 else 0
			var angle = deg2rad((n * 360/ballspawn) + additional_angle)
			var particle = particlebase.instance()
			particle.frames = frames
			match Global.Player.character_name:
				0:
					particle.animation = "ring_x"
				1:
					particle.animation = "ring_zero"
				2:
					particle.animation = "ring_axl"
			particle.x_movement = sin(angle) * 1.5
			particle.y_movement = cos(angle) * 1.5
			particle.oneshot = false
			particle.z_index = 10
			add_child(particle)
		ring_spawn_count -= 1
		yield(get_tree().create_timer(0.3),"timeout")

func delete():
	queue_free()
