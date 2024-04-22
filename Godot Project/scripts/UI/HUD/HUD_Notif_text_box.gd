extends Control

onready var text : String
onready var text_2 : String

onready var text_box = $Label
onready var text_box_2 = $Label2
onready var box = $TextureRect
onready var time = 2.5

var subtank = false
var subtank_id = 0

var y_pos = 0

func _ready():
	EventBus.connect("PlayerHealthUpdated",self,"update_health")
	rect_position.x = -200
	if !subtank:
		$subtank_set.queue_free()
		if text_2 != "":
			text_box.rect_position.y = -8
			text_box_2.rect_position.y = 1
			box.rect_min_size.y = 22
			box.rect_position.y = -6
			y_pos = 22
		else:
			y_pos = 18
		text_box.text = text
		text_box_2.text = text_2
	else:
		y_pos = 22
		box.rect_min_size.x = 118
		box.rect_min_size.y = 21
		box.rect_position.y = -6
		time = 1.7
		$subtank_set/TextureProgress.value = GameProgress.Subtank_container[subtank_id]["juice"]
	$Timer.wait_time = time
	$Timer.start()
	yield(get_tree(),"physics_frame")
	yield(get_tree(),"physics_frame")
	var tw = create_tween()
	if !subtank:
		var size_target = text_box if text_box.rect_size.x > text_box_2.rect_size.x else text_box_2

		if int(text_box.rect_size.x) % 2 == 0:
			box.rect_min_size.x = size_target.rect_size.x + 6
		else:
			box.rect_min_size.x = size_target.rect_size.x + 7
	rect_position.x = (Global.ViewPort.size.x) - (box.rect_min_size.x/2) - 10
	rect_position.y = y_pos - 30

	tw.tween_property(self,"rect_position:y",float(y_pos),0.1)

func move_down(size):

	var tw = create_tween()
	tw.tween_property(self,"rect_position:y",(rect_position.y + size + 6),0.1)

func update_health(_a):
	if subtank:
		$subtank_set/TextureProgress.value = GameProgress.Subtank_container[subtank_id]["juice"]

func _on_Timer_timeout():
	var tw = create_tween()
	tw.tween_property(self,"rect_position:x",(Global.ViewPort.size.x) + (box.rect_min_size.x/2) + 10,0.2)
	yield(tw,"finished")
	queue_free()
