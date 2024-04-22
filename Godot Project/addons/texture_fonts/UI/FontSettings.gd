tool
extends HSplitContainer

signal change

onready var char_setting_list := $HSplitContainer/ListSettings/VSplitContainer/CharSettings/MarginContainer/ScrollContainer/SettingList
onready var kerning_pair_list := $HSplitContainer/ListSettings/VSplitContainer/Kerning/MarginContainer/ScrollContainer/KerningList

onready var height := $HSplitContainer/Settings/MarginContainer/Grid/Height
onready var gap := $HSplitContainer/Settings/MarginContainer/Grid/Gap
onready var horizontal_align := $HSplitContainer/Settings/MarginContainer/Grid/HorizontalAlign
onready var vertical_align := $HSplitContainer/Settings/MarginContainer/Grid/VerticalAlign
onready var ascent := $HSplitContainer/Settings/MarginContainer/Grid/Ascent
onready var monospace := $HSplitContainer/Settings/MarginContainer/Grid/MonoSpaced

onready var preview := $Preview
onready var preview_textbox := $Preview/MarginContainer/TextEdit

const char_setting_scene := preload("./Components/CharSetting.tscn")
const kerning_pair_scene := preload("./Components/KerningPair.tscn")

var font_settings
var font_ref: WeakRef


func set_font(new_font):
	font_ref = weakref(new_font)
	
	height.value = new_font.height
	ascent.value = new_font.ascent
	
	# clear char settings list
	for child in char_setting_list.get_children():
		char_setting_list.remove_child(child)
		child.queue_free()
	
	for child in kerning_pair_list.get_children():
		kerning_pair_list.remove_child(child)
		child.queue_free()
	
	font_settings = new_font.font_settings
	
	# populate char settings list
	for for_char in font_settings.char_settings:
		_add_char_setting(null, for_char)
	
	for kerning_pair in font_settings.kerning_pairs:
		_add_kerning_pair(null, kerning_pair)
	
	gap.value = font_settings.gap
	horizontal_align.value = font_settings.horizontal_align
	vertical_align.value = font_settings.vertical_align
	monospace.pressed = font_settings.monospace
	
	preview.set_preview_text(font_settings.preview_chars)
	preview.set_preview_color(font_settings.preview_color)


func _add_char_setting(char_setting_node = null, for_char = null):
	if char_setting_node == null:
		char_setting_node = char_setting_scene.instance()
	
	if for_char:
		char_setting_node.for_char = for_char
	
	char_setting_node.font_settings = font_settings
	
	char_setting_list.add_child(char_setting_node)
	char_setting_node.owner = self.owner
	char_setting_node.connect("change", self, "_value_changed")
	char_setting_node.connect("delete", self, "_on_char_setting_delete")
	
	_value_changed()


func _add_kerning_pair(kerning_pair_node = null, pair = null):
	if kerning_pair_node == null:
		kerning_pair_node = kerning_pair_scene.instance()
	
	kerning_pair_list.add_child(kerning_pair_node)
	kerning_pair_node.owner = self.owner
	
	kerning_pair_node.font_settings = font_settings
	
	if pair == null:
		pair = font_settings.add_kerning_pair()
	
	kerning_pair_node.set_kerning_pair(pair)
	kerning_pair_node.connect("change", self, "_value_changed")
	kerning_pair_node.connect("delete", self, "_on_kerning_pair_delete")
	
	_value_changed()


func _on_kerning_pair_delete(node):
	var idx = node.get_index()
	
	node.queue_free()
	font_settings.remove_kerning_pair(idx)
	_value_changed()


func _on_char_setting_delete(node):
	var for_char = node.for_char
	
	node.queue_free()
	font_settings.remove_setting(for_char)
	_value_changed()


func _value_changed():
	emit_signal("change")


func _on_AddCharSettingButton_pressed():
	_add_char_setting()


func _on_AddKerningButton_pressed():
	_add_kerning_pair()


func _on_Height_value_changed(value):
	var font = font_ref.get_ref()
	if font:
		font.height = value
	_value_changed()


func _on_Gap_value_changed(value):
	font_settings.gap = value
	_value_changed()


func _on_HorizontalAlign_value_changed(value):
	font_settings.horizontal_align = value
	_value_changed()


func _on_Ascent_value_changed(value):
	var font = font_ref.get_ref()
	if font:
		font.ascent = value
	_value_changed()


func _on_MonoSpaced_toggled(button_pressed):
	font_settings.monospace = button_pressed
	_value_changed()


func _on_VerticalAlign_value_changed(value):
	font_settings.vertical_align = value
	_value_changed()


func _on_TextEdit_text_changed():
	font_settings.preview_chars = preview_textbox.text
	_value_changed()


func _on_Scale_value_changed(value):
	preview.set_preview_scale(value / 100.0)


func _on_ColorPickerButton_color_changed(color):
	preview.set_preview_color(color)
	font_settings.preview_color = color
	_value_changed()
