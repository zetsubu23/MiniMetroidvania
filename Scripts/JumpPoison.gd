extends "res://Scripts/item.gd"



func _on_body_entered(body):
	if body.is_in_group("Player"):
		PlayerState.inventory[self.Name] = self
		PlayerState.jump_height *= 1.2
		queue_free()
