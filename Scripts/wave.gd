extends Area2D

var speed = 10
@export var damage = 6
var movement = Vector2()
@export var direction = 1
var life_time = 0

func _ready():
	add_to_group("Enemy")

func _physics_process(delta):
	
	life_time += 1
	
	movement.x = speed * delta * direction
	
	translate(movement.normalized() * speed)
	
	if life_time >= 100:
		queue_free()

func check_direction(dir):
	if dir == -1:
		$AnimatedSprite2D.flip_h = true
	direction = dir

func _on_body_entered(body):
	if body.name != "Player":
		queue_free()
	
