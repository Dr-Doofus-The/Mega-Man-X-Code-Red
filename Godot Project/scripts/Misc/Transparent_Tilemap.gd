extends Area2D



func _on_Transparent_Tilemap_body_entered(body):
	var tw = create_tween()
	tw.tween_property(self,"modulate:a",0.0,0.4)


