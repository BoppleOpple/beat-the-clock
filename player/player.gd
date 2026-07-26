class_name Player
extends ActorBase

#############
# CONSTANTS #
#############

const JOYSTICK_DEADZONE: float = 0.2

const DEATH_CLOCK_MAX_VOLUME = 1.0
const DEATH_CLOCK_MIN_VOLUME = 0.05

###########
# GLOBALS #
###########

@onready var audio_player: AudioStreamPlayer = $DeathClock

###########
# METHODS #
###########

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	GameManager.player_ref = self

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
	death_timer()


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
		
func death_timer() -> void:
	var time_left = $Timers/PlayerClock.time_left
	
	if time_left > 30.0 or time_left <= 0.0:
		if audio_player.playing:
			audio_player.stop()
		return
	
	if not audio_player.playing:
		audio_player.play()
	
	var progress = 1.0 - (time_left / 30.0)
	var linear_volume = lerp(DEATH_CLOCK_MIN_VOLUME, DEATH_CLOCK_MAX_VOLUME, progress)
	audio_player.volume_db = linear_to_db(linear_volume)
	print(audio_player.playing)
