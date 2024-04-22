extends Control

export (String) var desc
var focused = false
export var use_self_modulate = true
var tab

func _ready():
	connect("focus_entered",self,"focus_enter")
	connect("focus_exited",self,"focus_exit")
	

func _physics_process(_delta):
	if focused and (Engine.get_physics_frames()) %30 == 0:
		
		if use_self_modulate:
			if self_modulate.a >= 1:

				self_modulate.a = 0.0
			else:
				self_modulate.a = 1
		else:
			if modulate == Color(1.2,1.2,1.2):

				modulate = Color(1.5,1.5,1.5)
			else:
				modulate = Color(1.2,1.2,1.2)

func focus_enter():
	if use_self_modulate:
		self_modulate.a = 1.0
	else:
		modulate = Color(1.5,1.5,1.5)
	if tab:
		$Label.modulate = Color.white
	Global.Current_Hud.pause_menu.selection_changed(self)
	focused = true

func focus_exit():
	if use_self_modulate:
		self_modulate.a = 0
	else:
		modulate = Color.white
	if tab:
		$Label.modulate = Color("e7a868")
	#Global.Current_Hud.pause_menu.selection_changed(self)
	focused = false
