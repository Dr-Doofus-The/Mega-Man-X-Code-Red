extends AudioStreamPlayer
class_name SFX

func _ready():
	if bus == "Master":
		bus = "SFX"
	play()
	var _con = connect("finished",self,"finished")
func finished():
	queue_free()
