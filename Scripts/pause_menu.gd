extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
func toggle_pause():
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused


func _on_continue_pressed() -> void:
	toggle_pause()

func _on_save_pressed() -> void:
	SaveManager.save_game()

func _on_quit_pressed() -> void:
	get_tree().quit()
