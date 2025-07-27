extends TextureProgressBar



func _on_battlescape_kill_mode_update(state: bool) -> void:
	value = int(state)
