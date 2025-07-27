extends Control

func _ready():
	_on_screen_resized()
	get_tree().root.connect('size_changed', _on_screen_resized)

func _on_screen_resized():
	set_size(get_tree().root.get_visible_rect().size)
	$WorldViewport.set_size(get_tree().root.get_visible_rect().size)
