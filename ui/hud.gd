class_name HUD extends CanvasLayer

const UI_NOTIFICATION = preload("uid://p6shdjw8noyd")
const QUEST_GUI = preload("uid://tfffqne231ua")
const INVENTORY_GUI = preload("uid://lm8k4vjicofe")
const CRAFTING_GUI = preload("uid://r1lljb4a6vrm")

@onready var notification_container: VBoxContainer = %NotificationContainer

var current_gui : Control

func _ready() -> void:
	PPQuestManager.quest_added.connect(_on_quest_added)
	PPQuestManager.quest_completed.connect(_on_quest_completed)
	Globals.location_reach.connect(_on_location_reach)
	Globals.open_crafting_gui.connect(_on_open_crafting_gui)
	Globals.notify.connect(_on_notify)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_ended() -> void:
	if current_gui:
		return
	
	Globals.block_player_actions = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and current_gui:
		if current_gui is CraftingGUI:
			current_gui.close_gui()
		else:
			current_gui.queue_free()
		
		Globals.block_player_actions = false
	
	if Globals.block_player_actions:
		return
	
	if Input.is_action_just_pressed("toggle_inventory"):
		Globals.block_player_actions = true
		if not current_gui:
			current_gui = INVENTORY_GUI.instantiate() as InventoryGUI
			current_gui.set_current_scene_node(self)
			add_child(current_gui)
		elif not current_gui is InventoryGUI:
			current_gui.queue_free()
			current_gui = INVENTORY_GUI.instantiate() as InventoryGUI
			current_gui.set_current_scene_node(self)
			add_child(current_gui)
		else:
			current_gui.queue_free()
	
	if Input.is_action_just_pressed("toggle_quests"):
		Globals.block_player_actions = true
		if not current_gui:
			current_gui = QUEST_GUI.instantiate()
			add_child(current_gui)
		elif not current_gui is QuestGUI:
			current_gui.queue_free()
			current_gui = QUEST_GUI.instantiate()
			add_child(current_gui)
		else:
			current_gui.queue_free()

func _on_open_crafting_gui() -> void:
	if not current_gui:
		current_gui = CRAFTING_GUI.instantiate() as CraftingGUI
		add_child(current_gui)
	elif not current_gui is CraftingGUI:
		current_gui.queue_free()
		current_gui = CRAFTING_GUI.instantiate() as CraftingGUI
		add_child(current_gui)

func _on_quest_added(runtime_quest: PPRuntimeQuest) -> void:
	var ui_notification : UINotification = UI_NOTIFICATION.instantiate()
	notification_container.add_child(ui_notification)
	ui_notification.show_up("New Quest", "Got new quest: %s" % runtime_quest.get_quest_name())

func _on_quest_completed(quest_id: String) -> void:
	var quest_completed := PPQuestManager.find_quest(quest_id)
	var quest_rewards := quest_completed.get_rewards()
	
	var reward_string = ""
	for quest_reward in quest_rewards:
		match quest_reward.get_reward_type():
			PPQuestReward.RewardType.ITEM:
				var reward_entity : PPItemEntity = quest_reward.get_reward_entity()
				if reward_entity:
					reward_string += "\n Item: x%d %s" % [quest_reward.get_quantity(), reward_entity.get_item_name()]
			PPQuestReward.RewardType.CURRENCY:
				reward_string += "\n Currency: %d gold" % quest_reward.get_currency_amount()
	
	var ui_notification : UINotification = UI_NOTIFICATION.instantiate()
	notification_container.add_child(ui_notification)
	ui_notification.show_up("Quest Completed", "Completed quest: %s\n\nRewads: %s" % [quest_completed.get_quest_name(), reward_string])

func _on_location_reach(location: PPLocationEntity) -> void:
	for quest in PPQuestManager.get_active_quests():
		var objectives : = quest.get_runtime_objectives()
		for i in range(objectives.size()):
			var obj_instance := objectives[i].get_quest_objective_instance()
			if obj_instance.get_objective_type() == PPObjectiveEntity.ObjectiveType.REACH_LOCATION:
				var target = obj_instance.get_target_reference().get_entity()
				if target.get_entity_id() == location.get_entity_id():
					objectives[i].complete()

func _on_notify(text: String) -> void:
	var ui_notification : UINotification = UI_NOTIFICATION.instantiate()
	notification_container.add_child(ui_notification)
	ui_notification.show_up("WARNING", text)
