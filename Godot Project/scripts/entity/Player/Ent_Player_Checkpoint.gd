extends Area2D

export (bool) var start_point : bool = false

export (NodePath) var Camera_Bounds_Path
export (String) var Area_Name : String

export (bool) var invisible : bool = false

onready var off_palette = preload("res://sprites/GameObjects/Universal/spr_gobj_checkpoint_palette_off.png")
onready var x_palette = preload("res://sprites/GameObjects/Universal/spr_gobj_checkpoint_palette_x.png")
onready var zero_palette = preload("res://sprites/GameObjects/Universal/spr_gobj_checkpoint_palette_zero.png")
onready var vile_palette = preload("res://sprites/GameObjects/Universal/spr_gobj_checkpoint_palette_vile.png")



onready var sprite = $StaticBody2D/AnimatedSprite

var activated 


func _ready():
	var _con0 = EventBus.connect("PlayerSpawned",self,"set_camera_limits")
	var _con1 = EventBus.connect("CheckPointActivated",self,"check_for_deactivate")
	if start_point:
		Global.checkpoint = self

	else:
		activated = false
		sprite.play("off")
	yield(EventBus,"PlayerInitialized")
	switch_color_palette()
	if invisible:
		visible = false
		$StaticBody2D/CollisionShape2D.set_deferred("disabled",true)

func _on_Ent_player_checkpoint_body_entered(body):
	if body == Global.Player:

		if not activated:
			activate()
		if Global.checkpoint != self:
			sprite.play("activate")
			Global.checkpoint = self
		EventBus.emit_signal("CheckPointActivated")

func activate():
	activated = true
	switch_color_palette()
	sprite.play("activate")



func check_for_deactivate():
	if self != Global.checkpoint and sprite.animation == "idle":
		sprite.play("deactivate")

func set_camera_limits():
	if self == Global.checkpoint:
		if activated:
			$AnimationPlayer.play("Transmit_receiving")
		var Camera_Bounds = get_node_or_null(Camera_Bounds_Path)
		if Camera_Bounds == null:
			push_error("Checkpoint has no associated camera bounds")
			get_tree().quit()
		else:
			Camera_Bounds._update_camera_limits(true)
			
			Global.GameCamera.global_position = Global.Player.global_position

func beam_blink():

	while $AnimationPlayer.is_playing():
		$ColorRect.self_modulate = Color(1.9,1.9,1.9) if $ColorRect.self_modulate == Color(1,1,1) else Color(1,1,1)
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")
	
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")

func switch_color_palette():
	var mat = $StaticBody2D/AnimatedSprite.get_material()
	
	if not activated:
		mat.set_shader_param("palette",off_palette)



func _on_AnimatedSprite_animation_finished():
	match sprite.animation:
		"activate":
			sprite.play("idle")
		"deactivate":
			sprite.play("off")
