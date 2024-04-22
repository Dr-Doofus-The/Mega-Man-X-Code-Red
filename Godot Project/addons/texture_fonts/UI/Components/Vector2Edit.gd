tool
extends VBoxContainer

signal value_changed(value)

onready var label_node := $Heading/Label
onready var x_node := $Values/X
onready var y_node := $Values/Y


export(Vector2) var min_value: Vector2 = Vector2(-100.0, -100.0) setget set_min_value, get_min_value
var _min_value := Vector2(-100.0, -100.0)
func set_min_value(new_value: Vector2):
	_min_value = new_value
	if is_instance_valid(x_node) and is_instance_valid(y_node):
		x_node.min_value = new_value.x
		y_node.min_value = new_value.y
func get_min_value():
	if is_instance_valid(x_node) and is_instance_valid(y_node):
		return Vector2(x_node.min_value, y_node.min_value)

export(Vector2) var max_value: Vector2 = Vector2.ZERO setget set_max_value, get_max_value
var _max_value := Vector2(100.0, 100.0)
func set_max_value(new_value: Vector2):
	_max_value = new_value
	if is_instance_valid(x_node) and is_instance_valid(y_node):
		x_node.max_value = new_value.x
		y_node.max_value = new_value.y
func get_max_value():
	if is_instance_valid(x_node) and is_instance_valid(y_node):
		return Vector2(x_node.max_value, y_node.max_value)


export(Vector2) var value: Vector2 setget set_value, get_value
var _value := Vector2.ZERO
func set_value(new_value: Vector2):
	_value = new_value
	if is_instance_valid(x_node) and is_instance_valid(y_node):
		x_node.value = new_value.x
		y_node.value = new_value.y
func get_value():
	if is_instance_valid(x_node) and is_instance_valid(y_node):
		return Vector2(x_node.value, y_node.value)


export(String) var label := "Label" setget set_label, get_label
var _label := "Label"
func set_label(new_label: String):
	_label = new_label
	if is_instance_valid(label_node):
		label_node.text = new_label
func get_label():
	if is_instance_valid(label_node):
		return label_node.text


func _ready():
	set_label(_label)
	set_value(_value)
	set_min_value(_min_value)
	set_max_value(_max_value)


func _on_X_value_changed(new_value):
	value.x = new_value
	emit_signal("value_changed", value)

func _on_Y_value_changed(new_value):
	value.y = new_value
	emit_signal("value_changed", value)
