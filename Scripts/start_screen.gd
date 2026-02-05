extends Control

@onready var hover := $hoversound

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	




func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	SaveManager.load_game()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_load_game_mouse_entered() -> void:
	hover.play()


func _on_new_game_mouse_entered() -> void:
	hover.play()


func _on_quit_mouse_entered() -> void:
	hover.play()


func _on_load_game_mouse_exited() -> void:
	if not hover.is_inside_tree():
		return
	hover.play()

func _on_new_game_mouse_exited() -> void:
	if not hover.is_inside_tree():
		return
	hover.play()

func _on_quit_mouse_exited() -> void:
	hover.play()
