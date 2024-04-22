extends Node
class_name Item_Tank

var type = 0 #Subtank = 0 | Weapon tank = 1

var capacity : int = 20
var juice : int = 0 setget set_juice, get_juice

func get_capacity():
	return capacity

func get_juice():
	return juice
	
func set_juice(new_value):
	if new_value != juice:
		juice = int(clamp(new_value, 0, capacity))
