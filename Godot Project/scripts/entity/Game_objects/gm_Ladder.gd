extends Area2D

var canCLimb

func _unhandled_input(event):
	if event.is_action_pressed("ui_up") and canCLimb and Global.Player.current_state != 10:
		Global.Player.global_position.x = self.global_position.x
		Global.Player.current_state = 10
		Global.Player.IsDashJumping = false
	if event.is_action_pressed("ui_down") and canCLimb and Global.Player.current_state != 10 and not Global.Player.is_on_floor():
		Global.Player.global_position.x = self.global_position.x
		Global.Player.current_state = 10
		Global.Player.IsDashJumping = false		


func _process(_delta):
	
	if Input.is_action_pressed("ui_up") and canCLimb and Global.Player.current_state == 10 and (Global.Player.global_position.y < $CollisionShape2D.position.y - ($CollisionShape2D.shape.extents.y)):
		Global.Player.current_state = 3
	
func _on_Ladder_body_entered(body):
	if body == Global.Player:
		canCLimb = true

func _on_Ladder_body_exited(body):
	if body == Global.Player:
		canCLimb = false
