extends TextureRect

onready var mat = get_material()

func _process(delta):
	
	if mat:
		mat.set_shader_param("time",Global.time)
