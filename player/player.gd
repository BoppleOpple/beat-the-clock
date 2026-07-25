class_name Player
extends ActorBase

#############
# CONSTANTS #
#############

const JOYSTICK_DEADZONE: float = 0.2

###########
# GLOBALS #
###########

enum InputDevice { KEYBOARD_MOUSE, CONTROLLER }
var current_device := InputDevice.KEYBOARD_MOUSE

###########
# METHODS #
###########

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timers/PlayerClock.start(GameManager.PLAYER_MAX_TIME / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var frame_actions: Actions = Actions.new()
	
	frame_actions.move_x = Input.get_axis("gameplay_left", "gameplay_right")
	frame_actions.jump = Input.is_action_just_pressed("gameplay_jump")
	frame_actions.slow_fall = Input.is_action_pressed("gameplay_jump")
	frame_actions.ability_1 = Input.is_action_just_pressed("gameplay_ability_left")
	frame_actions.ability_2 = Input.is_action_just_pressed("gameplay_ability_middle")
	frame_actions.ability_3 = Input.is_action_just_pressed("gameplay_ability_right")
	frame_actions.ability_combo = Input.is_action_just_pressed("gameplay_ability_combo")
	
	_apply_actions(frame_actions, delta)

func get_aim_direction() -> Vector2:
	if current_device == InputDevice.CONTROLLER:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		var vector = Input.get_vector("gameplay_aim_left", "gameplay_aim_right", "gameplay_aim_up", "gameplay_aim_down")
		if vector.length() > JOYSTICK_DEADZONE:
			return vector.normalized()
		else:
			vector = Input.get_vector("gameplay_left", "gameplay_right", "gameplay_up", "gameplay_down")
			if vector.length() > JOYSTICK_DEADZONE:
				return vector.normalized()
			return Vector2.ZERO
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return (get_global_mouse_position() - self.position).normalized()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		current_device = InputDevice.KEYBOARD_MOUSE
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		current_device = InputDevice.CONTROLLER

####################
# INCOMING SIGNALS #
####################

func _on_jump_collision_nearby_body_entered(body: Node2D) -> void:
	super(body)

func _on_jump_collision_below_body_exited(body: Node2D) -> void:
	super(body)

func _on_coyote_timer_timeout() -> void:
	super()

func _on_slash_startup_delay_timeout() -> void:
	super()

func _on_sword_slash_animation_finished() -> void:
	super()

func _on_slash_collision_body_entered(body: Node2D) -> void:
	super(body)
	
func _on_player_clock_timeout() -> void:
	super()
