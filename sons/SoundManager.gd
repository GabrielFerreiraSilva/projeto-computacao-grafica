extends Node

var is_sound_enabled: bool = true

signal sound_state_changed(is_enabled: bool)

func toggle_sound():
	is_sound_enabled = !is_sound_enabled
	sound_state_changed.emit(is_sound_enabled)
