extends Node
class_name level

export (String,
"AirForce",
"Lava",
"Tunnel",
"Tower",
"Battleship",
"Forest",
"Circuit",
"Cyberfield"
) var level_name

onready var checkpoints : Array = get_node("CheckPoints").get_children()
onready var Parallax = $ParallaxBackground
var parallax_canvas_modulate = CanvasModulate.new()
onready var Light_canvas = $Light_Level
onready var Current_light_level = 1
onready var Player_Container =  $Player_holder


func _init():
	
	
	Global.Level = self
	Global.reset_level_stats()

	
func _ready():
	Global.level_stats["Path"] = filename
	var _con = EventBus.connect("UpdateLight",self,"Update_light")
	var hostage_count = 0
	if level_name:
		for n in GameProgress.Missing_Reploid_List[level_name]:
			if n != null:
				hostage_count += 1
		print ("You have rescued " + str(hostage_count) + " reploids in this stage")

	var index_position = -1


	for n in Global.Characters_To_Spawn:
		var player
		index_position += 1
		match n:
			0:
				player = Assets.PLAYER_X.instance()
				Player_Container.add_child(player)
				
			1:
				player = Assets.PLAYER_ZERO.instance()
				Player_Container.add_child(player)
				
			2:
				player = Assets.PLAYER_AXL.instance()
				Player_Container.add_child(player)

		Global.Character_Slots.remove(index_position)
		Global.Character_Slots.insert(index_position,player)
	

	Global.Character_Slots[0].spawn(false)
	Global.Character_Slots[1].visible = false
	if not Settings.skip_ready:
		Global.Current_Hud.on_player_spawn()

		
	Parallax.add_child(parallax_canvas_modulate)
	Light_canvas.color = Color(Current_light_level,Current_light_level,Current_light_level)
	parallax_canvas_modulate.color = Color(Current_light_level,Current_light_level,Current_light_level)




func Update_light(light_level):
	Light_canvas.get_node("Tween").interpolate_property(Light_canvas, "color", Light_canvas.color, Color(light_level,light_level,light_level),0.5)
	Light_canvas.get_node("Tween").interpolate_property(parallax_canvas_modulate, "color", Light_canvas.color, Color(light_level,light_level,light_level),0.5)
	Light_canvas.get_node("Tween").start()
	Current_light_level = light_level
