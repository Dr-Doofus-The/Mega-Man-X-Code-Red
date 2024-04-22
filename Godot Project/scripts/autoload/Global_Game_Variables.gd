extends Node

signal PlayerSpawned()
signal SpawnPlayer()
signal DeleteEntities()
signal Paused()

var Gravity = 980

var lives = 3

onready var Player : player_character
onready var Player_Character

onready var Characters_To_Spawn : Array = [0,2]
onready var Character_Slots : Array = [null,null]
onready var Current_Player = 0

onready var ViewPort : Viewport

onready var GameCamera : game_cam

onready var Level : level

onready var Current_Hud : game_hud

onready var PlayerHealthbar = null

onready var ResourceBank = null

onready var SoundBank = null

onready var time : float = 0.0


onready var reploid_list : Array


var canPause = true
var isPaused = false


onready var checkpoint

onready var bonus_platform = null


onready var level_stats : Dictionary = {
	"Path": "",
	"Timer": 0.0,
	"IsInBonus": false
}

var stage_timer : int = 60
var stage_timer_enabled = false

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	reploid_list = _get_dictionary_from_json("res://JSON/reploid_list.json")



func _freeze_frame(duration):
	get_tree().paused = true
	yield(get_tree().create_timer(duration),"timeout")
	if !isPaused:
		get_tree().paused = false

func get_active_player():
	var number = 0
	for n in Character_Slots:
		if !typeof(n) == TYPE_STRING and Global.Player == n:
			break
		else:
			number += 1

	return number

func _physics_process(_delta):
	if stage_timer_enabled and Global.Player and Engine.get_physics_frames()%60==0:
		stage_timer -= 1

func _process(delta):
	if !get_tree().paused:
		time += delta
		if Global.Player and Global.Player.HasControl:
			level_stats["Timer"] += delta

func restart_level():
	ViewPort.change_scene(Level.filename)

func reset_level_stats():
	level_stats["Path"] = ""
	level_stats["Timer"] = 0.0
	level_stats["IsInBonus"] = false

func teleport_player(teleport_position: Vector2, cam_bounds : Area2D):

	
	Global.canPause = false
	get_tree().paused = true
	if Transition.get_node("AnimationPlayer").current_animation == "Transition_out":
		yield(Transition.get_node("AnimationPlayer"),"animation_finished")

	
	Transition.get_node("AnimationPlayer").play("Transition_in")
	yield(Transition.get_node("AnimationPlayer"),"animation_finished")
	Global.Player.global_position = teleport_position
	cam_bounds._update_camera_limits(true)
	Global.GameCamera.global_position = Global.Player.global_position

	Transition.get_node("AnimationPlayer").play("Transition_out")
	Global.Player.isAttacking = false
	Global.Player.stop_movement()
	Global.canPause = true
	get_tree().paused = false

func set_values_to_null():
	Player = null
	Level = null
	PlayerHealthbar = null
	Character_Slots = [null,null]
	GameCamera = null

func _get_dictionary_from_json(path : String) -> Array:
	var f = File.new()
	assert(f.file_exists(path), "This file doesn't exist")
	
	f.open(path,File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)

	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
