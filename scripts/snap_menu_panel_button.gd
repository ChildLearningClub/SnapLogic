@tool
extends Button

var state: bool = true

func _ready() -> void: # Force buttons to behave like built in engine UI menu buttons
	toggled.connect(func(toggled_on: bool) -> void: 
		if toggled_on:
			set_flat(false)
			state = false
		else:
			set_flat(true)
			state = true)

	mouse_entered.connect(func() -> void: set_flat(false))
	mouse_exited.connect(func() -> void: set_flat(state))
