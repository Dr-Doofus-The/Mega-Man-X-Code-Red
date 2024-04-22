tool
extends VBoxContainer

onready var text_edit := $MarginContainer/TextEdit
onready var colorpicker := $HeadingBox/ColorPickerButton

func set_font(new_font: BitmapFont):
	text_edit.set("custom_fonts/font", new_font)


func set_preview_text(new_text):
	if new_text == null: new_text == ""
	text_edit.text = new_text


func set_preview_color(color: Color):
	colorpicker.color = color
	
	var stylebox: StyleBoxFlat = text_edit.get("custom_styles/normal")
	stylebox.bg_color = color.darkened(0.2)
	stylebox = text_edit.get("custom_styles/focus")
	stylebox.bg_color = color
	
	text_edit.set("custom_colors/caret_color", color.inverted())


func set_preview_scale(scale):
	text_edit.rect_scale = Vector2(scale, scale)


