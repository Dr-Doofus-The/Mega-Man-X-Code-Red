tool
extends TextureRect


var hover := false
var texture_font_mapping


onready var rect_preview := $RectPreview
onready var label := $RectPreview/Label


func _on_TextureView_mouse_entered():
	hover = true
	rect_preview.visible = true
	

func _on_TextureView_mouse_exited():
	hover = false
	rect_preview.visible = false

func _gui_input(event):
	if hover and event is InputEventMouseMotion:
		var c = texture_font_mapping.get_char_at_position(event.position)
		if c == "":
			rect_preview.visible = false
			return
		else:
			label.text = c
			var rect: Rect2 = texture_font_mapping.get_rect_for_position(event.position)
			rect_preview.rect_position = rect.position
			rect_preview.rect_size = rect.size
			rect_preview.visible = true
