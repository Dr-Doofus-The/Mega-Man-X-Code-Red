tool
extends Reference

var num_regex := RegEx.new()
var unicode_regex := RegEx.new()

var regex_compiled := false

# split multi-line string into 2d array containing char codes
func chars_to_codes(chars: String) -> Array:
	var codes = []
	
	if not regex_compiled:
		num_regex.compile("[0-9A-Fa-f]+")
		unicode_regex.compile("\\\\U\\+[0-9A-Fa-f]+;")
		regex_compiled = true
	
	var i = 0
	var l = chars.length()
	var line = 0
	
	while i < l:
		var next_char = chars[i]
		var code_int = -1
		
		# dont save new-line smymbol, but switch to new line
		if next_char == "\n":
			if line + 1 > codes.size():
				codes.append([])
			line += 1
			i += 1
			continue
		# escape char might indicate unicode block
		elif next_char == "\\":
			var code = unicode_regex.search(chars, i)
			if code and code.get_start() == i:
				var num_code = num_regex.search(code.get_string())
				code_int = ("0x" + num_code.get_string()).hex_to_int()
				
				i += code.get_string().length() - 1
			else:
				code_int = ord("\\")
		# standard char
		else:
			code_int = ord(next_char)
		
		# add line, if not present
		if line + 1 > codes.size():
			codes.append([code_int])
		else:
			codes[line].append(code_int)
		
		i += 1
	
	return codes
