extends Area2D

var stage_type : int
export (int) var reploid_id : int
var reploid_color setget set_reploid_color, get_reploid_color
var reploid_name : String


onready var sprite : AnimatedSprite = $AnimatedSprite
onready var sign_sprite : AnimatedSprite = $AnimatedSprite2


var state = 0
var stage : String = Global.reploid_list[reploid_id]["Stage"]

func _ready():


	if GameProgress.Missing_Reploid_List[stage][reploid_id%16] == true:
		queue_free()
	
	
	reploid_name = Global.reploid_list[reploid_id]["ReploidName"]
	if !reploid_name:
		push_error("Reploid has no name")
		breakpoint
	visible = false
	sprite.play(stage + "_help")
	sign_sprite.play("help")
	

	match Global.reploid_list[reploid_id]["Color"]:
		"BLUE":
			reploid_color = 0
		"RED":
			reploid_color = 1
		"YELLOW":
			reploid_color = 2
		"GREEN":
			reploid_color = 3
	set_reploid_color(reploid_color)



func set_reploid_color(value):
	reploid_color = value
	if sprite:
		var sprite_mat = sprite.get_material()
		match reploid_color:
			0:
				sprite_mat.set_shader_param("frame_coordinate",Vector2(0.001,0))
				self_modulate = Color("3470ff")
			1:
				sprite_mat.set_shader_param("frame_coordinate",Vector2(0.28,0))
				self_modulate = Color("d93030")
			2:
				sprite_mat.set_shader_param("frame_coordinate",Vector2(0.52,0))
				self_modulate = Color("f4ff34")
			3:
				sprite_mat.set_shader_param("frame_coordinate",Vector2(0.79,0))
				self_modulate = Color("3aff34")


func get_reploid_color():
	return reploid_color

func _physics_process(delta):
	if !Engine.is_editor_hint():

		match state:
			0:
				sprite.flip_h = true if Global.Player.global_position.x < global_position.x else false
			2:
				if sprite.frame == 3:
					position.y -= 6
					
					if Engine.get_physics_frames()%2 == 0:
						var par : ParticleSprite = Assets.PAR_TELEPORT_TRAIL.instance()
						par.pause_mode = Node.PAUSE_MODE_PROCESS
						par.gravity = 10

						par.global_position = Vector2(sprite.global_position.x  + rand_range(-2,2),sprite.global_position.y)
						par.modulate = self_modulate * 2.4
						Global.ViewPort.add_child(par)
				
					
				if !$VisibilityNotifier2D.is_on_screen():

					queue_free()

func _on_Item_Missing_Reploid_body_entered(body):
	if state == 0:
		if GameProgress.Missing_Reploid_List[stage][reploid_id%16] == true:
			
			push_error("Reploid ID already exists")
			breakpoint

		else:

			GameProgress.Missing_Reploid_List[stage][reploid_id%16] = true
			GameProgress.cores_collected[reploid_color] += 1
			GameProgress.current_cores[reploid_color] += 1
			
			print("You Now Have: \n" + str(GameProgress.current_cores[0]) + " Blue Cores\n" + str(GameProgress.current_cores[1]) + " Red Cores\n" + str(GameProgress.current_cores[2]) + " Yellow Cores\n" + str(GameProgress.current_cores[3]) + " Green Cores")
			

			
		
		Sound.play_sound(Sound.SND_NOTIF_01,-1,1)
		sprite.play(stage + "_thanks")
		sign_sprite.play("thanks")
		state = 1
		modulate = Color.white * 3
		yield(get_tree().create_timer(0.04,false),"timeout")
		modulate = Color.white
		yield(get_tree().create_timer(1.0,false),"timeout")
		sign_sprite.visible = false
		sprite.play("teleport")
		Sound.play_sound(Sound.SND_PL_TELEPORT_OUT,0,1)
		state = 2


func _on_VisibilityNotifier2D_screen_entered():
	visible = true


func _on_VisibilityNotifier2D_screen_exited():
	visible = false
