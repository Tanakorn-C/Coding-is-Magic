class_name Player
extends CharacterBody2D

@export var move_speed: float = 100.0
@export var run_multiplier: float = 2.0
@export var stamina_max: float = 100.0
@export var stamina_recover: float = 20.0   # per second
@export var stamina_cost: float = 35.0      # per second while running

var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var state: String = "idle"   # "idle" | "walk" | "run"
var stamina: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_walk = $sfx_walk
@onready var sfx_run = $sfx_run
func _ready() -> void:
	stamina = stamina_max
	state = "idle"
	_update_animation()

func _process(delta: float) -> void:
	# อ่านอินพุตที่นี่ (ไว) แต่เลื่อนตัวใน _physics_process
	direction = Input.get_vector("left", "right", "up", "down")
	var want_run := Input.is_action_pressed("run") and stamina > 0.0 and direction != Vector2.ZERO

	if direction.length() > 0.0:
		state = "run" if want_run else "walk"
		_update_cardinal(direction)
	else:
		state = "idle"

	# จัดการสตามินา
	if state == "run":
		stamina = max(0.0, stamina - stamina_cost * delta)
	else:
		stamina = min(stamina_max, stamina + stamina_recover * delta)
		
	if state == "walk":
		if sfx_run.playing: #stop sfx_run 
			sfx_run.stop()  
		if not sfx_walk.playing:
			sfx_walk.play()
	elif state == "run":
		if sfx_walk.playing: #stop sfx_walk
			sfx_walk.stop()
		if not sfx_run.playing:
			sfx_run.play()
	else: #idle
		if sfx_walk.playing:
			sfx_walk.stop()
		if sfx_run.playing: 
			sfx_run.stop()

func _physics_process(_delta: float) -> void:
	var move_dir := direction.normalized() if direction.length() > 0.0 else Vector2.ZERO
	var speed := move_speed * (run_multiplier if state == "run" else 1.0)
	velocity = move_dir * speed
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
	if cardinal_direction == Vector2.LEFT:
		sprite.flip_h = true
	elif cardinal_direction == Vector2.RIGHT:
		sprite.flip_h = false
	# up/down จะคงค่าจากก่อนหน้า หรือจะบังคับปิดก็ได้

	var base := (state if state != "run" else "walk")  # ถ้ายังไม่มีแอนิเมชัน run ให้ใช้ walk แทน
	var anim_name := "%s_%s" % [base, _dir_suffix()]   # เช่น "walk_side", "idle_up"
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
