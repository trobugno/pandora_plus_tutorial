class_name InventorySlot extends Panel

signal slot_clicked(slot: InventorySlot)

@export var slot : PPInventorySlot : set = set_slot

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func set_slot(inv_slot: PPInventorySlot) -> void:
	texture_rect.texture = inv_slot.get_item().get_texture()
	if inv_slot.quantity > 0:
		label.text = "x%d" % inv_slot.quantity
		label.show()
	slot = inv_slot

func set_quantity(quantity: int) -> void:
	slot.quantity = quantity
	
	if quantity == 0:
		clear_slot()
	else:
		label.text = "x%d" % quantity

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_pressed():
		slot_clicked.emit(self)

func clear_slot() -> void:
	texture_rect.texture = null
	label.hide()
