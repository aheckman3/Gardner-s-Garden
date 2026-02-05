extends Node2D

@onready var timer := $Timer
var plant_type : String = ""
var growth_stage : int = 0
var watered : bool = false
var player_in_range := false
var current_index := 0
var sprites := []
var interacted := false
var chosen_variant := -1
var variant_ids := {
	3: "plant_dark_purple",
	4: "plant_light_purple",
	5: "plant_orange",
	6: "plant_salmon",
	7: "plant_blue"
}

func _ready() -> void:
	_setup_visuals()
func _setup_visuals():
	# Collect all Sprite2D children into an array
	sprites = [
		$unplanted,
		$planted_empty,
		$bud,
		$dark_purple,
		$light_purple,
		$orange,
		$salmon,
		$blue
	]
	
	if growth_stage == 0:
		show_only(0)
		return
	if growth_stage == 1:
		show_only(1)
		return
	if growth_stage == 2:
		show_only(2)
		return
	if growth_stage >= 3:
		show_only(growth_stage)
		return


func show_only(index: int):
	for i in range(sprites.size()):
		sprites[i].visible = (i == index)


func interact():
	if interacted:
		return
		
	interacted = true
	growth_stage = 1
	show_only(1)
	$Timer.start()


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("water"):
		interact()
	if player_in_range and Input.is_action_just_pressed("harvest"):
		harvest()
	if player_in_range and Input.is_action_just_pressed("pickup"):
		_pickup_planter()

func _on_timer_timeout() -> void:
	growth_stage = 2
	show_only(2)
	$Timer2.start()
	
	


func _on_timer_2_timeout() -> void:
	chosen_variant = randi_range(3, 7)
	growth_stage = chosen_variant
	plant_type = variant_ids[chosen_variant]
	show_only(chosen_variant)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "gardener":
		player_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "gardener":
		player_in_range = false


func harvest():
	if chosen_variant in variant_ids:
		var item_id = variant_ids[chosen_variant]
		Inventory.add_item(item_id, 1)
		reset_planter()

func _pickup_planter():
	if growth_stage == 0:
		Inventory.add_planter(1)
		queue_free()
		


		
func reset_planter():
	interacted = false
	chosen_variant = -1
	growth_stage = 0
	plant_type = ""
	watered = false
	show_only(0)

	
func _apply_saved_state():
	_setup_visuals()
	
	if growth_stage == 1:
		$Timer.start()
		
	elif growth_stage == 2:
		$Timer2.start()
