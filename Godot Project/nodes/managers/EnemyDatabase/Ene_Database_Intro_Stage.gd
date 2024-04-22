extends Node

onready var ENE_SPIKY = preload("res://nodes/entity/Enemies/Entity_Enemy_Spiky.tscn")

func _ready():
	Global.EnemyDataBase = self
