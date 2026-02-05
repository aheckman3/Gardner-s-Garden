extends Node

signal inventory_changed
var shop_open := false
var gold := 0
var empty_planter := 10

var inventory := {
	"plant_dark_purple": 5,
	"plant_light_purple": 5,
	"plant_orange": 5,
	"plant_salmon": 5,
	"plant_blue": 5,
	"empty_planter": 10
}
	
func add_gold(amount: int):
	gold += amount
	emit_signal("inventory_changed")


func add_planter(_amount: int):
	add_item("empty_planter", 1)
	emit_signal("inventory_changed")


func add_five_planters(_amount: int):
	add_item("empty_planter", 5)
	emit_signal("inventory_changed")


func remove_planter(amount: int):
	empty_planter = max(0, empty_planter - amount)
	emit_signal("inventory_changed")


func remove_gold(amount: int):
	gold = max(0, gold - amount)
	emit_signal("inventory_changed")


func add_item(item_id: String, amount := 1):
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	emit_signal("inventory_changed")


func remove_item(item_id: String, amount := 1):
	if inventory.has(item_id):
		inventory[item_id] = max(0, inventory[item_id] - amount)
	emit_signal("inventory_changed")


func get_count(item_id: String) -> int:
	return inventory.get(item_id, 0)
