tool
extends Resource

var char_utils := preload("../Util/CharUtils.gd").new()

# {
# 	for_char: String = {
# 		advance: int,
# 		offset: Vector2
# 	}
# }
export var char_settings: Dictionary

# [
# 	{
# 		from: String,
# 		to: String,
# 		kerning: int
# 	}
# ]
export var kerning_pairs: Array

export var gap := 2
export var horizontal_align := 1
export var vertical_align := 0
export var monospace := false


export var preview_color: Color = Color("202431")
export var preview_chars: String


func get_default_setting():
	return {
		advance = 0.0,
		offset = Vector2.ZERO
	}

func _init():
	char_settings = {}
	kerning_pairs = []

# ------ Settings Functions ------

func add_setting(for_char: String) -> Dictionary:
	char_settings[for_char] = {
		advance = 0.0,
		offset = Vector2.ZERO
	}
	
	return char_settings[for_char]


func insert_setting(for_char: String, setting: Dictionary):
	char_settings[for_char] = setting


func remove_setting(for_char: String):
	if char_settings.has(for_char):
		char_settings.erase(for_char)


func set_setting(for_char: String, advance: int, offset: Vector2):
	char_settings[for_char] = {
		advance = advance,
		offset = offset
	}


func get_setting(char_code: int):
	if char_code == -1:
		return get_default_setting()
	
	for char_string in char_settings:
		var char_codes: Array = char_utils.chars_to_codes(char_string).front()
		if char_code in char_codes:
			return char_settings[char_string]
	
	return get_default_setting()


func set_advance(for_char: String, advance: int):
	if not char_settings.has(for_char):
		add_setting(for_char)
	
	char_settings[for_char].advance = advance


func set_offset(for_char: String, offset: Vector2):
	if not char_settings.has(for_char):
		add_setting(for_char)
	
	char_settings[for_char].offset = offset


func get_advance(for_char: String):
	if char_settings.has(for_char):
		return char_settings[for_char].advance
	else:
		return 0.0


func get_offset(for_char: String):
	if char_settings.has(for_char):
		return char_settings[for_char].offset
	else:
		return Vector2.ZERO


# ------ Kerning Pair Functions ------

func add_kerning_pair() -> Dictionary:
	var new_pair = {
		from = "",
		to = "",
		kerning = 0
	}
	
	kerning_pairs.append(new_pair)
	return new_pair


func insert_kerning_pair(idx: int, new_kerning: Dictionary):
	kerning_pairs.insert(idx, new_kerning)


func remove_kerning_pair(idx: int):
	kerning_pairs.remove(idx)


func set_kerning_pair(idx: int, new_kerning: Dictionary):
	kerning_pairs[idx] = new_kerning


func set_kerning_pair_from(idx: int, new_from: String):
	kerning_pairs[idx].from = new_from


func set_kerning_pair_to(idx: int, new_to: String):
	kerning_pairs[idx].to = new_to


func set_kerning_pair_kerning(idx: int, new_kerning: int):
	kerning_pairs[idx].kerning = new_kerning


func get_kerning_pair(idx: int) -> Dictionary:
	return kerning_pairs[idx]


func solve_kerning_pairs() -> Array:
	var solved_list := []
	for pair in kerning_pairs:
		if pair.from == "" or pair.to == "" or pair.kerning == 0:
			continue
		
		var from_array: Array = char_utils.chars_to_codes(pair.from).front()
		var to_array: Array = char_utils.chars_to_codes(pair.to).front()
		
		for a in from_array:
			for b in to_array:
				solved_list.append({
					char_a = a,
					char_b = b,
					kerning = pair.kerning
				})
	
	return solved_list
