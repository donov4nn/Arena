extends CharacterBody2D

var jump_count = 0
var is_wall_sliding = false
var last_wall = null
var can_dash = true
var can_trigger_power_1 = true
var fire_node = preload("res://scenes/powers/fire_power.tscn")
var fire_ball = null
var dash_timer = null
var power_1_timer = null
@onready var dash_progress_bar = $Layout/DashProgressBar
@onready var power_one_progress_bar = $Layout/PowerOneProgressBar
const character_constants = preload("res://scripts/character/character_constants.gd")
const timer_util = preload("res://scripts/utils/timer_util.gd")

func _ready():
	timer_util.new()

func _physics_process(delta):		
	layout()
	power()
	var input_dir : Vector2 = input()
	
	if input_dir != Vector2.ZERO:
		accelerate(input_dir)
	else:
		add_friction()	
		
	move_and_slide()
	jump()
	wall_slide(delta)
	dash()
	
	if is_on_floor():
		last_wall = null
		jump_count = 0

func accelerate(direction):
	velocity = velocity.move_toward(character_constants.speed * direction, character_constants.accuracy)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, character_constants.friction)
	
func input():
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("left", "right")
	input_dir = input_dir.normalized()
	
	return input_dir

func jump():
	velocity.y += character_constants.gravity
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or jump_count < character_constants.extra_jump:
			velocity.y = character_constants.jump_power
			jump_count += 1
			return
			
		if is_on_wall() and is_wall_sliding: 
			if last_wall == get_wall_normal():
				return
			
			last_wall = get_wall_normal()
			velocity.y = character_constants.wall_jump_power
			
			if Input.is_action_pressed("left"):
				velocity.x = character_constants.wall_jump_pushback
			if Input.is_action_pressed("right"):
				velocity.x = -character_constants.wall_jump_pushback

func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
		
	if is_wall_sliding:
		velocity.y += (character_constants.wall_slide_gravity * delta)
		velocity.y = min(velocity.y, character_constants.wall_slide_gravity)
		
func dash():
	if Input.is_action_just_pressed("dash") and can_dash:
		var dash_direction = Vector2(Input.get_axis("left", "right"), 0)
		velocity = dash_direction.normalized() * character_constants.dash_power
		can_dash = false
		dash_timer = create_timer_with_callback(1, handle_dash_timer_time_out)

func handle_dash_timer_time_out():
	if dash_timer != null:
		dash_timer = null
		
	can_dash = true

func power():
	if Input.is_action_just_pressed("power_1") and can_trigger_power_1:
		handle_power_1()
#	
func handle_power_1():
	can_trigger_power_1 = false
	fire_ball = fire_node.instantiate()
	get_parent().add_child(fire_ball)
	power_1_timer = create_timer_with_callback(2, handle_power_1_destroy)

func create_timer_with_callback(duration, end_callback, wait_callback = null):
	var timer = get_tree().create_timer(duration)
	timer.connect("timeout", end_callback)
	return timer

func handle_power_1_destroy():
	if fire_ball != null:
		fire_ball.queue_free()
		fire_ball = null
		
	if power_1_timer != null:
		power_1_timer = null 
		
	can_trigger_power_1 = true
	
func layout():
	pass
#	if dash_progress_bar != null:
#		dash_progress_bar.value = 50
#	dash_progress_bar.value = timer_util.calcul_percent(dash_timer)
#	dash_cd_layout.text = ("Dash CD : " + format_time(dash_timer.time_left)) if dash_timer != null else ""
#	power_1_cd_layout.text = ("Power 1 CD : " + format_time(power_1_timer.time_left)) if power_1_timer != null else ""

func format_time(total_seconds):
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hours:  int   =  int(total_seconds / 3600.0)
	if hours != 0:
		return "%02d:%02d:%05.2f" % [hours, minutes, seconds]
	elif minutes != 0:
		return "%02d:%05.2f" % [minutes, seconds]
	else:
		return "%05.2f" % seconds
		
