tool
extends Node2D

export(PackedScene) onready var Enemy setget set_enemy, get_enemy
export(int) onready var varient
var enemy_spawn : Enemy_Class

var spawn_count = 1

onready var spawn_container = $Spawn_container

func _ready():
	if !Engine.is_editor_hint():
		EventBus.connect("PlayerSpawned",self,"reset_spawn_count")
		
		
	update_editor()

func set_enemy(enemy : PackedScene):
	Enemy = enemy
	update_editor()
func get_enemy():
	return Enemy

func update_editor():
	if Engine.is_editor_hint():
		if Enemy != null:
			$AnimatedSprite.visible = true
			var editor_enemy : Enemy_Class = Enemy.instance()
			var sprite = editor_enemy.find_node("Sprite")
			var vis_notifier : VisibilityNotifier2D = editor_enemy.get_node("VisibilityNotifier2D")
			$AnimatedSprite.frames = sprite.frames
			
			$VisibilityNotifier2D.scale = vis_notifier.scale
			$VisibilityNotifier2D.position = vis_notifier.position
			if not ["default"].has(sprite.frames.get_animation_names()):
				$AnimatedSprite.animation = sprite.frames.get_animation_names()[0]
		else:
			$AnimatedSprite.visible = false
	else:
		$AnimatedSprite.visible = false

func reset_spawn_count():
	spawn_count = 1

func reduce_spawn_count():
	spawn_count -= 1

func _on_VisibilityNotifier2D_screen_entered():
	
	if spawn_container.get_child_count() == 0 and Enemy and not [Global.Player.state.SPAWNING, Global.Player.state.DYING].has(Global.Player.current_state) and spawn_count > 0:
		

		enemy_spawn = Enemy.instance()
		enemy_spawn.varient = varient
		spawn_container.call_deferred("add_child", enemy_spawn)
		
		enemy_spawn.connect("enemy_dying",self,"reduce_spawn_count")
	else:
		pass

