extends Node

signal subtank_refil_done()

#All of These are set to false for testing purposes

#ID LIST
# 0 = GUNGAROO | 1 = CROWRANG | 2 = BOARSKI | 3 = WARFLY | 4 = TONION | 5 = STONEKONG | 6 = ANTEATOR |  7 = HYENARD

var Boss_Defeated_Array = [true, true, true, true, true, true, true, true]

#Subtanks

var Subtank_container : Array = []
var Weapontank_container : Array = []

#Armor X

enum Armor{NONE, BLADE, GLIDE, ULTIMATE}

onready var Head_Part = Armor.ULTIMATE
onready var Body_Part = Armor.ULTIMATE
onready var Arm_Part = Armor.ULTIMATE
onready var Leg_Part = Armor.ULTIMATE

#Zero

var current_zero_armor = 0 #0 = Normal | 1 = Black

#Chips

var current_chips : Array = [0,0,0,0]

#Heart Tanks
var heart_tank_array : Array = []

#Missing Reploid List
var Missing_Reploid_List : Dictionary = {
	"AirForce" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false], 
	"Tunnel" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false], 
	"Circuit" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false], 
	"Tower" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false], 
	"Battleship" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false], 
	"Forest" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false], 
	"Cyberfield" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false], 
	"Lava" : [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
}


#Cores

var cores_collected : Array = [0,0,0,0]
var current_cores : Array = [0,0,0,0]

#Difficulty 0 - Easy | 1 - Normal | 2 - Xtreme

var GameDificulty = 1


onready var health_sfx = preload("res://sound_assests/ui/hud/Health_Bar_Rise.wav")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


#SUBTANK STUFF


func add_subtank():
	var subtank = {
		"juice" : 0,
		"juice_limit" : 16
	}
	Subtank_container.append(subtank)



func drain_subtank(id):
	Sound.play_sound(Sound.SND_UI_UPDATE_HEALTH,4,1)
	while Subtank_container[id]["juice"] != 0 and Global.Player.hp != Global.Player.hp_max:
		Subtank_container[id]["juice"] -=1
		Global.Player.hp += 1
		#var rise_sfx = SFX.new()
		#rise_sfx.stream = health_sfx
		#add_child(rise_sfx)
		Global.Current_Hud.pause_menu.update_health()
		EventBus.emit_signal("PlayerHealthUpdated",false)
		yield(get_tree().create_timer(0.05),"timeout")
	Sound.SND_UI_UPDATE_HEALTH.stop()
	emit_signal("subtank_refil_done")
	#EventBus.emit_signal("PlayerHealthUpdated",false)
