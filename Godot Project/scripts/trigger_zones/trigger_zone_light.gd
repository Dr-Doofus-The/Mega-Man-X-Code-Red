extends Area2D

export (float) var light_level



func _on_trigger_zone_light_body_entered(body):
	if body == Global.Player:
		EventBus.emit_signal("UpdateLight",light_level)
