extends Path2D

export (int) var spawn_amount = 1
export (float) var speed = 0.1

func _ready():
	var thing2copy = get_child(0)
	thing2copy.unit_offset = 0
	
	for n in spawn_amount:
		var new = thing2copy.duplicate()
		add_child(new)
		new.unit_offset = (n+1)/float(spawn_amount)
	thing2copy.queue_free()

func _physics_process(delta):
	#pass
	var delta_time = delta * speed
	for n in get_children():
		n.unit_offset += delta_time
