extends Node
# Keeps track of recent inputs in order to make timing windows more flexible.
# Intended use: Add this file to your project as an Autoload script and have other objects call the class' methods.
# (more on AutoLoad: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)

# How many milliseconds ahead of time the player can make an input and have it still be recognized.
# I chose the value 150 because it imitates the 9-frame buffer window in the Super Smash Bros. Ultimate game.
const BUFFER_WINDOW: int = 150

var keyboard_timestamps: Dictionary
var joypad_timestamps: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	# Initialize all dictionary entris.
	keyboard_timestamps = {}
	joypad_timestamps = {}
	

# Called whenever the player makes an input.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed or event.is_echo():
			return
			
		var scancode: int = event.scancode
		keyboard_timestamps[scancode] = Time.get_ticks_msec()
	elif event is InputEventJoypadButton:
		if !event.pressed or event.is_echo():
			return
			
		var button_index: int = event.button_index
		joypad_timestamps[button_index] = Time.get_ticks_msec()
	
# Returns whether any of the keyboard keys or joypad buttons in the given action were pressed within the buffer window.
func is_action_press_buffered(action: String) -> bool:
	# Get the inputs associated with the action. If any one of them was pressed in the last BUFFER_WINDOW milliseconds,
	# the action is buffered.
	for event in InputMap.get_action_list(action):
		if event is InputEventKey:
			var scancode: int = event.scancode
			if keyboard_timestamps.has(scancode):
				if Time.get_ticks_msec() - keyboard_timestamps[scancode] <= BUFFER_WINDOW:
					# Prevent this method from returning true repeatedly and registering duplicate actions.
					_invalidate_action(action)
					
					return true;
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				if Time.get_ticks_msec() - joypad_timestamps[button_index] <= BUFFER_WINDOW:
					_invalidate_action(action)
					return true
	# If there's ever a third type of buffer-able action (mouse clicks maybe?), it'd probably be worth it to generalize
	# the repetitive keyboard/joypad code into something that works for any input method. Until then, by the YAGNI 
	# principle, the repetitive stuff stays >:)
	
	return false


# Records unreasonable timestamps for all the inputs in an action. Called when IsActionPressBuffered returns true, as
# otherwise it would continue returning true every frame for the rest of the buffer window.
func _invalidate_action(action: String) -> void:
	for event in InputMap.get_action_list(action):
		if event is InputEventKey:
			var scancode: int = event.scancode
			if keyboard_timestamps.has(scancode):
				keyboard_timestamps[scancode] = 0
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				joypad_timestamps[button_index] = 0
