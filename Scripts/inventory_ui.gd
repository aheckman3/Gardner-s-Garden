extends Control


var player : CharacterBody2D = null
var is_open = false
var slots := []
var item_icons := {
	"plant_dark_purple": preload("res://Assets/inventory_sprites/dark_purple_inv_sprite-4.png.png"),
	"plant_light_purple": preload("res://Assets/inventory_sprites/light_purple_inv_sprite-5.png.png"),
	"plant_orange": preload("res://Assets/inventory_sprites/orange_inv_sprite-6.png.png"),
	"plant_salmon": preload("res://Assets/inventory_sprites/salmon_inv_sprite-3.png.png"),
	"plant_blue": preload("res://Assets/inventory_sprites/blue_inv_sprite-7.png.png"),
	"empty_planter": preload("res://Assets/inventory_sprites/empty_planter_inv_sprite-8.png.png"),
	"gold": preload("res://Assets/inventory_sprites/gold-1.png.png")
}

func _ready():
	player = get_tree().get_first_node_in_group("player")
	close()

	slots = [
		$NinePatchRect/GridContainer/inv_UI_slot1, 
		$NinePatchRect/GridContainer/inv_UI_slot2,
		$NinePatchRect/GridContainer/inv_UI_slot3,
		$NinePatchRect/GridContainer/inv_UI_slot4,
		$NinePatchRect/GridContainer/inv_UI_slot5,
		$NinePatchRect/GridContainer/inv_UI_slot6,
		$NinePatchRect/GridContainer/inv_UI_slot7,
		$NinePatchRect/GridContainer/inv_UI_slot8,
	]

	Inventory.connect("inventory_changed", Callable(self, "update_inventory_ui"))
	update_inventory_ui()


func update_inventory_ui():
	var items = Inventory.inventory.keys()
	var index = 0
	
	for item_id in items:
		while index == 6 or index == 7:
			index += 1
		if index >= slots.size():
			break
			
		var slot = slots[index]
		var icon = slot.get_node("TextureRect")
		var label = slot.get_node("Label")
		var count = Inventory.get_count(item_id)

		if count > 0:
			icon.texture = item_icons[item_id]
			label.text = str(count)
			icon.visible = true
			label.visible = true
		else:
			icon.texture = null
			label.text = ""
			icon.visible = false
			label.visible = false
		index += 1
	update_gold_slot()
	update_planter_slot()


func update_gold_slot():
	var gold_slot = slots[7]
	var icon = gold_slot.get_node("TextureRect")
	var label = gold_slot.get_node("Label")

	icon.texture = preload("res://Assets/inventory_sprites/gold-1.png.png")
	label.text = str(Inventory.gold)
	
	icon.visible = true
	label.visible = true


func update_planter_slot():
	var planter_slot = slots[6]
	var icon = planter_slot.get_node("TextureRect")
	var label = planter_slot.get_node("Label")
	
	icon.texture = preload("res://Assets/inventory_sprites/empty_planter_inv_sprite-8.png.png")
	label.text = str(Inventory.get_count("empty_planter"))
	
	icon.visible = true
	label.visible = true


func _process(_delta: float) -> void:
	if Inventory.shop_open:
		return
	
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()


func open():
	visible = true
	is_open = true


func close():
	visible = false
	is_open = false


func _on_place_planter_pressed() -> void:
	if player:
		player.start_placing_planter()


func _on_save_button_pressed() -> void:
	SaveManager.save_game()


func _on_load_game_pressed() -> void:
	SaveManager.load_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
