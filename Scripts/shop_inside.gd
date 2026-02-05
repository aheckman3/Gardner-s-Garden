extends Control
signal inventory_changed
@onready var hover := $hoversound
var planter_price := 30
var five_planters := 150
var plant_sell_prices := {
	"plant_dark_purple": 1,
	"plant_light_purple": 1,
	"plant_orange": 1,
	"plant_salmon": 1,
	"plant_blue": 5
}
func _ready() -> void:
	Inventory.connect("inventory_changed", Callable(self, "update_shop_buttons"))
	$inventory_UI.visible = true


func _process(_delta: float) -> void:
	print(Inventory.gold)


func open_shop():
	Inventory.shop_open = true
	visible = true


func close_shop():
	Inventory.shop_open = false


func buy_empty_planter():
	if Inventory.gold >= planter_price:
		Inventory.remove_gold(planter_price)
		Inventory.add_planter(1)
		emit_signal("inventory_changed")


func buy_five():
	if Inventory.gold >= five_planters:
		Inventory.remove_gold(five_planters)
		Inventory.add_five_planters(1)
		emit_signal("inventory_changed")


func sell_dark_purple():
	if Inventory.get_count("plant_dark_purple") > 0:
		Inventory.remove_item("plant_dark_purple")
		Inventory.add_gold(1)


func sell_light_purple():
	if Inventory.get_count("plant_light_purple") > 0:
		Inventory.remove_item("plant_light_purple")
		Inventory.add_gold(1)


func sell_orange():
	if Inventory.get_count("plant_orange") > 0:
		Inventory.remove_item("plant_orange")
		Inventory.add_gold(1)


func sell_salmon():
	if Inventory.get_count("plant_salmon") > 0:
		Inventory.remove_item("plant_salmon")
		Inventory.add_gold(1)


func sell_blue():
	if Inventory.get_count("plant_blue") > 0:
		Inventory.remove_item("plant_blue")
		Inventory.add_gold(5)


func _on_button_pressed() -> void:
	sell_dark_purple()


func _on_sell_light_purple_pressed() -> void:
	sell_light_purple()


func _on_sell_orange_pressed() -> void:
	sell_orange()


func _on_sell_salmon_pressed() -> void:
	sell_salmon()


func _on_sell_blue_pressed() -> void:
	sell_blue()


func _on_buy_planter_pressed() -> void:
	buy_empty_planter()


func _on_buy_5_pressed() -> void:
	buy_five()


func _on_sell_all_pressed() -> void:
	for plant_id in plant_sell_prices.keys():
		var count := Inventory.get_count(plant_id)
		if count > 0:
			Inventory.remove_item(plant_id, count)
			
			var gold_earned : int = plant_sell_prices[plant_id] * count
			Inventory.add_gold(gold_earned)
		emit_signal("inventory_changed")

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	SaveManager.load_game()


func _on_sell_dark_purple_mouse_entered() -> void:
	hover.play()


func _on_sell_light_purple_mouse_entered() -> void:
	hover.play()


func _on_sell_orange_mouse_entered() -> void:
	hover.play()


func _on_sell_salmon_mouse_entered() -> void:
	hover.play()


func _on_sell_blue_mouse_entered() -> void:
	hover.play()


func _on_exit_mouse_entered() -> void:
	hover.play()


func _on_buy_planter_mouse_entered() -> void:
	hover.play()


func _on_buy_5_mouse_entered() -> void:
	hover.play()


func _on_sell_all_mouse_entered() -> void:
	hover.play()


func _on_sell_dark_purple_mouse_exited() -> void:
	hover.play()

func _on_sell_light_purple_mouse_exited() -> void:
	hover.play()


func _on_sell_orange_mouse_exited() -> void:
	hover.play()


func _on_sell_salmon_mouse_exited() -> void:
	hover.play()


func _on_sell_blue_mouse_exited() -> void:
	hover.play()


func _on_exit_mouse_exited() -> void:
	if not hover.is_inside_tree():
		return
	hover.play()


func _on_buy_planter_mouse_exited() -> void:
	hover.play()


func _on_buy_5_mouse_exited() -> void:
	hover.play()


func _on_sell_all_mouse_exited() -> void:
	hover.play()
