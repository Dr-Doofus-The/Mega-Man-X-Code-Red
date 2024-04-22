tool
extends BitmapFont
class_name TextureFont


var _texture_mappings: Array
var _font_settings


const default_texture_mappings := {
	rect_size = Vector2(14, 14),
	rect_gap = Vector2(1, 1),
	texture_offset = Vector2(1, 1),
	chars = \
"""abcdefgh
ijklmnop
qrstuvwx
yz.,!?" """
}

func _init():
	_font_settings = load("res://addons/texture_fonts/Classes/TextureFontSettings.gd").new()


func get_class():
	return "TextureFont"

func add_texture(texture: Texture) -> void:
	.add_texture(texture)
	var mapping = load("res://addons/texture_fonts/Classes/TextureFontMapping.gd").new()
	mapping.set_texture(texture)
	mapping.rect_size = default_texture_mappings.rect_size
	mapping.rect_gap = default_texture_mappings.rect_gap
	mapping.texture_offset = default_texture_mappings.texture_offset
	mapping.chars = default_texture_mappings.chars
	
	self.texture_mappings.append(mapping)


func remove_texture(index: int) -> void:
	self.texture_mappings.remove(index)


func build_font():
	var height = self.height
	var ascent = self.ascent
	var distance_field = self.distance_field
	var fallback = self.fallback
	
	.clear()
	
	var mono: bool = self.font_settings.monospace
	var h_align: int = self.font_settings.horizontal_align
	var v_align: int = self.font_settings.vertical_align
	var gap: int = self.font_settings.gap
	
	var is_space_defined := false
	
	for i in _texture_mappings.size():
		var mapping = _texture_mappings[i]
		.add_texture(mapping.scaled_texture)
		
		var char_codes = mapping.char_codes
		
		for line in char_codes:
			for code in line:
				if code == 32:
					is_space_defined = true
				
				var rect
				
				if mono:
					rect = mapping.get_char_rect(code)
				else:
					rect = mapping.get_cropped_char_rect(code)
				
				if rect == null:
					continue
				
				var char_setting = _font_settings.get_setting(code)
				var align = char_setting.offset
				var advance = rect.size.x + char_setting.advance + gap
				
				align.x += h_align
				align.y += v_align
				
				add_char(code, i, rect, align, advance)
	
	# add empty space char
	if not is_space_defined and not fallback and _texture_mappings.size() > 0:
		var char_setting = _font_settings.get_setting(32)
		
		var extra_space := 0
		if mono:
			extra_space = _texture_mappings[0].rect_size.x * _texture_mappings[0].scale
		
		var advance = char_setting.advance + extra_space + gap
		
		var rect := Rect2(0,0,0,0)
		add_char(32, 0, rect, Vector2.ZERO, advance)
	
	self.height = height
	self.ascent = ascent
	self.distance_field = distance_field
	self.fallback = fallback
	
	var kerning_pairs = _font_settings.solve_kerning_pairs()
	
	for pair in kerning_pairs:
		add_kerning_pair(pair.char_a, pair.char_b, pair.kerning)
	
	emit_signal("changed")


func _get_property_list():
	
	var props = [
		{
			name = "texture_mappings",
			usage = PROPERTY_USAGE_NOEDITOR,
			type = TYPE_RAW_ARRAY
		},
		{
			name = "font_settings",
			usage = PROPERTY_USAGE_NOEDITOR,
			type = TYPE_NIL
		}
	]
	
	return props


func _get(property: String):
	match property:
		"texture_mappings":
			return _texture_mappings
		"font_settings":
			return _font_settings


func _set(property: String, val):
	match property:
		"texture_mappings":
			_texture_mappings = val
		"font_settings":
			_font_settings = val

