class_name QuestGUI extends Control

@onready var quests_list: ItemList = %QuestsList
@onready var quest_name: Label = %QuestName
@onready var quest_status: Label = %QuestStatus
@onready var quest_description: Label = %QuestDescription
@onready var objectives: GridContainer = %ObjectivesGrid
@onready var rewards: GridContainer = %RewardsGrid
@onready var quest_details: MarginContainer = %QuestDetails

var quests : Array[PPRuntimeQuest] = []

func _ready() -> void:
	quest_details.hide()
	quests_list.clear()
	quests.clear()
	
	for child in objectives.get_children():
		child.queue_free()
	
	for child in rewards.get_children():
		child.queue_free()
	
	quests.append_array(PPQuestManager.get_active_quests())
	quests.append_array(PPQuestManager.get_completed_quests())
	quests.append_array(PPQuestManager.get_failed_quests())
	
	for quest in quests:
		quests_list.add_item(quest.get_quest_name())

func _on_quests_list_item_selected(index: int) -> void:
	for child in objectives.get_children():
		child.queue_free()
	for child in rewards.get_children():
		child.queue_free()
	
	var current_quest := quests[index]
	quest_name.text = current_quest.get_quest_name()
	quest_description.text = current_quest.get_description()
	quest_status.hide()
	
	if current_quest.get_quest_status() == PPRuntimeQuest.QuestStatus.COMPLETED:
		quest_status.text = "Completed"
		quest_status.show()
	elif current_quest.get_quest_status() == PPRuntimeQuest.QuestStatus.FAILED:
		quest_status.text = "Failed"
		quest_status.show()
	
	for quest_obj in current_quest.get_runtime_objectives():
		var label = Label.new()
		label.text = quest_obj.get_display_text()
		label.add_theme_color_override("font_color", Color.DARK_GRAY)
		label.add_theme_font_size_override("font_size", 9)
		objectives.add_child(label)
	
	for quest_reward in current_quest.get_rewards():
		match quest_reward.get_reward_type():
			PPQuestReward.RewardType.ITEM:
				var reward_entity: PPItemEntity = quest_reward.get_reward_entity()
				if reward_entity:
					var label = Label.new()
					label.text = "x%d %s" % [quest_reward.get_quantity(), reward_entity.get_item_name()]
					label.add_theme_color_override("font_color", Color.DARK_GRAY)
					label.add_theme_font_size_override("font_size", 9)
					rewards.add_child(label)
			PPQuestReward.RewardType.CURRENCY:
				var label = Label.new()
				label.text = "%d gold" % quest_reward.get_currency_amount()
				label.add_theme_color_override("font_color", Color.DARK_GRAY)
				label.add_theme_font_size_override("font_size", 9)
				rewards.add_child(label)
	
	quest_details.show()
