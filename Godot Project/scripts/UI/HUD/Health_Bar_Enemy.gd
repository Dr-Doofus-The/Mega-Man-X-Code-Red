extends Control

var enemy


signal raise_finished()

func _ready():
	var _con = EventBus.connect("PlayerSpawned",self,"delete_this")
	var _con2 = enemy.connect("Damage_taken",self,"update_hp")
	var _con3 = enemy.connect("tree_exiting",self,"delete_this")
	$Health_Bar_Frame/Health_Bar_Progress.max_value = enemy.hp_max
	$Health_Bar_Frame/Health_Bar_Progress_red.max_value = enemy.hp_max
	
	$Health_Bar_Frame/Health_Bar_Progress.value = 0
	$Health_Bar_Frame/Health_Bar_Progress_red.value = 0

func raise_hp():
	update_life(true)

func update_hp(_1,_2):
	update_life(false)

func update_life(slow : bool):
	$Health_Bar_Frame/Health_Bar_Progress.max_value = enemy.hp_max
	$Health_Bar_Frame/Health_Bar_Progress_red.max_value = enemy.hp_max
	if slow:
		var plus_value = clamp(enemy.hp_max / 32,1,100)
		Sound.play_sound(Sound.SND_UI_UPDATE_HEALTH,3,1)
		Sound.SND_UI_UPDATE_HEALTH.play()
		while $Health_Bar_Frame/Health_Bar_Progress.value != enemy.hp:
			$Health_Bar_Frame/Health_Bar_Progress.value += plus_value
			$Timer.start(0.03) ; yield($Timer,"timeout")
		emit_signal("raise_finished")
		Sound.SND_UI_UPDATE_HEALTH.stop()
		$Health_Bar_Frame/Health_Bar_Progress_red.value = enemy.hp
	
	$Health_Bar_Frame/Health_Bar_Progress.value = enemy.hp
	
	if $Health_Bar_Frame/Health_Bar_Progress_red.value < enemy.hp:
		$Health_Bar_Frame/Health_Bar_Progress_red.value = enemy.hp
	else:
		$Red_start_timer.start()
	
func delete_this():
	queue_free()

func _on_Red_start_timer_timeout():
	while $Health_Bar_Frame/Health_Bar_Progress_red.value > enemy.hp:
		
		$Health_Bar_Frame/Health_Bar_Progress_red.value -= 0.5
		$red_decrement_timer.start(); yield($red_decrement_timer,"timeout")
