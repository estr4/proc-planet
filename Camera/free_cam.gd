class_name FreeCam extends Camera3D

@export var toggle_key: Key = KEY_TAB
@export var overlay_text: bool = true
@onready var pivot := Node3D.new()
@onready var screen_overlay := VBoxContainer.new()
@onready var event_log := VBoxContainer.new()

const MAX_SPEED := 6
const MIN_SPEED := 0.2
const ACCELERATION := 5.0
const MOUSE_SENSITIVITY := 0.2

func expdec(from, to, decay, delta):
	return to + (from - to) * exp(-decay * delta)

var movement_active := false:
	set(val):
		movement_active = val
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if movement_active else Input.MOUSE_MODE_VISIBLE)
		display_message("[Movement ON]" if movement_active else "[Movement OFF]")


var target_speed := MIN_SPEED
var velocity := Vector3.ZERO

func setup_nodes() -> void:
	self.add_sibling(pivot)
	pivot.position = position
	pivot.rotation = rotation
	self.reparent(pivot)
	self.position = Vector3.ZERO
	self.rotation = Vector3.ZERO
	# UI stuff
	screen_overlay.add_theme_constant_override("Separation", 8)
	self.add_child(screen_overlay)
	screen_overlay.add_child(make_label("Debug Camera"))
	screen_overlay.add_spacer(false)
	
	screen_overlay.add_child(event_log)
	screen_overlay.visible = overlay_text


func _ready() -> void:
	setup_nodes.call_deferred()

func _process(delta: float) -> void:
	if Input.is_action_just_released("__debug_camera_toggle"):
		movement_active = not movement_active
	
	if movement_active:
		var dir = Vector3.ZERO
		if Input.is_action_pressed("__debug_camera_forward"): 	dir.z -= 1
		if Input.is_action_pressed("__debug_camera_back"): 		dir.z += 1
		if Input.is_action_pressed("__debug_camera_left"): 		dir.x -= 1
		if Input.is_action_pressed("__debug_camera_right"): 	dir.x += 1
		if Input.is_action_pressed("__debug_camera_up"): 		dir.y += 1
		if Input.is_action_pressed("__debug_camera_down"): 		dir.y -= 1
		
		dir = dir.normalized()
		dir = dir.rotated(Vector3.UP, pivot.rotation.y)
		
		velocity = expdec(velocity, dir * target_speed, ACCELERATION, delta)
		pivot.position += velocity


func _input(event: InputEvent) -> void:
	if movement_active:
		if event is InputEventMouseMotion:
			pivot.rotate_y(-event.relative.x * MOUSE_SENSITIVITY * get_physics_process_delta_time())
			rotate_x(-event.relative.y * MOUSE_SENSITIVITY * get_physics_process_delta_time())
			rotation.x = clamp(rotation.x, -PI/2, PI/2)

		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				target_speed = clamp(target_speed + 0.1, MIN_SPEED, MAX_SPEED)
				display_message("[Speed up] " + str(target_speed))
				
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				target_speed = clamp(target_speed - 0.1, MIN_SPEED, MAX_SPEED)
				display_message("[Slow down] " + str(target_speed))

func display_message(text: String) -> void:
	while event_log.get_child_count() >= 3:
		event_log.remove_child(event_log.get_child(0))
	
	event_log.add_child(make_label(text))

func make_label(text: String) -> Label:
	var l = Label.new()
	l.text = text
	return l
