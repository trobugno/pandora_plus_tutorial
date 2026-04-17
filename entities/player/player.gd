class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var current_location: PPLocationEntity
var current_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var last_NPC: NPC = null

func _ready() -> void:
	PPPlayerManager.initialize_new_player("tester")
	var player_data = PPPlayerManager.get_player_data()
	var base_stats = PPStats.new(100, 50, 3, 5)
	base_stats._mov_speed = 60
	player_data.base_stats = base_stats
	player_data.runtime_stats = PPRuntimeStats.new(base_stats)
	
	var mushrooms = Pandora.get_entity(EntityIds.MUSHROOMS).instantiate() as PPItemEntity
	var roots = Pandora.get_entity(EntityIds.ROOT).instantiate() as PPItemEntity
	var armoatic_leaves = Pandora.get_entity(EntityIds.AROMATIC_LEAVES).instantiate() as PPItemEntity
	PPPlayerManager.add_item(mushrooms, 5)
	PPPlayerManager.add_item(roots, 5)
	PPPlayerManager.add_item(armoatic_leaves, 3)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and last_NPC and not Globals.block_player_actions:
		last_NPC.interact()
		Globals.block_player_actions = true

func _physics_process(_delta: float) -> void:
	if Globals.block_player_actions:
		return
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var runtime_stats = PPPlayerManager.get_runtime_stats()
	velocity = input_dir * runtime_stats.get_effective_stat("mov_speed")
	
	if input_dir != Vector2.ZERO:
		is_moving = true
		current_direction = input_dir
		PPPlayerManager.set_position(Vector3(global_position.x, global_position.y, 0))
		update_animation()
	else:
		is_moving = false
		set_idle_frame()
	
	move_and_slide()

func update_animation() -> void:
	if abs(current_direction.x) > abs(current_direction.y):
		# moving horizontally
		if current_direction.x > 0:
			animation_player.play("right_walk")
		else:
			animation_player.play("left_walk")
	else:
		# moving vertically
		if current_direction.y > 0:
			animation_player.play("down_walk")
		else:
			animation_player.play("up_walk")

func set_idle_frame() -> void:
	animation_player.stop()
	
	if abs(current_direction.x) > abs(current_direction.y):
		if current_direction.x > 0:
			animation_player.play("right_idle")
		else:
			animation_player.play("left_idle")
	else:
		if current_direction.y > 0:
			animation_player.play("down_idle")
		else:
			animation_player.play("up_idle")

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is NPC:
		last_NPC = body
		last_NPC.show_name()

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body is NPC and body == last_NPC:
		last_NPC.hide_name()
		last_NPC = null
