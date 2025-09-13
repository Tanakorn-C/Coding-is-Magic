class_name player
extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var move_speed : float = 150.0
var state : String = "idle"

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	print("=== PLAYER DEBUG INFO ===")
	print("AnimationPlayer node: ", animation_player)
	print("Sprite2D node: ", sprite)
	
	if animation_player:
		print("Available animations:")
		var anims = animation_player.get_animation_list()
		for anim in anims:
			print("- ", anim)
		print("Total animations: ", anims.size())
	else:
		print("ERROR: AnimationPlayer not found!")
	
	print("=========================")

func _physics_process(delta):
	# Debug input
	var input_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var input_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	print("Raw input - X: ", input_x, " Y: ", input_y)
	
	direction = Vector2(input_x, input_y)
	print("Direction: ", direction)
	
	velocity = direction.normalized() * move_speed
	print("Velocity: ", velocity)
	
	# อัพเดท direction และ state
	var direction_changed = SetDirection()
	var state_changed = SetState()
	
	print("Direction changed: ", direction_changed, " State changed: ", state_changed)
	print("Current state: ", state, " Cardinal direction: ", cardinal_direction)
	
	if state_changed:
		UpdateAnimation()
	
	move_and_slide()

func SetDirection() -> bool:
	if direction != Vector2.ZERO:
		var old_direction = cardinal_direction
		
		if abs(direction.y) > abs(direction.x):
			cardinal_direction = Vector2.DOWN if direction.y > 0 else Vector2.UP
		else:
			cardinal_direction = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
		
		# Flip sprite for side movement
		if cardinal_direction == Vector2.LEFT:
			sprite.flip_h = true
		elif cardinal_direction == Vector2.RIGHT:
			sprite.flip_h = false
		
		print("Direction change - Old: ", old_direction, " New: ", cardinal_direction)
		return old_direction != cardinal_direction
	
	return false

func SetState() -> bool:
	var old_state = state
	state = "idle" if direction == Vector2.ZERO else "walk"
	
	print("State change - Old: ", old_state, " New: ", state)
	return old_state != state

func UpdateAnimation() -> void:
	var anim_name = state + "_" + AnimDirection()
	print("*** TRYING TO PLAY ANIMATION: ", anim_name, " ***")
	
	if not animation_player:
		print("ERROR: AnimationPlayer is null!")
		return
	
	if animation_player.has_animation(anim_name):
		print("SUCCESS: Animation found, playing...")
		animation_player.play(anim_name)
		print("Current animation: ", animation_player.current_animation)
		print("Is playing: ", animation_player.is_playing())
	else:
		print("ERROR: Animation '", anim_name, "' not found!")
		print("Available animations: ", animation_player.get_animation_list())
		
		# Try fallback
		if animation_player.has_animation("idle_down"):
			print("Using fallback: idle_down")
			animation_player.play("idle_down")

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.LEFT or cardinal_direction == Vector2.RIGHT:
		return "side"
	else:
		return "down"

# เพิ่มฟังก์ชัน debug เพื่อทดสอบ animation โดยตรง
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				test_animation("idle_down")
			KEY_2:
				test_animation("idle_up")
			KEY_3:
				test_animation("idle_side")
			KEY_4:
				test_animation("walk_down")
			KEY_5:
				test_animation("walk_up")
			KEY_6:
				test_animation("walk_side")

func test_animation(anim_name: String):
	print("=== TESTING ANIMATION: ", anim_name, " ===")
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		print("Played successfully!")
	else:
		print("Failed to play!")
