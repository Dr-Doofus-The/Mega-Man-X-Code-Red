extends Sprite

var highlighted : bool = false

onready var weapon_id : int = 0
#0-Disabled 1 = S.Ice 2 = Storm T. 3 = Rolling Shield 4 =Boomerang cutter
#5 = Electric Spark #6 torpedo #7 = Sting  8=fire wave

func update_id():
	match weapon_id:
		1:
			if GameProgress.Boss_Defeated_Array[0]:
				frame = 8
			else:
				weapon_id = 0
		2:
			if GameProgress.Boss_Defeated_Array[1]:
				frame = 5
			else:
				weapon_id = 0
		3:
			if GameProgress.Boss_Defeated_Array[2]:
				frame = 2
			else:
				weapon_id = 0
		4:
			if GameProgress.Boss_Defeated_Array[3]:
				frame = 7
			else:
				weapon_id = 0
		5:
			if GameProgress.Boss_Defeated_Array[4]:
				frame = 6
			else:
				weapon_id = 0
		6:
			if GameProgress.Boss_Defeated_Array[5]:
				frame = 9
			else:
				weapon_id = 0
		7:
			if GameProgress.Boss_Defeated_Array[6]:
				frame = 4
			else:
				weapon_id = 0
		8:
			if GameProgress.Boss_Defeated_Array[7]:
				frame = 3
			else:
				weapon_id = 0
				
	if weapon_id == 0:
		$ui_weapon_wheel_part_backdrop.visible = false
		frame = 1

func _process(_delta):
	if highlighted:
		scale = lerp(scale, Vector2(1,1), 0.5)
	else:
		scale = lerp(scale, Vector2(0.5,0.5), 0.5)
