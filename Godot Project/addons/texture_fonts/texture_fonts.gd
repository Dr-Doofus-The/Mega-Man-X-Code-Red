tool
extends EditorPlugin


var _handling_resource: WeakRef
var _font_editor: Control
var is_disk_resource := false

func _enter_tree():
	get_editor_interface().get_resource_filesystem().connect("filesystem_changed", self, "_on_filesystem_changed")


func _exit_tree():
	close_editor()

func handles(object: Object) -> bool:
	if object is BitmapFont and object.get_class() == "TextureFont":
		return true
	elif _handling_resource:
		_handling_resource = null
		close_editor()
	
	return false

func edit(object: Object):
	var resoruce: BitmapFont = object as BitmapFont
	_handling_resource = weakref(resoruce)
	
	if resoruce.resource_path != "":
		is_disk_resource = true
	else:
		is_disk_resource = false
		
	open_editor(resoruce)

func open_editor(font: Object):
	
	if not is_instance_valid(_font_editor):
		_font_editor = preload("./UI/FontEditor.tscn").instance()
		add_control_to_bottom_panel(_font_editor, "Texture Font")
		_font_editor.connect("close", self, "close_editor")
	
	_font_editor.edit_font(font)
	make_bottom_panel_item_visible(_font_editor)

func close_editor():
	if is_instance_valid(_font_editor):
		_font_editor.save_now()
		hide_bottom_panel()
		remove_control_from_bottom_panel(_font_editor)
		_font_editor.queue_free()

func _on_filesystem_changed():
	if _handling_resource and is_disk_resource:
		if not _handling_resource.get_ref() or _handling_resource.get_ref().resource_path == "":
			_handling_resource = null
			close_editor()
