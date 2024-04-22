tool
extends MarginContainer

signal change

onready var size := $VBoxContainer/RectSettings/Size
onready var gap := $VBoxContainer/RectSettings/Gap
onready var offset := $VBoxContainer/RectSettings/Offset
onready var chars := $VBoxContainer/HSplitContainer/HBoxContainer/TextEdit
onready var texture_viewer := $VBoxContainer/HSplitContainer/TextureViewer
onready var scale := $VBoxContainer/RectSettings/Scaling/HBoxContainer/Scale
onready var interpolation := $VBoxContainer/RectSettings/Scaling/HBoxContainer/Interpolation

var current_mapping #: TextureFontMapping


var interpolation_options = [
	Image.INTERPOLATE_BILINEAR,
	Image.INTERPOLATE_CUBIC,
	Image.INTERPOLATE_LANCZOS,
	Image.INTERPOLATE_NEAREST,
	Image.INTERPOLATE_TRILINEAR
]


func _ready():
	interpolation.clear()
	interpolation.add_item("Bilinear")
	interpolation.add_item("Cubic")
	interpolation.add_item("Lanczos")
	interpolation.add_item("Nearest")
	interpolation.add_item("Trilinear")


func set_mapping(mapping):
	current_mapping = mapping
	
	var texture: Texture = mapping.source_texture
	var max_size := texture.get_size()
	
	size.max_value = max_size
	gap.max_value = max_size
	offset.max_value = max_size
	
	size.value = mapping.rect_size
	gap.value = mapping.rect_gap
	offset.value = mapping.texture_offset
	chars.text = mapping.chars
	scale.value = mapping.scale
	interpolation.selected = interpolation_options.find(mapping.interpolation)


func _on_Size_value_changed(value: Vector2):
	if current_mapping:
		current_mapping.rect_size = value
		emit_signal("change")


func _on_Gap_value_changed(value: Vector2):
	if current_mapping:
		current_mapping.rect_gap = value
		emit_signal("change")


func _on_Offset_value_changed(value: Vector2):
	if current_mapping:
		current_mapping.texture_offset = value
		emit_signal("change")


func _on_TextEdit_text_changed():
	if current_mapping:
		current_mapping.chars = chars.text
		emit_signal("change")


func _on_Scale_value_changed(value):
	if current_mapping:
		current_mapping.scale = value
		texture_viewer.set_texture(current_mapping.scaled_texture)
		emit_signal("change")


func _on_OptionButton_item_selected(index):
	if current_mapping:
		current_mapping.interpolation = interpolation_options[index]
		texture_viewer.set_texture(current_mapping.scaled_texture)
		emit_signal("change")
