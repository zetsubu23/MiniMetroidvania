extends CharacterBody2D

var movement = Vector2()
var canMove = true
var isAnimating = false
var attack = false
var isDead = false
var isHitted = true

signal hit(damage)
signal death

var currentDirection = 0
@onready var wave = preload("res://Scenes/Wave.tscn")

func _ready():
	add_to_group("Player")
	if isHitted:
		canMove = false
		emit_signal("hit", 5)
		$HitArea/HitCollision.disabled = true
		$CharacterAnim.play("hurt")
		await $CharacterAnim.animation_finished
		canMove = true
		await get_tree().create_timer(10).timeout
		$HitArea/HitCollision.disabled = false
		isHitted = false
	
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

func animation():

	if currentDirection == -1 and is_on_floor() and !attack and !isDead:
		$CharacterAnim.flip_h = true
		$CharacterAnim.animation = "walking"


	if currentDirection == 1 and is_on_floor() and !attack and !isDead:
		$CharacterAnim.flip_h = false
		$CharacterAnim.animation = "walking"
	
#
	if !is_on_floor() and !attack and !isDead:
		$CharacterAnim.animation = "jumping"
		
	if movement == Vector2.ZERO and is_on_floor() and !attack and !isDead:
		$CharacterAnim.animation = "idle"
	
	$CharacterAnim.play()
	
	if attack and !isDead:
		$CharacterAnim.play("attack")
		await $CharacterAnim.animation_finished
		if currentDirection == 1:
			$CharacterAnim.flip_h = false
		else:
			$CharacterAnim.flip_h = true
		attack = false
	
	if PlayerState.health <= 0 and !isDead:
		canMove = false
		$CharacterAnim.play("death")
		await $CharacterAnim.animation_finished
		emit_signal("death")
	
func player_movement(delta):
	
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var jump = Input.is_action_just_pressed("ui_accept")
	
	movement.x = -int(left) + int(right)
	movement.y = -int(jump)
	currentDirection = movement.x
	
	if jump and is_on_floor():
		PlayerState.fall_velocity -= PlayerState.jump_height
		
	if PlayerState.haveShield and Input.is_action_just_pressed("down") and is_on_floor():
		velocity = Vector2.ZERO
		movement = Vector2.ZERO
		canMove = false
		$HitArea/HitCollision.disabled = true
		$CharacterAnim.play("pray")
		await $CharacterAnim.animation_finished
		canMove = true
		$HitArea/HitCollision.disabled = false
		
	if PlayerState.canRoll and Input.is_action_just_pressed("roll") \
	and movement.x != 0 and currentDirection != 0 and is_on_floor():
		
		canMove = false
		currentDirection = 2
		$HitArea/HitCollision.disabled = true
		$RegullarCollision.disabled = true
		
		$CharacterAnim.play("rolling")
		
		await $CharacterAnim.animation_finished
	
		if velocity.x > 0:
			currentDirection = 1
		elif velocity.x < 0:
			currentDirection = -1
		else:
			currentDirection = 0
		
		$HitArea/HitCollision.disabled = false
		$RegullarCollision.disabled = false
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
	if body.is_in_group("Enemy") and !isHitted:
		canMove = false
		emit_signal("hit", 5)
		$HitArea/HitCollision.disabled = true
		$CharacterAnim.play("hurt")
		await $CharacterAnim.animation_finished
		canMove = true
		await get_tree().create_timer(10).timeout
		$HitArea/HitCollision.disabled = false
		isHitted = false
