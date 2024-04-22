tool
extends VBoxContainer

onready var texture_view := $Control/TextureContainer/TextureView
onready var texture_container := $Control/TextureContainer
onready var zoom_spinbox := $Heading/SpinBox

var hover := false

var zoom := 100.0 setget set_zoom, get_zoom
var _zoom := 100.0
func set_zoom(new_zoom):
	_zoom = clamp(new_zoom, 10, 5000)
	texture_view.rect_scale = Vector2(float(_zoom) / 100.0, float(_zoom) / 100.0)
	texture_view.rect_pivot_offset = texture_view.rect_size / 2.0
func get_zoom():
	return _zoom


var texture_font_mapping setget set_mapping
func set_mapping(new_mapping):
	texture_view.texture_font_mapping = new_mapping


func zoom_in():
	self.zoom *= 1.1
	zoom_spinbox.value = self.zoom

func zoom_out():
	self.zoom *= 0.9
	zoom_spinbox.value = self.zoom


func set_texture(texture: Texture):
	if is_inside_tree():
		texture_container.set_texture(texture)
		texture_view.texture = texture
		texture_view.rect_size = texture.get_size()
		texture_view.rect_pivot_offset = texture_view.rect_size / 2.0

func _input(event):
	if hover:
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					zoom_in()
				BUTTON_WHEEL_DOWN:
					zoom_out()
		elif event is InputEventMouseMotion:
			event = event as InputEventMouseMotion
			
			if event.button_mask & BUTTON_LEFT:
				texture_container.offset += event.relative


func _on_SpinBox_value_changed(value):
	self.zoom = value


func _on_TextureContainer_mouse_entered():
	hover = true


func _on_TextureContainer_mouse_exited():
	hover = false
