extends Area2D

@export var Name = "item"
@export var Count = 0
@export var damage = 6

func _ready():
	add_to_group("Item")
	print(get_groups())
