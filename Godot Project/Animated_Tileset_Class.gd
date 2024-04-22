extends TileMap
class_name AnimatedTileMap

var _timer = Timer.new()

export (float) var delay = 1.0
export (int) var frames
export (int) var size
export (int) var height
var x_region = 0

func _ready():
	connect("settings_changed",self,"on_script_change")
	pause_mode =Node.PAUSE_MODE_STOP
	add_child(_timer)
	_timer.connect("timeout",self,"_on_timer_timeout")
	_timer.wait_time = delay
	_timer.one_shot = false
	_timer.pause_mode =Node.PAUSE_MODE_STOP
	_timer.start()

func _on_timer_timeout():
	x_region += size
	x_region %= size * frames
	
	for n in tile_set.get_tiles_ids():
		tile_set.tile_set_region(n,Rect2(x_region,height,size/2,height))

func on_script_change():
	_timer.wait_time = delay
