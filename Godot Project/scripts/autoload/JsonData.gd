extends Node

onready var weapon_data_list : Array



func _ready():
	weapon_data_list = _get_dictionary_from_json("res://JSON/weapon_list.json")

func _get_dictionary_from_json(path : String) -> Array:
	var f = File.new()
	assert(f.file_exists(path), "This file doesn't exist")
	
	f.open(path,File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)

	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
