extends CanvasLayer
class_name game_hud

signal flash_done()

onready var ready_notif = preload("res://nodes/UI/Notif/UI_Ready_pop_up.tscn")
onready var warning_notif = preload("res://nodes/UI/Notif/UI_Warning_pop_up.tscn")
onready var box_notif = preload("res://nodes/UI/Notif/UI_NotifBox_pop_up.tscn")

onready var pause_menu = $UI_Pause_Menu

onready var hud_anim_player = $AnimationPlayer
onready var boss_health_bar_container = $Boss_Health_bar
onready var timer_text = $timer_text

var focus_before_popup = null


func _ready() -> void:
	
	Global.Current_Hud = self
	
	
func _physics_process(_delta):
	if $timer_text.visible == true:
		$timer_text.text = "%02d:%02d" % [fmod(Global.stage_timer, 60*60) / 60, fmod(Global.stage_timer,60)]
	
func on_player_spawn():
	Transition.get_node("AnimationPlayer").play("Transition_out")
	Global.canPause = false
	var ree = ready_notif.instance() 
	add_child(ree)
	hud_anim_player.play("Hud_Hidden")
	
	var anim_player = ree.get_node("AnimationPlayer")
	yield(anim_player,"animation_started")
	
	Global.emit_signal("SpawnPlayer")
	hud_anim_player.play("ShowHud")	
	yield(anim_player,"animation_finished")
	
	ree.queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("subtank") and Global.Player.HasControl and !pause_menu.visible and GameProgress.Subtank_container.size() > 0 and Global.Player.hp != Global.Player.hp_max and not get_tree().paused:
		var max_val = [0,0]
		if GameProgress.Subtank_container.size() > 1:
			max_val[1] = GameProgress.Subtank_container[1]["juice"]
		if GameProgress.Subtank_container.size() > 0:
			max_val[0] = GameProgress.Subtank_container[0]["juice"]
		

		if max_val[1] > max_val[0] and GameProgress.Subtank_container[1]["juice"] > 0:
			get_tree().paused = true
			subtank_notify(1)
			yield(get_tree().create_timer(0.15),"timeout")
			GameProgress.drain_subtank(1)
			
		elif max_val[0] > max_val[1] and GameProgress.Subtank_container[0]["juice"] > 0:
			get_tree().paused = true
			subtank_notify(0)
			yield(get_tree().create_timer(0.15),"timeout")			
			GameProgress.drain_subtank(0)
			
		else:
			return
		yield(GameProgress,"subtank_refil_done")
		get_tree().paused = false
func warning_notify():
	var warning_ui = warning_notif.instance()
		
	#hud_anim_player.play("HideHud")	
	add_child(warning_ui)
	var anim_player = warning_ui.get_node("AnimationPlayer")
	yield(anim_player,"animation_finished")
	warning_ui.queue_free()

func box_notify(text_1 : String, text_2 : String = ""):

	var pop_up = box_notif.instance()
	pop_up.text = text_1
	pop_up.text_2 = text_2
	if $Notif_Holder.get_child_count() > 0:
		for n in $Notif_Holder.get_children():
			if text_2 != "":
				n.move_down(22)
			else:
				n.move_down(13)
	$Notif_Holder.add_child(pop_up)

func show_timer():
	$timer_text.rect_position.y = -20
	$timer_text.visible = true
	var tw = create_tween()
	tw.tween_property($timer_text,"rect_position:y",10.0,0.2)
	yield(tw,"finished")
	for n in 3:
		yield(get_tree(),"physics_frame")
	blink_element($timer_text,9,4)

	
func blink_element(node,times : int,frames : int):
	if node.visible == true:
		node.visible = false
	else:
		node.visible = true
	for n in frames:
		yield(get_tree(),"physics_frame")
	if times > 0:
		blink_element(node, times - 1, frames)
	else:
		emit_signal("flash_done")
	
	
func subtank_notify(id : int):

	var pop_up = box_notif.instance()
	pop_up.subtank = true
	pop_up.subtank_id = id
	
	if $Notif_Holder.get_child_count() > 0:
		for n in $Notif_Holder.get_children():
			n.move_down(21)
	$Notif_Holder.add_child(pop_up)
