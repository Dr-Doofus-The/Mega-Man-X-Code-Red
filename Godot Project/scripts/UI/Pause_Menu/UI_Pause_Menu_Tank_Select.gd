extends TextureButton

var desc = (
"The sub-tank stores life-energy if you already have max health, which you can resotre by using the subtank"
)
var focused = false

func _ready():
	connect("focus_entered",self,"focus_enter")
	connect("focus_exited",self,"focus_exit")

func _physics_process(_delta):
	if focused and (Engine.get_physics_frames()) %20 == 0:
		if self_modulate == Color.white:
			self_modulate = Color.white*1.2
		else:
			self_modulate = Color.white

func focus_enter():
	#self_modulate = Color.white*1.2
	Global.Current_Hud.pause_menu.selection_changed(self)
	focused = true

func focus_exit():
	self_modulate = Color.white
	Global.Current_Hud.pause_menu.selection_changed(self)
	focused = false

func update_values():
	$TextureProgress.value = GameProgress.Subtank_container[get_index()]["juice"]
