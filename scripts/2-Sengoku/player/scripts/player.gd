class_name player
extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var move_speed : float = 150.0
var state : String = "idle"

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	state = "idle"
	update_animation()

func _physics_process(delta):
	# อ่านอินพุต
	direction = Input.get_vector("left", "right", "up", "down")
	
	# กำหนด state
	if direction.length() > 0.0:
		state = "walk"
		update_cardinal(direction)
	else:
		state = "idle"
	
	# เคลื่อนที่
	var move_dir = direction.normalized() if direction.length() > 0.0 else Vector2.ZERO
	velocity = move_dir * move_speed
	move_and_slide()
	
	# อัปเดต animation
	update_animation()

func update_cardinal(vec: Vector2) -> void:
	# แยกทิศตามแกนที่เด่นกว่า
	if abs(vec.x) > abs(vec.y):
		cardinal_direction = Vector2.RIGHT if vec.x > 0.0 else Vector2.LEFT
	else:
		cardinal_direction = Vector2.DOWN if vec.y > 0.0 else Vector2.UP

func dir_suffix() -> String:
	# ชุดคลิปมี up/down/side เท่านั้น
	if cardinal_direction == Vector2.UP:
		return "up"
	if cardinal_direction == Vector2.DOWN:
		return "down"
	return "side"  # ใช้ร่วมทั้งซ้ายและขวา

func update_animation() -> void:
	# เมื่อ idle ให้ reset flip_h กลับเป็นปกติ
	if state == "idle":
		sprite.flip_h = false
	elif cardinal_direction == Vector2.LEFT:
		sprite.flip_h = true
	elif cardinal_direction == Vector2.RIGHT:
		sprite.flip_h = false
	
	# สร้างชื่อ animation
	var anim_name = "%s_%s" % [state, dir_suffix()]   # เช่น "walk_side", "idle_down"
	
	# เล่น animation ถ้าไม่ใช่ animation เดิม
	if animation_player.current_animation != anim_name:
		if animation_player.has_animation(anim_name):
			animation_player.play(anim_name)
		else:
			# fallback ถ้าไม่เจอ animation
			if animation_player.has_animation("idle_down"):
				animation_player.play("idle_down")

# เก็บฟังก์ชัน debug ไว้สำหรับทดสอบ
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
