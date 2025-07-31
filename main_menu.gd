extends Control

#Called when ready enters the scene tree for the first time
func _ready():
	pass

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://clubroom.tscn")
	GameState.reset()
