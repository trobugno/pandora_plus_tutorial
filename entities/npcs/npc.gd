class_name NPC extends CharacterBody2D

@export var dialogue_timeline: DialogicTimeline
@export var npc_entity: PPNPCEntity
@export var location_entity: PPLocationEntity
@onready var label: Label = $NPCName

var runtime_npc : PPRuntimeNPC

func _ready() -> void:
	runtime_npc = PPNPCManager.spawn_npc(npc_entity, location_entity)
	Dialogic.signal_event.connect(_on_dialogic_signal_event)

func show_name() -> void:
	label.show()

func hide_name() -> void:
	label.hide()

func interact() -> void:
	var completed_quest_ids := PPQuestManager.get_completed_quest_ids()
	for quest_id in completed_quest_ids:
		if Dialogic.VAR.get_variable("{Quests.%s}" % quest_id) != 2:
			Dialogic.VAR.set_variable("{Quests.%s}" % quest_id, 2)
	
	var active_quests := PPQuestManager.get_active_quests()
	PPNPCUtils.track_npc_interaction(active_quests, npc_entity)
	
	if dialogue_timeline:
		Dialogic.start(dialogue_timeline)

func _on_dialogic_signal_event(argument: Variant) -> void:
	if argument is Dictionary:
		if argument.has("npc_name") and argument.get("npc_name") == npc_entity.get_npc_name():
			if argument.has("start_quest"):
				var quest_id : String = argument.get("start_quest")
				
				var available_quests := runtime_npc.get_available_quests(PPQuestManager.get_completed_quest_ids())
				var matched_quests := available_quests.filter(func(quest: PPQuestEntity): return quest.get_quest_id() == quest_id)
				PPQuestManager.start_quest(matched_quests[0])
