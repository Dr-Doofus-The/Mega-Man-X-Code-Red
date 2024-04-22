extends Control

signal DialogEnded()

export var DialogPath = ""
var PortraitPath = "res://sprites/Cutscene/DiaPortaits/"

export(float) var textSpeed = 0.05

onready var Boxtext = $Dialogbox/Box/Text

var dialog

var PhraseNum = 0
var current_speaker
var finished = false
var talking = false

func _ready():
	Global.Current_Hud.hud_anim_player.play("HideHud")	
	dialog = getdialog()
	if dialog[PhraseNum].has("Amount"):
		match int(dialog[PhraseNum]["Amount"]): 
			2:
				$Portrait/ColorRect.visible = true
				$Portrait/ColorRect2.visible = true
			1:
				$Portrait/ColorRect.visible = true
				$Portrait/ColorRect2.visible = false
			0:
				$Portrait/ColorRect.visible = false
				$Portrait/ColorRect2.visible = false		
	get_portrait()
	$AnimationPlayer.play("Open_Dialog_Box")
	yield($AnimationPlayer,"animation_finished")
	$Timer.wait_time = textSpeed


	next_page()


func getdialog() -> Array:
	var file = File.new()
	assert(file.file_exists(DialogPath), "This file doesn't exist")
	
	file.open(DialogPath, File.READ)
	var json = file.get_as_text()
	
	var output = parse_json(json)

	if typeof(output) == TYPE_ARRAY:
		return output
	else:	
		return []

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if finished:
			next_page()
		else:
			Boxtext.visible_characters = len(Boxtext.text)
	if event.is_action_pressed("ui_end") and dialog != null:
		Boxtext.visible_characters = len(Boxtext.text)
		PhraseNum = len(dialog)
		next_page()

func get_portrait():
	if dialog[PhraseNum].has("Character_ID1"):
		var id1_portrait = load(PortraitPath + dialog[PhraseNum]["Character_ID1"] + ".tres")

		$Portrait/ColorRect/Portrait_ID0.frames = id1_portrait
		$Portrait/ColorRect/Portrait_ID0/Portrait_ID0_Mouth.frames = id1_portrait
		$Portrait/ColorRect/Portrait_ID0/Portrait_ID0_Eyes.frames = id1_portrait

		
	if dialog[PhraseNum].has("EmotionID1"):
		$Portrait/ColorRect/Portrait_ID0.animation = dialog[PhraseNum]["EmotionID1"]
		$Portrait/ColorRect/Portrait_ID0/Portrait_ID0_Eyes.animation = dialog[PhraseNum]["EmotionID1"] + "_eyes"
		$Portrait/ColorRect/Portrait_ID0/Portrait_ID0_Mouth.animation = dialog[PhraseNum]["EmotionID1"] + "_mouth"
		

	if dialog[PhraseNum].has("Character_ID2"):
		var id2_portrait = load(PortraitPath + dialog[PhraseNum]["Character_ID2"] + ".tres")

		$Portrait/ColorRect2/Portrait_ID1.frames = id2_portrait
		
	if dialog[PhraseNum].has("EmotionID2"):
		$Portrait/ColorRect2/Portrait_ID1.animation = dialog[PhraseNum]["EmotionID2"]

func next_page() -> void:
	if PhraseNum >= len(dialog):
		$AnimationPlayer.play("Close_Dialog_Box")
		yield($AnimationPlayer,"animation_finished")
		Global.Current_Hud.hud_anim_player.play("ShowHud")	
		emit_signal("DialogEnded")
		queue_free()
		return
	
	finished = false
	get_portrait()
	
	
	if dialog[PhraseNum].has("CurrentSpeaker"):
		current_speaker = int(dialog[PhraseNum]["CurrentSpeaker"])
	
	
	Boxtext.bbcode_text = dialog[PhraseNum]["Text"].to_upper()
	

	
	Boxtext.visible_characters = 0
	
	$AudioStreamPlayer.play()
	
	while Boxtext.visible_characters < len(Boxtext.text):
		Boxtext.visible_characters +=1
		
		if $AudioStreamPlayer.get_playback_position() > 0.05:
			$AudioStreamPlayer.play()
		
		var current_char = Boxtext.text[Boxtext.visible_characters - 1]
		
		if ["!","?","."].has(current_char):
			$Timer.start(0.4)
			talking = false
		elif [","].has(current_char):
			$Timer.start(0.225)
			talking = false
		elif [" "].has(current_char):
			$Timer.start(textSpeed)
			talking = false
		else:
			$Timer.start(textSpeed)
			talking = true
		mouth_animate()
		yield($Timer, "timeout")
	finished = true
	talking = false
	PhraseNum += 1
	return

func mouth_animate():
	if talking:
		match current_speaker:
			1:
				$Portrait/ColorRect/Portrait_ID0/Portrait_ID0_Mouth.playing = true
	

func _on_Portrait_ID0_Mouth_animation_finished():
	$Portrait/ColorRect/Portrait_ID0/Portrait_ID0_Mouth.frame = 0
	if talking == false or current_speaker != 1:
		$Portrait/ColorRect/Portrait_ID0/Portrait_ID0_Mouth.playing = false


func _on_AnimatedSprite_animation_finished():
	if $Dialogbox/Box/AnimatedSprite.animation == "Open":
		$Dialogbox/Box/AnimatedSprite.play("Idle")
