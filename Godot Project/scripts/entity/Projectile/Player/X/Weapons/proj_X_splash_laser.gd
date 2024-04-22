extends KinematicBody2D


var splashindex = 0
var lead : Node = null
var lead_data := []
var follow = false
var follow_data := []

var BulletDire : int
var velocity := Vector2.ZERO
var frame = 0
var bounce_count = 3

func _ready():
	if splashindex == 0:
		velocity.y = 30
		for n in 2:
			var follower = self.duplicate()
			follower.lead = self
			follower.follow = true
			follower.splashindex = n + 1
			follower.set_collision_mask_bit(0,false)
			get_parent().add_child(follower)

func _physics_process(delta):
	
	if follow:
		if is_instance_valid(lead):
			follow_data = lead.lead_data.duplicate()
		
		
		if follow_data.size() <= splashindex * 2:
			visible = false
			return

		if (frame - splashindex * 2) > follow_data.size() - 2:
			queue_free()
			return

		#frame += 1
		visible = true
		global_position = follow_data[frame - splashindex * 2]["pos"]
		rotation = follow_data[frame - splashindex * 2]["rot"]
		frame += 1
		return
	
	
	
	if is_on_floor():
		velocity.y *= -1
		bounce_count -= 1
	if is_on_wall():
		BulletDire *= -1
		#bounce_count -= 1
	if bounce_count <= 0:
		queue_free()

	velocity.x = BulletDire * 370
	velocity.y += Global.Gravity * delta
	
	rotation = velocity.angle()

	
	var _con = move_and_slide(velocity,Vector2.UP)
	
	var dict = {
		"pos" : global_position,
		"rot" : rotation
	}
	lead_data.append(dict)

