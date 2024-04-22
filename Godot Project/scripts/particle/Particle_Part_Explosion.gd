extends AnimatedSprite

onready var particle_base = preload("res://nodes/particles/ParticleBase.tscn")
export(int) var amount : int
onready var current_frame = 0


func _ready():
	visible = false
	var frame_count = self.frames.get_frame_count("default")
	
	for n in amount:
		spawn_particle()
		if current_frame == frame_count:
			current_frame = 0
		else:
			current_frame += 1

	queue_free()

func spawn_particle():
	var particle = particle_base.instance()
	particle.gravity = 20
	particle.y_movement = rand_range(-3,-6)
	particle.x_movement = rand_range(-3,3)
	particle.global_position = self.global_position
	particle.frames = frames
	particle.animation = animation
	particle.frame = current_frame
	particle.play_animation = false
	particle.start_on_frame_0 = false
	particle.flicker = true
	Global.ViewPort.get_child(0).add_child(particle)
