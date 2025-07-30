extends CharacterBody2D

@export var SPEED = 250
@export var JUMP_VELOCITY = -225

@onready var savemenu : Control = $UI/SaveMenu
@onready var pausemenu : Control = $UI/Control

var inside_detector = false

signal break_block

func _ready():
	GameManager.player = self
	global_position = GameManager.player_spawn_position
	savemenu.visible = false
	pausemenu.visible = false

func _physics_process(delta: float) -> void:
	if inside_detector == true:
		pass
	
	update_input()
	update_gravity(delta)

func update_gravity(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) 

	move_and_slide()

func update_input():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("ESC"):
		pausemenu.visible = !pausemenu.visible
	
	if Input.is_action_just_pressed("LMB"):
		break_block.emit()

func _on_mouse_detector_mouse_entered():
	print("true")
	inside_detector = true

func _on_mouse_detector_mouse_exited():
	inside_detector = false

func _on_menu_button_pressed() -> void:
	savemenu.visible = true
