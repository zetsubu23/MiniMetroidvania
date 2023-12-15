extends Node2D


func _on_player_hit(damage):
	print(damage)
	PlayerState.health -= damage
	print(PlayerState.health)
