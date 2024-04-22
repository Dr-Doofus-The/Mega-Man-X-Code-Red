extends Light2D

onready var spot_light_texture = preload("res://sprites/Particles/light/spr_light_spot_light.png")
onready var radius_light_texture = preload("res://sprites/Particles/light/spr_light_circle.png")

export (int, "Radius", "Spot") var light_mode




func _ready():
	var _con = EventBus.connect("UpdateLight",self,"update_light")
	$Outer_Light.texture_scale =texture_scale + 0.15

	match light_mode:
		0:
			texture = radius_light_texture
			$Outer_Light.texture = radius_light_texture
		1:
			texture = spot_light_texture
			$Outer_Light.texture = spot_light_texture	

	if Global.Level.Current_light_level:
		pass
	else:
		yield(get_tree(),"idle_frame")
	color.a = clamp(0.8 - Global.Level.Current_light_level, 0, 1)
	$Outer_Light.color.a = clamp(0.5 - Global.Level.Current_light_level,0,1)


func update_light(light):
	
	if light == 1:
		$Tween.interpolate_property($Outer_Light,"color:a",$Outer_Light.color.a, 0,0.5)
		$Tween.interpolate_property(self,"color:a",color.a, 0,0.5)
		$Tween.start()
	else:
		
	
		$Tween.interpolate_property($Outer_Light,"color:a",$Outer_Light.color.a,clamp(0.8 - light,0,1),0.5)
		$Tween.interpolate_property(self,"color:a",color.a,1,0.5)
		$Tween.start()
