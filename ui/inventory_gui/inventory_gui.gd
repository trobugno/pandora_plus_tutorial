class_name InventoryGUI extends Control

@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var load_button: Button = %LoadButton
@onready var currency: Label = %Currency

var current_inventory : PPInventory
var current_scene_node : Node : set = set_current_scene_node

func _ready() -> void:
	current_inventory = PPPlayerManager.get_inventory()
	currency.text = "%d gold" % PPPlayerManager.get_currency()
	
	for index in range(current_inventory.all_items.size()):
		var inventory_item := current_inventory.all_items[index]
		var inventory_slot := inventory_grid.get_child(index) as InventorySlot
		if inventory_item:
			inventory_slot.set_slot(inventory_item)

func _process(_delta: float) -> void:
	if PPSaveManager.get_save_slot(1):
		load_button.disabled = false
	else:
		load_button.disabled = true

func _on_save_button_pressed() -> void:
	PPSaveManager.save_game(1)

func _on_load_button_pressed() -> void:
	current_scene_node.get_tree().reload_current_scene()

func set_current_scene_node(node: Node) -> void:
	current_scene_node = node
