extends StaticBody2D

export (NodePath) var Next_Room_path

onready var door_sprite = $Door_Sprite
onready var door_tween = $Tween
export var boss_door : bool = false
export var locked : bool = false
export (int) var door_id : int

export (int, "UP", "RIGHT", "DOWN", "LEFT") var direction = 1

var Next_Room : ReferenceRect

func _ready():
	Next_Room = get_node(Next_Room_path)
	
	var _con = EventBus.connect("UnlockDoor",self,"unlock_door")
	
	match direction:
		1:
			$Detection.position.x -= 2
		3:
			$Detection.position.x +=2
func _on_Detection_body_entered(body):
	if body == Global.Player and not locked:
		Global.Player.isAttacking = false
		Global.Player.set_physics_process(false)
		Global.Player.HasControl = false
		Global.Player.dir = 0
		Global.Player.current_state = Global.Player.state.ANIMATION
		Global.Player.Ghosting = false
		if ["idle", "idle_shoot", "idle_charge_shot"].has(Global.Player.ent_sprite.animation):
			Global.Player.ent_sprite.animation = "Run"
		

		get_tree().paused = true
		Global.canPause = false
		door_sprite.play("default")
		door_sprite.playing = true
		if boss_door:
			yield(get_tree().create_timer(1),"timeout")
			MusicPlayer.fade_music(false, 2)	
		yield(door_sprite,"animation_finished")
		get_tree().paused = false
		Global.GameCamera.target_bottom_limit = Next_Room.margin_bottom
		Global.GameCamera.target_left_limit = Next_Room.margin_left
		Global.GameCamera.target_top_limit = Next_Room.margin_top
		Global.GameCamera.target_right_limit = Next_Room.margin_right
		
		Global.GameCamera.slow_update(2,direction)
		door_tween.interpolate_property(Global.Player, "global_position:x", Global.Player.global_position.x, Global.Player.global_position.x + (Global.Player.collshape.shape.extents.x * 2 + $Detection/CollisionShape2D.shape.extents.x * 2), 2)
		door_tween.start()
		yield(door_tween,"tween_completed")
		door_sprite.play("close")
		Global.Player.set_physics_process(true)
		if Global.Player.is_on_floor():
			Global.Player.current_state = Global.Player.state.IDLE
		else:
			Global.Player.current_state = Global.Player.state.FALLING
		if not boss_door:
			Global.Player.HasControl = true	
			Global.canPause = true
		Global.Player.emit_signal("regained_controls")
		yield(door_sprite,"animation_finished")
		door_sprite.playing = false

func unlock_door(id):
	if id == door_id:
		locked = false

func _on_Door_Sprite_frame_changed():
	match door_sprite.animation:
		"default":
			match door_sprite.frame:
				1:
					$lock_snd.play()
				14:
					$move_snd.play()
				
		"close":
			if boss_door:
				if door_sprite.frame == 0:
					$boss_door_snd.play()
			else:
					
				match door_sprite.frame:
					1:
						$move_snd.play()
					4:
						$lock_snd.play()
					
