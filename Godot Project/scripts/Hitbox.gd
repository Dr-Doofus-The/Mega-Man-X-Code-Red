extends Area2D
class_name hitbox


signal damage_dealt(old_hp, new_hp, target)

export(int) var damage : int = 1
export(bool) var ignore_iframes : bool = false
export(bool) var activate_iframes : bool = true
export(String) var hitbox_name
export (int) var linger_frames : float = 0
export (int) var combo_value : int = 0
export(float) var knockback_power : float = 1.0

var current_linger_frames = 0

var temporary = false
var time : float
var size : Vector2

func _ready():
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	if temporary:

		var tw = create_tween()
		var collshape = CollisionShape2D.new()
		collshape.shape = RectangleShape2D.new()
		collshape.shape.extents = size
		call_deferred("add_child",collshape)
		add_to_group("Hitbox")

		tw.tween_interval(time)
		tw.tween_callback(self,"delete")

func delete():
	queue_free()

func _physics_process(_delta):
	if current_linger_frames > 0:
		current_linger_frames -= 1
		if current_linger_frames == 0:
			$CollisionShape2D.set_deferred("disabled", false)

func _on_Hitbox_damage_dealt(_old_hp, _new_hp, _target):

	if linger_frames > 0:
		current_linger_frames = linger_frames
		$CollisionShape2D.set_deferred("disabled", true)


