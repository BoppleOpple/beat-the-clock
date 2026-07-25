class_name Player
extends ActorBase

#############
# CONSTANTS #
#############

const JOYSTICK_DEADZONE: float = 0.2

###########
# METHODS #
###########

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	GameManager.player_ref = self

func _on_kill() -> void:
	emit_signal("respawn")

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
	if GameManager.current_device == GameManager.InputDevice.CONTROLLER:
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

signal respawn()
