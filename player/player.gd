extends RigidBody2D

#############
# CONSTANTS #
#############

const MOVE_FORCE_SCALE: float = 1200.0
const VELOCITY_THRESHOLD: float = 500.0

const JUMP_VELOCITY: Vector2 = Vector2(0, -600.0)

const RIGHTING_TORQUE_SCALE: float = 10000.0

const JUMPING_GRAVITY_SCALE: float = 0.7
const AFTER_JUMPING_GRAVITY_SCALE: float = 1.5
const DEFAULT_GRAVITY_SCALE: float = 1.0

const DEFAULT_COYOTE_TIME: float = 0.2

const DASH_VELOCITY_SCALE: float = 800.0
const DASH_RECHARGE: float = 2.0

const GRENADE_VELOCITY_SCALE: float = 500.0

###########
# GLOBALS #
###########

var is_on_ground: bool = false
var is_mid_jump: bool = false

###########
# METHODS #
###########

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# get direction from input
	var input_x: float = 0
	if Input.is_action_pressed("gameplay_left"):
		input_x -= 1
	if Input.is_action_pressed("gameplay_right"):
		input_x += 1
	
	# scale the force based on current speed + direction (increase turnaround time)
	var input_dir: float = sign(input_x)
	var input_magnitude: float = abs(input_x - clamp(self.linear_velocity.x / VELOCITY_THRESHOLD, -1, 1)) * MOVE_FORCE_SCALE
	
	# apply the movement force
	self.apply_central_force(Vector2(input_dir * input_magnitude, 0))
	
	# keep ground detector beneath player
	$JumpCollisionBelow.rotation = -self.rotation
	
	# jump force
	if Input.is_action_just_pressed("gameplay_jump") and is_on_ground:
		is_mid_jump = true
		is_on_ground = false
		self.set_axis_velocity(JUMP_VELOCITY)
	
	# float (variable height + regrab)
	if Input.is_action_pressed("gameplay_jump"):
		self.gravity_scale = JUMPING_GRAVITY_SCALE
	elif is_mid_jump:
		self.gravity_scale = AFTER_JUMPING_GRAVITY_SCALE
	else:
		self.gravity_scale = DEFAULT_GRAVITY_SCALE
	
	# self-righting
	var righting_dir: float = -sign(self.rotation)
	var righting_factor: float = clamp(abs(self.rotation) / PI - 0.1, 0, 1)
	var righting_torque: float = righting_factor * RIGHTING_TORQUE_SCALE
	
	self.apply_torque(righting_torque * righting_dir)
	
	# handle abilities
	if Input.is_action_just_pressed("gameplay_ability_left") and (GameManager.player.ability_1_cooldown <= 0.0):
		GameManager.player.ability_1_cooldown = _activate_ability(GameManager.player.ability_1)
	
	if Input.is_action_just_pressed("gameplay_ability_middle") and (GameManager.player.ability_2_cooldown <= 0.0):
		GameManager.player.ability_2_cooldown = _activate_ability(GameManager.player.ability_2)
	
	if Input.is_action_just_pressed("gameplay_ability_right") and (GameManager.player.ability_3_cooldown <= 0.0):
		GameManager.player.ability_3_cooldown = _activate_ability(GameManager.player.ability_3)

func _activate_ability(ability: PlayerData.Ability) -> float:
	match ability:
		PlayerData.Ability.EMPTY:
			pass
		PlayerData.Ability.DASH:
			_perform_dash()
		PlayerData.Ability.SWORD:
			pass
		PlayerData.Ability.GRENADE:
			_throw_grenade()
	
	return GameManager.ABILITY_COOLDOWN[ability]

func _perform_dash() -> void:
	self.linear_velocity = Vector2()
	self.set_axis_velocity(get_mouse_direction() * DASH_VELOCITY_SCALE)

func _throw_grenade() -> void:
	var pos: Vector2 = $GrenadeAnchor.global_position
	var vel: Vector2 = get_mouse_direction() * GRENADE_VELOCITY_SCALE
	
	vel += self.linear_velocity
	
	emit_signal("throw_grenade", pos, vel)

func get_mouse_direction() -> Vector2:
	return (get_global_mouse_position() - self.position).normalized()

####################
# INCOMING SIGNALS #
####################

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("gameplay_ability_left"):
		self._perform_dash()

func _on_jump_collision_nearby_body_entered(body: Node2D) -> void:
	# potentially change to group-based
	if body != self and $JumpCollisionBelow.overlaps_body(body):
		$CoyoteTimer.stop()
		is_mid_jump = false
		is_on_ground = true

func _on_jump_collision_below_body_exited(body: Node2D) -> void:
	# potentially change to group-based
	if body != self:
		$CoyoteTimer.stop()
		$CoyoteTimer.start(DEFAULT_COYOTE_TIME)

func _on_coyote_timer_timeout() -> void:
	is_on_ground = false

####################
# OUTGOING SIGNALS #
####################

signal throw_grenade(position: Vector2, velocity: Vector2)
