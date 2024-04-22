extends Sprite

onready var data = {"0": [texture, Vector2.ZERO, false,false]}
onready var copy_sprite
onready var count = 0
export var current_count = -2

export var condition : String

func _physics_process(_delta):
	do_record()
	apply_record()

func do_record():
	count += 1
	
	if copy_sprite:
		var display = true if copy_sprite.get_parent().get(condition) else false
		data[String(count)] = [copy_sprite.frames.get_frame(copy_sprite.animation,copy_sprite.frame), copy_sprite.global_position, copy_sprite.flip_h, display]

func apply_record():
	current_count +=1
	var current_data = data.get(String(current_count))
	if current_data != null:
		texture = current_data[0]
		global_position = current_data[1]
		flip_h = current_data[2]
		visible = current_data[3]
		data.erase(String(current_count - 1))
