extends AnimatedSprite


func _init():
	visible = false


func _on_VisibilityNotifier2D_screen_exited():
	visible = false


func _on_VisibilityNotifier2D_screen_entered():
	visible = true
