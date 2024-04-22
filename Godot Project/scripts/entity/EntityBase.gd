extends KinematicBody2D

signal Damage_taken(i_frame,damage_dealer)

export(int) var hp_max: int = 100

onready var hp: int = hp_max setget set_hp, get_hp

export(bool) var gravityenabled: bool = true
export(bool) var UseDamageTable: bool = false
export(bool) var Die_On_0_HP: bool = true
export(bool) var infinite_inertia : bool = true
export(float) var invulnerable_time : float = 0
export (bool) var invulnerable = false

var damage_table


var velocity:Vector2 = Vector2.ZERO
var snap = true
var damage_resistance = 1
var latest_combo_value = -1


onready var ent_sprite : AnimatedSprite = $Sprite
onready var visanotifier : VisibilityNotifier2D = $VisibilityNotifier2D
onready var collshape = $CollisionShape2D
onready var animplayer : AnimationPlayer = $AnimationPlayer
onready var hurtbox : Area2D = $Hurtbox
onready var hurtbox_collision : CollisionShape2D = $Hurtbox/CollisionShape2D
onready var i_frame_timer : Timer = $I_frame_timer


func _init():
	visible = false
	hp = hp_max

func ready():
	i_frame_timer.wait_time = invulnerable_time


func set_hp(value : int):
	if value != hp:
		hp = int(clamp(value,0,hp_max))
		

func get_hp():
	return hp

func move():
	var snap_vector = Vector2(0,15) if snap else Vector2.ZERO

	velocity = (move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, true,4,0.785398,infinite_inertia))

func snap_to_ground(ray_length : float):
	var space_state = get_world_2d().direct_space_state
	var result_pos = space_state.intersect_ray(global_position, Vector2(global_position.x,global_position.y + ray_length),[self],collision_mask)

	if result_pos:
		global_position.y = result_pos.position.y - (collshape.shape.extents.y) + 1
	return result_pos

func _physics_process(delta):

	if gravityenabled == true:
		if is_on_floor():
			velocity.y = 0
		else:
			
			velocity.y += Global.Gravity * delta
#	round_position()

func _on_Hurtbox_area_entered(Hitbox : hitbox):
	

	var old_hp = self.hp
	if Hitbox and Hitbox.is_in_group("Hitbox"):
		if invulnerable and !Hitbox.ignore_iframes and (latest_combo_value >= Hitbox.combo_value):
		


			if self != Global.Player:
				Sound.play_sound(Sound.SND_HIT_SHIELD,0,1)
				Hitbox.emit_signal("damage_dealt", old_hp, old_hp, self)
			else:
				receive_damage(Hitbox.damage,Hitbox.activate_iframes,Hitbox)
				Hitbox.emit_signal("damage_dealt", old_hp, old_hp - Hitbox.damage, self)
			

		else:
			if UseDamageTable:
				if damage_table.has(Hitbox.hitbox_name):
					receive_damage(int(damage_table[Hitbox.hitbox_name]),Hitbox.activate_iframes,Hitbox)
					Hitbox.emit_signal("damage_dealt", old_hp, old_hp - int(damage_table[Hitbox.hitbox_name]), self)
			else:
				receive_damage(Hitbox.damage,Hitbox.activate_iframes,Hitbox)
				Hitbox.emit_signal("damage_dealt", old_hp, old_hp - Hitbox.damage, self)





func receive_damage(damage_value,i_frame,damage_dealer):
	
	
	
	if invulnerable and damage_dealer and not damage_dealer.ignore_iframes and (latest_combo_value >= damage_dealer.combo_value):
		pass
	else:
		self.hp -= int(max(1,damage_value/damage_resistance))
		if damage_dealer:
			latest_combo_value = damage_dealer.combo_value
		emit_signal("Damage_taken",i_frame,damage_dealer)
		if invulnerable_time > 0: 
			invulnerable = true
			i_frame_timer.stop()
			i_frame_timer.start()


func _on_EntityBase_tree_exiting():
	call_deferred("queue_free")

func turn_off_collision_box(mode : bool):
	collshape.set_deferred("disabled", mode)

func turn_off_hurtbox(mode : bool):
	hurtbox_collision.set_deferred("disabled", mode)

func _on_I_frame_timer_timeout():
	invulnerable = false
	latest_combo_value = -1
	refresh_hurtbox()

func refresh_hurtbox():
	turn_off_hurtbox(true)
	yield(get_tree(),"idle_frame")
	turn_off_hurtbox(false)


func _on_VisibilityNotifier2D_screen_entered():
	visible = true

func round_position():
	global_position = global_position.round()

func _on_VisibilityNotifier2D_screen_exited():
	visible = false
