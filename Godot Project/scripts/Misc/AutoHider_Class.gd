extends VisibilityNotifier2D
class_name AutoHider

export var delete :=false

func _ready():
	var _con1 = connect("screen_entered",self,"on_screen")
	var _con2 = connect("screen_exited",self,"off_screen")
	
func on_screen():
	get_parent().visible = true
	
func off_screen():
	if delete:
		get_parent().queue_free()
	get_parent().visible = false
