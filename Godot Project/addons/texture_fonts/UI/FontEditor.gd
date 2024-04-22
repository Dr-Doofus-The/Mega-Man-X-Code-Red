tool
extends MarginContainer

signal close

# ------ Resources ------

const file_scene = preload("./Components/File.tscn")

# ------ References ------

onready var file_list := $TabContainer/Textures/Files/Panel/ScrollContainer/FileList
onready var file_dialog := $TabContainer/Textures/Files/HeadingBox/AddTextureButton/FileDialog
onready var file_settings := $TabContainer/Textures/FileSettings
onready var texture_viewer := $TabContainer/Textures/FileSettings/VBoxContainer/HSplitContainer/TextureViewer
onready var no_selection_overlay := $TabContainer/Textures/FileSettings/NoSelectionOverlay

onready var font_preview := $"TabContainer/Font Settings/Preview"
onready var font_settings := $"TabContainer/Font Settings"

# ------ Variables ------

var selected_file_node
var file_nodes: Array = []
var font_ref: WeakRef

# ------ Inherited Methods -----

func _ready():
	file_settings.connect("change", self, "queue_save")
	font_settings.connect("change", self, "queue_save")

# ------ Methods ------


# reset editor, and populate for new font
func edit_font(new_font) -> void:	
	if font_ref:
		save_now()
	
	font_ref = weakref(new_font)
	for node in file_nodes:
		node.queue_free()
	
	file_nodes.clear()
	
	no_selection_overlay.visible = true
	
	for mapping in new_font.texture_mappings:
		_add_texture_ui(mapping.source_texture)
	
	if file_nodes.size() != 0:
		change_texture(0)
	
	if is_inside_tree():
		font_settings.set_font(new_font)
		font_preview.set_font(new_font)


func get_font_from_ref() -> Font:
	var font = font_ref.get_ref()
	
	if font: return font
	else:
		emit_signal("close")
		return font


func update_overlay():
	if is_instance_valid(selected_file_node):
		no_selection_overlay.visible = false
	else:
		no_selection_overlay.visible = true


var _queued_save_count := 0
func queue_save(timeout := 2.5):
	_queued_save_count += 1
	
	if not is_inside_tree():
		return
	
	var timer = Timer.new()
	add_child(timer)
	timer.start(2.5)
	yield(timer, "timeout")
	
	_queued_save_count -= 1
	if _queued_save_count == 0:
		_save()
	elif _queued_save_count < 0:
		_queued_save_count += 1


func save_now():
	_queued_save_count = 0
	_save()


func _save():
	if font_ref and font_ref.get_ref():
		var font = get_font_from_ref()
		
		font.build_font()
		
		if font.resource_path == "":
			return
		
		var error := ResourceSaver.save(font.resource_path, font)
		if error != OK:
			push_error("Failed to Save Font with Path: " + font.resource_path + ". Error Code: " + String(error))
		else:
			print("Saved Font: " + font.resource_path)
	else:
		emit_signal("close")

# ------ Actions ------


func add_texture(texture: Texture, idx := -1):
	_add_texture_ui(texture, idx)
	var font = get_font_from_ref()
	font.add_texture(texture)
	change_texture(file_list.get_child_count() - 1)
	queue_save()

func _add_texture_ui(texture: Texture, idx := -1):
	var file_node := file_scene.instance()
	
	file_list.add_child(file_node)
	file_node.set_texture(texture)
	if idx == -1:
		file_nodes.append(file_node)
	else:
		file_list.move_child(file_node, idx)
		file_nodes.insert(idx, file_node)
	
	file_node.connect("file_removed", self, "_on_file_removed")
	file_node.connect("file_changed", self, "_on_file_changed")


func delete_texture(node):
	var index = file_nodes.find(node)
	node.queue_free()
	file_nodes.remove(index)
	
	if node == selected_file_node:
		selected_file_node = null
	
	var font = get_font_from_ref()
	font.remove_texture(index)
	
	update_overlay()
	queue_save()


func change_texture(index: int):
	var file = file_nodes[index]
	
	if is_instance_valid(selected_file_node):
		selected_file_node.selected = false
	
	var font = get_font_from_ref()
	
	if is_instance_valid(file):
		file.selected = true
		selected_file_node = file
		texture_viewer.set_texture(font.texture_mappings[index].scaled_texture)
	
	file_settings.set_mapping(font.texture_mappings[index])
	texture_viewer.set_mapping(font.texture_mappings[index])
	
	update_overlay()


# ------ Signals ------

func _on_file_removed(file):
	if file == selected_file_node:
		selected_file_node = null
		if not file_nodes.empty():
			selected_file_node = file_nodes.front()
			selected_file_node.selected = true
	
	delete_texture(file)
	update_overlay()


func _on_file_changed(file):
	var idx = file_nodes.find(file)
	if idx == -1:
		return
	
	change_texture(idx)


func _on_AddTextureButton_pressed():
	file_dialog.popup_centered()


func _on_FileDialog_file_selected(path):
	var texture = load(path)
	if texture is Texture:
		add_texture(texture)
