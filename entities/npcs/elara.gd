extends NPC

func interact() -> void:
	super.interact()
	Globals.open_crafting_gui.emit()
