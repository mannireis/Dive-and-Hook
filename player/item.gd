extends Node2D

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
