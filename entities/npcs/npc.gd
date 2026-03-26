class_name NPC extends CharacterBody2D

@export var npc_entity: PPNPCEntity
@export var location_entity: PPLocationEntity
@onready var label: Label = $NPCName

var runtime_npc : PPRuntimeNPC

func _ready() -> void:
	runtime_npc = PPNPCManager.spawn_npc(npc_entity, location_entity)

func show_name() -> void:
	label.show()

func hide_name() -> void:
	label.hide()

func interact() -> void:
	var active_quests := PPQuestManager.get_active_quests()
	PPNPCUtils.track_npc_interaction(active_quests, npc_entity)
	
	var available_quests := runtime_npc.get_available_quests(PPQuestManager.get_completed_quest_ids())
	if available_quests:
		PPQuestManager.start_quest(available_quests[0])
