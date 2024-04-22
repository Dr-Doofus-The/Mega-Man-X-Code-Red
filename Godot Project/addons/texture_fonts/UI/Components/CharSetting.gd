tool
extends VBoxContainer

signal change
signal delete

var font_settings
var for_char: String

onready var char_edit := $Heading/Char
onready var advance := $MarginContainer/HBoxContainer/VBoxContainer/SpinBox
onready var offset := $MarginContainer/HBoxContainer/Vector2Edit

func _ready():
	if for_char:
		char_edit.text = for_char
		advance.value = font_settings.get_advance(for_char)
		offset.value = font_settings.get_offset(for_char)


func _on_DeleteButton_pressed():
	emit_signal("delete", self)


func _on_Char_text_changed(to_char: String):
	# if char is emptied
	if to_char.length() == 0:
		if for_char:
			font_settings.remove_setting(for_char)
			emit_signal("change")
		return
	
	# char allready exists, ignore
	if to_char in font_settings.char_settings:
		return
	
	
	# if char was set before, delete old entry
	if for_char:
		font_settings.remove_setting(for_char)
	
	# add new char setting
	font_settings.add_setting(to_char)
	font_settings.set_setting(to_char, advance.value, offset.value)
	
	
	for_char = to_char
	
	emit_signal("change")


func _on_SpinBox_value_changed(value):
	if for_char:
		font_settings.set_advance(for_char, value)
		emit_signal("change")


func _on_Vector2Edit_value_changed(value):
	if for_char:
		font_settings.set_offset(for_char, value)
		emit_signal("change")
