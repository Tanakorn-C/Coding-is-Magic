class_name Player
extends CharacterBody2D

@export var move_speed: float = 100.0
var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var state := "idle"  # "idle" | "walk"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	state = "idle"
	_update_animation()

func _process(_delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	if direction.length() > 0.0:
		state = "walk"
		_update_cardinal(direction)
	else:
		state = "idle"

func _physics_process(_delta: float) -> void:
	var move_dir := direction.normalized() if direction.length() > 0.0 else Vector2.ZERO
	velocity = move_dir * move_speed
	move_and_slide()
	_update_animation()

func _update_cardinal(vec: Vector2) -> void:
	# แยกทิศตามแกนที่เด่นกว่า
	if absf(vec.x) > absf(vec.y):
		cardinal_direction = Vector2.RIGHT if vec.x > 0.0 else Vector2.LEFT
	else:
		cardinal_direction = Vector2.DOWN if vec.y > 0.0 else Vector2.UP

func _dir_suffix() -> String:
	# ชุดคลิปมี up/down/side เท่านั้น
	if cardinal_direction == Vector2.UP:
		return "up"
	if cardinal_direction == Vector2.DOWN:
		return "down"
	return "side"  # ใช้ร่วมทั้งซ้ายและขวา

func _update_animation() -> void:
	# ตั้ง flip_h ให้ถูกก่อน แล้วค่อยเล่นคลิป
	# ขวา = ไม่พลิก, ซ้าย = พลิก, ขึ้น/ลง = แล้วแต่จะชอบ (ส่วนใหญ่ไม่พลิก)
	if cardinal_direction == Vector2.LEFT:
		sprite.flip_h = true
	elif cardinal_direction == Vector2.RIGHT:
		sprite.flip_h = false
	# ถ้าเป็น up/down จะคงค่าจากครั้งก่อน หรือจะบังคับปิดก็ได้:
	# else:
	#     sprite.flip_h = false
	# 3
	var anim_name := "%s_%s" % [state, _dir_suffix()]  # เช่น "walk_side", "idle_up"
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
