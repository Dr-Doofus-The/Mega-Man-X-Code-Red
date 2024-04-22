extends Area2D

export (float) var y_wind_force : float = 0.0
export (float) var x_wind_force : float = 0.0


func _on_Wind_area_body_entered(body):
	if body == Global.Player:
		if y_wind_force != 0:
			Global.Player.y_up_force = y_wind_force
		if x_wind_force != 0:
			Global.Player.wind_force_x = x_wind_force

func _on_Wind_area_body_exited(body):
	if body == Global.Player:
		if y_wind_force != 0:
			Global.Player.y_up_force = 0
		if x_wind_force != 0:
			Global.Player.wind_force_x = 0
