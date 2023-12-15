extends CharacterBody2D

var movement = Vector2()
var canMove = true
var isAnimating = false
var attack = false

signal hit(damage)

var currentDirection = 0
@onready var wave = preload("res://Scenes/Wave.tscn")

func _ready():
	add_to_group("Player")
	
func _physics_process(delta):
	current_gravity()
	
	if canMove:
		player_movement(delta)
	
	if !attack and canMove and Input.is_action_just_pressed("attack"):
		check_attack()
		
	if canMove:
		animation()
	
	velocity.x = movement.x * PlayerState.speed
	
	movement = movement.normalized() * PlayerState.speed * delta
	move_and_slide()

func _process(delta):
	pass

func animation():

	if currentDirection == -1 and is_on_floor() and !attack:
		$CharacterAnim.flip_h = true
		$CharacterAnim.animation = "walking"


	if currentDirection == 1 and is_on_floor() and !attack:
		$CharacterAnim.flip_h = false
		$CharacterAnim.animation = "walking"
	
#
	if !is_on_floor() and !attack:
		$CharacterAnim.animation = "jumping"
		
	if movement == Vector2.ZERO and is_on_floor() and !attack:
		$CharacterAnim.animation = "idle"
	
	$CharacterAnim.play()
	
	if attack:
		$CharacterAnim.play("attack")
		await $CharacterAnim.animation_finished
		attack = false
	
func player_movement(delta):
	
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var jump = Input.is_action_just_pressed("ui_accept")
	
	movement.x = -int(left) + int(right)
	movement.y = -int(jump)
	currentDirection = movement.x
	
	if jump and is_on_floor():
		PlayerState.fall_velocity -= PlayerState.jump_height
		
	if PlayerState.canRoll and Input.is_action_just_pressed("down") and movement.x != 0 and currentDirection != 0:
		
		canMove = false
		currentDirection = 2
		$HitArea/HitCollision.disabled = true
		
		$CharacterAnim.play("rolling")
		
		await $CharacterAnim.animation_finished
	
		if velocity.x > 0:
			currentDirection = 1
		elif velocity.x < 0:
			currentDirection = -1
		else:
			currentDirection = 0
		
		$HitArea/HitCollision.disabled = true
		canMove = true

func current_gravity():
	
	velocity.y = PlayerState.fall_velocity
	
	if !is_on_floor():
		PlayerState.fall_velocity += PlayerState.gravity_force
		
	if is_on_floor() and PlayerState.fall_velocity > 5:
		PlayerState.fall_velocity = 5
	

	if PlayerState.fall_velocity >= PlayerState.terminal_velocity:
		PlayerState.fall_velocity = PlayerState.terminal_velocity

func check_attack():
	attack = true
	var wave_projectile = wave.instantiate()
	wave_projectile.position = $RightMarker.global_position
	if $CharacterAnim.flip_h == true:
		wave_projectile.position = $LeftMarker.global_position
		wave_projectile.check_direction(-1)
	get_parent().add_child(wave_projectile)



func _on_hit_area_body_entered(body):
	if body.is_in_group("Enemy"):
		emit_signal("hit", body.damage)
	if body.is_in_group("Item"):
		print(body)
		emit_signal("hit", body.damage)
