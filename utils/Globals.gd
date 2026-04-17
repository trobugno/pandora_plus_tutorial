extends Node

signal location_reach(location: PPLocationEntity)
signal open_crafting_gui
signal notify(text: String)

var block_player_actions : bool = false

func open_crafting_gui_from_dialogue() -> void:
	open_crafting_gui.emit()
