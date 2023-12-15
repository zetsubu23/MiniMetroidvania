extends "res://Scripts/item.gd"



func _on_body_entered(body):
	if body.is_in_group("Player"):
		PlayerState.inventory[self.Name] = self
		PlayerState.canRoll = true
		queue_free()
