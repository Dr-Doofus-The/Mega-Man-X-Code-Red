extends ParticleSprite

onready var detector = get_node("Area2D")

func _physics_process(_delta):
	if detector.get_overlapping_bodies().size() == 0:
		queue_free()
