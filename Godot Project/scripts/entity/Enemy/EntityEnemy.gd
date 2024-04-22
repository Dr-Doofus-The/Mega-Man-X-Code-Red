extends "res://scripts/entity/EntityBase.gd"
class_name Enemy_Class


signal stop_behavior()
signal enemy_dying()

onready var flash_player = $Flash_AnimationPlayer
onready var puff_fx = preload("res://nodes/particles/other/Par_smoke_puff_small.tscn")

onready var small_weapon_refill = preload("res://nodes/entity/Items/Item_ammo_Small.tscn")
onready var med_weapon_refill = preload("res://nodes/entity/Items/Item_ammo_Med.tscn")
onready var small_energy_refill = preload("res://nodes/entity/Items/Item_Health_Small.tscn")
onready var med_energy_refill = preload("res://nodes/entity/Items/Item_Health_Med.tscn")


export (int) var Movement_Speed : int = 0
export (bool) var Flip_Sprite_To_Match_Direction : bool = false
export (bool) var DropItem : bool = true
export (bool) var smoke_on_low_health : bool = false
export (PackedScene) var piece_explosion
export (Rect2) var sprite_size : Rect2
export (bool) var long_death : bool = false

export (int) var Dna_id_1 : int
export (int) var Dna_id_2 : int

var varient = 0
onready var enemy_direction = 1
onready var healthbar = $Sprite/HealthBar
onready var centerpoint = $Sprite/CenterPoint
export (float) var enemy_reaction_time : float = 1.0

var rng = RandomNumberGenerator.new()
var dying = false

var lifetime = 0.0

func _ready():
	$reaction_time.wait_time = enemy_reaction_time
	$reaction_time.start()
	update_dir()
	
	flash_player.play("No_Flash")
	if GameProgress.current_chips[0] == 1:
		healthbar.visible = true
		healthbar.rect_position.y -= sprite_size.size.y
		healthbar.max_value = hp_max
		healthbar.value = hp
	var _con = Global.connect("PlayerSpawned",self,"_on_player_death")

func _physics_process(delta):
	lifetime += delta
	if enemy_reaction_time > 0:
		enemy_reaction_time -= delta
	if Flip_Sprite_To_Match_Direction:
		ent_sprite.scale.x = enemy_direction * -1
	if smoke_on_low_health and hp < int(hp_max/3.0) and Engine.get_physics_frames() % 6 == 0 and not dying:
		if not $Flash_AnimationPlayer.is_playing():
			$Flash_AnimationPlayer.play("Damage_Flash_light")
		var smoke_fx = puff_fx.instance()
		smoke_fx.global_position = global_position + Vector2(rand_range(-sprite_size.size.x/2,sprite_size.size.x/2),rand_range(-20,20))
		Global.ViewPort.get_child(0).add_child(smoke_fx)
	move()

func update_dir():
	if global_position.x < Global.Player.global_position.x:
		enemy_direction = 1
	else:
		enemy_direction = -1

func enemy_die(copy_drop : bool = false):
	flash_player.stop()
	drop_item(copy_drop)
	dying = true
	emit_signal("enemy_dying")
	if long_death:
		#turn_off_collision_box(true)
		
		hurtbox.set_deferred("monitoring", false)
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		emit_signal("stop_behavior")
		animplayer.stop()
		var yield_timer = Timer.new()
		yield_timer.pause_mode =Node.PAUSE_MODE_STOP
		add_child(yield_timer)

		
		for n in 10:
			if $Flash_AnimationPlayer.current_animation != "Dying":
				$Flash_AnimationPlayer.play("Dying")
			spawn_explosion(true)
			yield_timer.start(0.13); yield(yield_timer,"timeout")
		Global.GameCamera.camera_shake(1,2,0.15)
	else:
		spawn_explosion(false)
	

	if piece_explosion != null:
		var p_explosion = piece_explosion.instance()
		p_explosion.position = self.global_position	
		Global.ViewPort.call_deferred("add_child",p_explosion)

	call_deferred("queue_free")

func spawn_explosion(random : bool):
	var explosion_effect = Assets.PAR_EXPLOSION_STANDARD.instance()
	if random:
		explosion_effect.position = self.global_position + Vector2(rand_range(-sprite_size.size.x/2,sprite_size.size.x/2),rand_range(-sprite_size.size.y/2,sprite_size.size.y/2))
	else:
		explosion_effect.position = self.global_position	
	Global.ViewPort.call_deferred("add_child",explosion_effect)	
	Sound.play_standard_explosion_sound()
func drop_item(copy_drop):
	if copy_drop:
		var item = Assets.ITEM_DNA_BOOST.instance()
		item.global_position = self.global_position.round()
		item.velocity.y = -200
		item.ItemID = Dna_id_1
		item.ItemID2 = Dna_id_2
		Global.ViewPort.call_deferred("add_child",item)
		return

	if DropItem:

		rng.randomize()
		var dropchance = int(rand_range(0,100))

		if dropchance <= 50:
			pass
			# Drop Nothing
		elif dropchance > 50 and dropchance <= 62:
			var item = small_weapon_refill.instance()
			item.global_position = self.global_position.round()
			item.velocity.y = -200
			Global.ViewPort.call_deferred("add_child",item)
		elif dropchance > 62 and dropchance <= 74:
			var small_e_refill = small_energy_refill.instance()	
			small_e_refill.global_position = self.global_position.round()
			small_e_refill.velocity.y = -200
			Global.ViewPort.call_deferred("add_child",small_e_refill)
		elif dropchance > 74 and dropchance <= 86:
			var item = med_weapon_refill.instance()	
			item.position = self.global_position.round()
			item.velocity.y = -200
			Global.ViewPort.call_deferred("add_child",item)
		elif dropchance > 86 and dropchance <= 98:
			var med_e_refill = med_energy_refill.instance()	
			med_e_refill.position = self.global_position.round()
			med_e_refill.velocity.y = -200
			Global.ViewPort.call_deferred("add_child",med_e_refill)
		elif dropchance > 98:
			pass
			# 1 UP

func _on_EntityEnemy_Damage_taken(_i_frame,damage_dealer):
	if hp <= 0:
		if Die_On_0_HP:
			if damage_dealer and damage_dealer.hitbox_name == "COPY_SHOT":
				enemy_die(true)
			else:
				
				enemy_die(false)
	healthbar.value = hp
	
	flash_player.play("Damage_Flash")
func _on_player_death():
	#emit_signal("enemy_dying")
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	#emit_signal("enemy_dying")
	queue_free()



func _on_EntityEnemy_stop_behavior():
	ent_sprite.playing = false
