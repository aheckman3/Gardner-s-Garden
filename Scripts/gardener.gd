extends CharacterBody2D


const SPEED = 75.0
@onready var col_shape = $CollisionShape2D
@onready var planter_container = get_tree().get_first_node_in_group("planter_containers")
@onready var anim = $AnimatedSprite2D
var facing := "down"
var is_using_tool := false
var placing_planter := false
var planter_preview : Node2D = null
var planter_scene := preload("res://Scenes/planter.tscn")
var shop_cooldown := false

func _ready():
	if Inventory.shop_open == false:
		_start_shop_cooldown()
	
func _physics_process(_delta: float) -> void:
	var x_dir := Input.get_axis("left", "right")
	var y_dir := Input.get_axis("up", "down")
	var direction := Vector2(x_dir, y_dir)
	
	if get_tree().paused:
		return


	if placing_planter and planter_preview:
		var mouse_pos = get_global_mouse_position()
		planter_preview.global_position = mouse_pos
		
		if can_place_planter(mouse_pos):
			planter_preview.modulate = Color(1, 1, 1, 0.5)
		else: 
			planter_preview.modulate = Color(1, 0.3, 0.3, 0.5)
	

	# If using a tool, ignore movement animations
	if is_using_tool:
		move_and_slide()
		return

	# Movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * SPEED

		# Update facing direction
		if abs(direction.x) > abs(direction.y):
			facing = "right" if direction.x > 0 else "left"
		else:
			facing = "down" if direction.y > 0 else "up"

		play_walk_animation()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		play_idle_animation()

	# Tool use overrides animation
	if Input.is_action_just_pressed("water") and not is_using_tool and direction == Vector2.ZERO:
		is_using_tool = true
		anim.play("water_" + facing)
	move_and_slide()

func start_placing_planter():
	if Inventory.get_count("empty_planter") > 0:
		placing_planter = true
		planter_preview = planter_scene.instantiate()
		planter_preview.modulate = Color(1, 1, 1, 0.5) #gives transparent view
		planter_container.add_child(planter_preview)
		var solid = planter_preview.get_node("StaticBody2D")
		solid.set_collision_layer_value(1, false)
		solid.set_collision_layer_value(2, true)


func _input(event):
	if event.is_action_pressed("planter"):
		if placing_planter:
			planter_preview.queue_free()
			planter_preview = null
			placing_planter = false
		else:
			start_placing_planter()
	if placing_planter and event.is_action_pressed("place"):
		place_planter()
	if placing_planter and event.is_action_pressed("cancel"):
		planter_preview.queue_free()
		planter_preview = null
		placing_planter = false
		
	if Input.is_action_just_pressed("pause"):
		var menu = get_tree().get_first_node_in_group("pause_menu")
		menu.toggle_pause()


func place_planter():
	var pos = planter_preview.global_position
	if can_place_planter(pos):
		var planter = planter_scene.instantiate()
		planter.global_position = pos
		planter_container.add_child(planter)
		planter_preview.modulate = Color(1, 1, 1, 1)
		planter_preview.queue_free()
		planter_preview = null
		placing_planter = false
		Inventory.remove_item("empty_planter", 1)
	else:
		print("blocked")
		
func can_place_planter(target_pos: Vector2) -> bool:
	var temp_planter = planter_scene.instantiate()
	temp_planter.global_position = target_pos
	
	var shape = temp_planter.get_node("StaticBody2D/CollisionShape2D").shape
	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, target_pos)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	params.collision_mask = 1

	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_shape(params)
	
	temp_planter.queue_free()
	
	return result.is_empty()
	
func try_place_planter(target_pos: Vector2):
	if can_place_planter(target_pos):
		var planter = preload("res://Scenes/planter.tscn").instantiate()
		planter.global_position = position
		get_tree().current_scene.add_child(planter)
	else:
		print("blocked")
func play_walk_animation():
	anim.play("walk_" + facing)


func play_idle_animation():
	anim.play("idle_" + facing)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_using_tool:
		is_using_tool = false
		anim.play("idle_" + facing)

func _go_to_shop():
	$AudioStreamPlayer2D.play()
	SaveManager.save_game()
	await $AudioStreamPlayer2D.finished
	get_tree().change_scene_to_file("res://Scenes/shop_inside.tscn")



func temporarily_disable():
	col_shape.disabled = true
	await get_tree().create_timer(2.0).timeout
	col_shape.disabled = false

func _on_shop_body_entered(body: Node2D) -> void:

	if shop_cooldown:
		return

	if body.is_in_group("player") and facing == "up":
		shop_cooldown = true
		call_deferred("_go_to_shop")
		_start_shop_cooldown()
		
func _start_shop_cooldown():
	shop_cooldown = true
	await get_tree().create_timer(1.5).timeout
	shop_cooldown = false
