extends StaticBody2D

export (String, "head_part", "arm_part", "body_part", "leg_part") var armor_type: String = "leg_part"

onready var dialog_box = preload("res://nodes/managers/DialogManager.tscn")
onready var dr_light_music = "res://sound_assests/music/cutscene/dr_light_theme.ogg"

var dia_finished = false

func _ready():
	$part_icon.animation = armor_type

func _on_Area2D_body_entered(body):
	if body == Global.Player:
		
		Global.canPause = false
		Global.Player.walk_to_point($AnimatedSprite.global_position.x)
		yield(EventBus,"PlayerWalkToDone")
		activate_capsule()


func activate_capsule():
		Global.Player.global_position.x = $AnimatedSprite.global_position.x
		Global.Player.current_state = Global.Player.state.ANIMATION	
		$AnimationPlayer.play("Transmitting")
		Global.Player.ent_sprite.animation = "idle"
		Global.Player.ent_sprite.playing = false
		yield(get_tree().create_timer(3.0), "timeout")
		
		match armor_type:
			"head_part":
				GameProgress.Head_Part = true		
			"arm_part":
				GameProgress.Arm_Part = true		
			"body_part":
				GameProgress.Body_Part = true		
			"leg_part":
				$Shine.play("Leg_part")
				GameProgress.Leg_Part = true
		
		yield($AnimationPlayer,"animation_finished")
		Global.Player.ent_sprite.playing = true
		Global.Player.ent_sprite.animation = "Victory"
		yield(get_tree().create_timer(1.3), "timeout")
		Global.Player.current_state = Global.Player.state.IDLE
		Global.Player.HasControl = true
		Global.canPause = true

func _on_Cutscene_trigger_body_entered(body):
	if body == Global.Player and dia_finished == false:
		
		if global_position.x > Global.Player.global_position.x:
			Global.Player.PlayerDirection = 1
		else:
			$Dr_light_sprite.flip_h = true
			$Dr_light_sprite.offset.x = -2
			Global.Player.PlayerDirection = -1
		Global.canPause = false
		Global.Player.HasControl = false
		Global.Player.dir = 0
		if not Global.Player.is_on_floor():
			yield(Global.Player,"landed")
		

		$Blink_animplayer.play("Blink")
		$AnimationPlayer.play("Open")
		Global.Player.play_stand_animation(0)
		yield($AnimationPlayer,"animation_finished")
		var dia_box = dialog_box.instance()
		MusicPlayer.change_music(dr_light_music)
		match armor_type:
			"leg_part":
				dia_box.DialogPath = "res://JSON/dialog/light_capsules/dia_capsule_foot_part_first.json"
				Global.Current_Hud.add_child(dia_box)
				dia_box.connect("DialogEnded", self, "_on_Dialog_End")
			"head_part":
				dia_box.DialogPath = "res://JSON/dialog/light_capsules/dia_capsule_head_part.json"
				Global.Current_Hud.add_child(dia_box)
				dia_box.connect("DialogEnded", self, "_on_Dialog_End")
		
func _on_Dialog_End():
	$AnimationPlayer.play("Holo_Close")
	Global.Player.play_stand_animation(1)
	
	yield($AnimationPlayer,"animation_finished")
	MusicPlayer.back_to_stage_music()
	MusicPlayer.start_music(true)
	Global.Player.HasControl = true
	Global.canPause = true
	dia_finished = true

func _on_Dr_light_sprite_animation_finished():
	if $Dr_light_sprite.animation == "Entrance":
		$Dr_light_sprite.animation = "Idle"
