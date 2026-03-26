class_name LocationArea
extends Area2D

signal location_reach(location: PPLocationEntity)

@export var location : PPLocationEntity

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.current_location and body.current_location != location:
			body.current_location = location
			location_reach.emit(location)
