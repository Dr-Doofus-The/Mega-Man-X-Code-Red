tool
extends HBoxContainer


signal change
signal delete

onready var fromLine = $LineEditFrom
onready var toLine = $LineEditTo
onready var offsetLine = $SpinBoxOffset

var font_settings


onready var idx := get_index()


# Dict which holds info about a kerning pair
#
# Kerning: {
# 	from: String,
# 	to: String,
# 	kerning: float
# }
func set_kerning_pair(new_kerning):
	fromLine.text = new_kerning.from
	toLine.text = new_kerning.to
	offsetLine.value = new_kerning.kerning


func _on_LineEditFrom_text_changed(new_text):
	font_settings.set_kerning_pair_from(idx, new_text)
	emit_signal("change")


func _on_LineEditTo_text_changed(new_text):
	font_settings.set_kerning_pair_to(idx, new_text)
	emit_signal("change")


func _on_SpinBoxOffset_value_changed(value):
	font_settings.set_kerning_pair_kerning(idx, value)
	emit_signal("change")


func _on_DeleteButton_pressed():
	emit_signal("delete", self)
