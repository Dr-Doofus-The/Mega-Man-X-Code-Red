extends Node

onready var small_energy_pickup = preload("res://nodes/entity/Items/Item_Health_Small.tscn")
onready var med_energy_pickup = preload("res://nodes/entity/Items/Item_Health_Med.tscn")

#Particles
onready var FX_Explosion_Standard = preload("res://nodes/particles/other/Par_Explosion_Standard.tscn")


func _ready():
	Global.ResourceBank = self
