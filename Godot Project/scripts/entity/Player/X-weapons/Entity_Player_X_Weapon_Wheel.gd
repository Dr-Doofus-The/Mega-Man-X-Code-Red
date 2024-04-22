extends Node2D

onready var w_manager = get_node("../X_Weapon_manager")

var right_analog : int
enum right_inputs{none, up, up_right, right, down_right, down, down_left, left, up_left}
var current_input = right_inputs.none
var current_higlight = null

onready var open_timer = $Open_timer

func _ready():
	#This sets the ui containers to represent certain weapons

	#var j = 0
	#for n in get_children():
	#	if n.get_class() == "Sprite":
	#		j += 1
	#		n.weapon_id = j
	#		n.update_id()
	pass

func _unhandled_input(_event):
	#Get the Input for the Right Stick and converts it to degrees
	pass
	
	#if GameProgress.Boss_Defeated_Array.has(true) and not w_manager.is_weapon_projectile_alive():
	#	right_analog = int(rad2deg(Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down").angle()))
	#	check_input()
	#	update_highlight()
	
func check_input():
	#Defines old input in order to compare it to the new one
	var old_input = current_input
	
	if Input.get_vector("right_stick_left", "right_stick_right", "right_stick_up", "right_stick_down") != Vector2.ZERO:
		
		# If the right stick is moved, then start the timer, and if the time left was zero, then open the quick select ring
		if open_timer.time_left == 0:
			$AnimationPlayer.play("open")
			visible = true
		open_timer.start()
		
		# This code Reads input if the right stick is within a certain angle
		
		if right_analog > -112 && right_analog < -67:
			current_input = right_inputs.up

		elif right_analog > -67 && right_analog < -22:
			current_input = right_inputs.up_right

		elif right_analog > -22 && right_analog < 22:
			current_input = right_inputs.right

		elif right_analog > 22 && right_analog < 67:
			current_input = right_inputs.down_right
			
		elif right_analog > 67 && right_analog < 112:
			current_input = right_inputs.down

		elif right_analog > 112 && right_analog < 157:
			current_input = right_inputs.down_left

		elif right_analog > 157 && right_analog < 180 or right_analog > -157 && right_analog < -180:
			current_input = right_inputs.left

		elif right_analog > -157 && right_analog < -112:
			current_input = right_inputs.up_left
	#If it doesn't get any inputs, then the input is set to none
	else:
		current_input = right_inputs.none
		
	
	#This checks if the script reads a new input and makes sure not to select a weapon you don't have
	if old_input != current_input and w_manager.weapons[current_input] != null and current_input != 0:
		
		w_manager.current_weapon_index = current_input
		w_manager.switch_weapons()
		Global.SoundBank.SND_UI_SELECTION.play()



func update_highlight():
	var old_highlight = current_higlight
	match w_manager.current_weapon_index:
		0:
			current_higlight = null
		1:
			$ui_weapon_wheel_part_id0.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id0
		2:
			$ui_weapon_wheel_part_id1.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id1
		3:
			$ui_weapon_wheel_part_id2.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id2
		4:
			$ui_weapon_wheel_part_id3.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id3
		5:
			$ui_weapon_wheel_part_id4.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id4
		6:
			$ui_weapon_wheel_part_id5.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id5
		7:
			$ui_weapon_wheel_part_id6.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id6
		8:
			$ui_weapon_wheel_part_id7.highlighted = true
			current_higlight = $ui_weapon_wheel_part_id7

	if old_highlight != current_higlight and old_highlight != null:
		old_highlight.highlighted = false

func _on_Open_timer_timeout():
	$AnimationPlayer.play("close")
	yield($AnimationPlayer,"animation_finished")
	if open_timer.time_left == 0:
		visible = false
