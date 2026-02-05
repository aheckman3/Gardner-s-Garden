extends Node

const SAVE_PATH := "user://savegame.json"

func save_game():
	var player = get_tree().get_first_node_in_group("player")
	var planter_container = get_tree().get_first_node_in_group("planter_containers")
	var data := {
		"scene": get_tree().current_scene.scene_file_path,
		"player": {
			"position": player.global_position,
			"facing": player.facing
		},
		"inventory": {
			"gold": Inventory.gold,
			"empty_planter": Inventory.empty_planter,
			"items": Inventory.inventory
		},
		"planters": _save_planters(planter_container)
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Game Saved")


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No Save File Found")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	if typeof(data) != TYPE_DICTIONARY:
		print("Save File Corrupted")
		return
		
	get_tree().change_scene_to_file(data["scene"])
	await get_tree().process_frame
	
	_restore_player(data["player"])
	_restore_inventory(data["inventory"])
	_restore_planters(data["planters"])
	
	print("Game Loaded")
	
func _save_planters(container):
	var result := []
	for planter in container.get_children():
		result.append({
			"position": planter.global_position,
			"plant_type": planter.plant_type,
			"growth":  planter.growth_stage,
			"watered": planter.watered,
			"interacted": planter.interacted,
			"chosen_variant": planter.chosen_variant
		})
	return result

func _restore_player(data):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: Player not found after scene load")
		return
		
	player.global_position = _to_vector2(data["position"])
	player.facing = data["facing"]
	
func _restore_inventory(data):
	Inventory.gold = data["gold"]
	Inventory.empty_planter = data["empty_planter"]
	Inventory.inventory = data["items"]
	Inventory.emit_signal("inventory_changed")
	
func _restore_planters(planter_list):
	var container = get_tree().get_first_node_in_group("planter_containers")
	var attempts := 0
	while container == null and attempts < 30:
		await get_tree().process_frame
		container = get_tree().get_first_node_in_group("planter_containers")
		attempts += 1
		
	if container == null:
		print("ERROR: Planter container not found after scene load")
		return
		
	var planter_scene = preload("res://Scenes/planter.tscn")
	
	for child in container.get_children():
		child.queue_free()
		
	for p in planter_list:
		var planter = planter_scene.instantiate()
		planter.global_position = _to_vector2(p["position"])
		planter.plant_type = p.get("plant_type", "")
		planter.growth_stage = p["growth"]
		planter.watered = p.get("watered", false)
		planter.interacted = p.get("interacted", false)
		planter.chosen_variant = p.get("chosen_variant", -1)
		planter.call_deferred("_apply_saved_state")
		container.add_child(planter)

func _to_vector2(str_value: String) -> Vector2:
	var cleaned := str_value.trim_prefix("(").trim_suffix(")")
	var parts := cleaned.split(",")
	return Vector2(parts[0].to_float(), parts[1].to_float())
	
