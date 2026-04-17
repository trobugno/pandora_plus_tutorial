class_name CraftingGUI extends Control

@onready var ingredients_container: GridContainer = %IngredientsContainer
@onready var recipes_list: ItemList = %RecipesList
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var result_container: HBoxContainer = %ResultContainer
@onready var tip: Label = %Tip

@onready var recipe_slot: InventorySlot = %RecipeSlot

var current_inventory : PPInventory
var ingredients_inventory : PPInventory
var current_recipes : Array[PPRecipeEntity]
var selected_recipe : PPRecipeEntity

func _ready() -> void:
	modulate.a = 0
	position.y = 100
	ingredients_inventory = PPInventory.new(3)
	
	populate_player_inventory()
	populate_recipes()
	
	var animation_tween = get_tree().create_tween()
	animation_tween.parallel().tween_property(self, "position:y", 0, 0.5).set_delay(0.35)
	animation_tween.parallel().tween_property(self, "modulate:a", 1, 0.5).set_delay(0.35)

func _process(_delta: float) -> void:
	for index in range(recipes_list.item_count):
		var recipe := current_recipes[index]
		var can_craft := PPRecipeUtils.can_craft(PPPlayerManager.get_inventory(), recipe.get_recipe_property())
		recipes_list.set_item_disabled(index, !can_craft)

func populate_ingredients() -> void:
	for child in ingredients_container.get_children():
		var inventory_slot := child as InventorySlot
		inventory_slot.clear_slot()
		if inventory_slot.slot_clicked.has_connections():
			inventory_slot.slot_clicked.disconnect(_on_ingredient_clicked)
	
	for index in range(ingredients_inventory.all_items.size()):
		var inventory_item := ingredients_inventory.all_items[index]
		var inventory_slot := ingredients_container.get_child(index) as InventorySlot
		if inventory_item:
			inventory_slot.set_slot(inventory_item)
			inventory_slot.slot_clicked.connect(_on_ingredient_clicked)

func populate_recipes() -> void:
	var unlocked_recipes = PPPlayerManager.get_player_data().unlocked_recipes
	if selected_recipe:
		if not unlocked_recipes.has(selected_recipe.get_entity_id()):
			PPRecipeUtils.unlock_recipe(selected_recipe)
			unlocked_recipes.append(selected_recipe.get_entity_id())
	
	current_recipes = PPRecipeUtils.get_all_recipes().filter(func(r: PPRecipeEntity): return unlocked_recipes.has(r.get_entity_id()))
	recipes_list.clear()
	
	for index in range(current_recipes.size()):
		var recipe := current_recipes[index]
		var recipe_result := recipe.get_recipe_property().get_result()
		recipes_list.add_item(recipe_result.get_item_name())

func populate_player_inventory() -> void:
	current_inventory = PPPlayerManager.get_inventory()
	
	for child in inventory_grid.get_children():
		var inventory_slot := child as InventorySlot
		inventory_slot.clear_slot()
		if inventory_slot.slot_clicked.has_connections():
			inventory_slot.slot_clicked.disconnect(_on_slot_clicked)
	
	for index in range(current_inventory.all_items.size()):
		var inventory_item := current_inventory.all_items[index]
		var inventory_slot := inventory_grid.get_child(index) as InventorySlot
		if inventory_item:
			inventory_slot.set_slot(inventory_item)
			inventory_slot.slot_clicked.connect(_on_slot_clicked)

func _on_slot_clicked(slot: InventorySlot) -> void:
	var empty_slots := ingredients_container.get_children().filter(func(inv_slot: InventorySlot): \
		return inv_slot.slot == null)
	var ingredients_found := ingredients_container.get_children().filter(func(inv_slot: InventorySlot): \
		return inv_slot.slot and inv_slot.slot.get_item().get_entity_id() == slot.slot.get_item().get_entity_id())
	if not empty_slots and not ingredients_found:
		Globals.notify.emit("Impossible to add ingredient")
	
	PPInventoryUtils.transfer_items(current_inventory, ingredients_inventory, slot.slot.get_item(), 1)
	populate_player_inventory()
	populate_ingredients()
	
	for recipe in PPRecipeUtils.get_all_recipes():
		if PPRecipeUtils.can_craft(ingredients_inventory, recipe.get_recipe_property()):
			_configure_recipe_result(recipe)
			break

func _on_ingredient_clicked(slot: InventorySlot) -> void:
	PPInventoryUtils.transfer_items(ingredients_inventory, current_inventory, slot.slot.get_item(), 1)
	populate_player_inventory()
	populate_ingredients()
	
	var match_recipe : bool = false
	for recipe in PPRecipeUtils.get_all_recipes():
		if PPRecipeUtils.can_craft(ingredients_inventory, recipe.get_recipe_property()):
			match_recipe = true
	
	if not match_recipe:
		tip.show()
		result_container.hide()

func _on_recipes_list_item_selected(index: int) -> void:
	PPInventoryUtils.transfer_all(ingredients_inventory, current_inventory)
	
	var recipe := current_recipes[index]
	for inv_slot in recipe.get_recipe():
		PPInventoryUtils.transfer_items(current_inventory, ingredients_inventory, inv_slot.get_item(), inv_slot.quantity)
	
	populate_player_inventory()
	populate_ingredients()
	_configure_recipe_result(recipe)

func _configure_recipe_result(recipe: PPRecipeEntity) -> void:
	selected_recipe = recipe
	var recipe_inv_slot := PPInventorySlot.new()
	recipe_inv_slot.set_item_from(recipe.get_recipe_property().get_result())
	recipe_slot.set_slot(recipe_inv_slot)
	
	tip.hide()
	result_container.show()

func _on_craft_button_pressed() -> void:
	PPRecipeUtils.craft_recipe(ingredients_inventory, selected_recipe.get_recipe_property())
	PPInventoryUtils.transfer_all(ingredients_inventory, current_inventory)
	
	populate_player_inventory()
	populate_ingredients()
	populate_recipes()
	
	tip.show()
	result_container.hide()

func close_gui() -> void:
	var animation_tween = get_tree().create_tween()
	animation_tween.parallel().tween_property(self, "position:y", 100, 0.5)
	animation_tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	
	PPInventoryUtils.transfer_all(ingredients_inventory, current_inventory)
	await animation_tween.finished
	queue_free()
