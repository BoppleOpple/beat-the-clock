class_name ActorBase
extends RigidBody2D

#############
# CONSTANTS #
#############

const MOVE_FORCE_SCALE: float = 1200.0
const VELOCITY_THRESHOLD: float = 500.0

const JUMP_VELOCITY: Vector2 = Vector2(0, -600.0)

const RIGHTING_TORQUE_SCALE: float = 10000.0

const JUMPING_GRAVITY_SCALE: float = 0.7
const JUMPING_TORQUE_SCALE: float = 50.0
const JUMPING_TORQUE_MAX: float = 5000.0
const AFTER_JUMPING_GRAVITY_SCALE: float = 1.5
const DEFAULT_GRAVITY_SCALE: float = 1.0

const DEFAULT_COYOTE_TIME: float = 0.2

const DASH_VELOCITY_SCALE: float = 800.0
const DASH_RECHARGE: float = 2.0

const GRENADE_VELOCITY_SCALE: float = 500.0

const PLAYER_TIMER_OFFSET: Vector2 = Vector2(-30,-25)

const SWORD_POMMEL_DISTANCE: float = 20.0
const SWORD_IMPULSE_SCALE: float = 900.0
const SWORD_STARTUP_DELAY: float = 0.2
const SWORD_PARRY_DURATION: float = 0.4
const SWORD_IMPULSE_UPKICK: float = 500.0

const PARRY_PARTICLE_DISTANCE: float = 25

const HITSTUN_DURATION: float = 1.0

###########
# CLASSES #
###########

class Actions:
	var move_x: float = 0.0
	var jump: bool = false
	var slow_fall: bool = false
	var ability_1: bool = false
	var ability_2: bool = false
	var ability_3: bool = false
	var ability_combo: bool = false
	var aim_vector: Vector2 = Vector2(1, 0)

###########
# GLOBALS #
###########

var is_blastable: bool = true
var is_slashable: bool = true
var is_on_ground: bool = false
var is_mid_jump: bool = false

var ability_1: GameManager.Ability = GameManager.Ability.DASH
var ability_2: GameManager.Ability = GameManager.Ability.GRENADE
var ability_3: GameManager.Ability = GameManager.Ability.SWORD
var ability_c: GameManager.Ability = GameManager.Ability.DASH

var teleporting: bool = false
var teleport_pos: Vector2

var should_free: bool = false

###########
# METHODS #
###########

func _ready() -> void:
	$Timers/PlayerClock.start(GameManager.PLAYER_MAX_TIME / 2)

func _process(_delta: float):
	# handle timers
	$Timers/VisualTimer/TimerLabel.text = str(snapped($Timers/PlayerClock.time_left, 0.1))
	$Timers/VisualTimer/TimerLabel.set_position(self.get_position() + PLAYER_TIMER_OFFSET)
	GameManager.player.ability_1_cooldown = $Timers/LeftAbilityTimer.time_left
	GameManager.player.ability_2_cooldown = $Timers/MiddleAbilityTimer.time_left
	GameManager.player.ability_3_cooldown = $Timers/RightAbilityTimer.time_left
	GameManager.player.ability_c_cooldown = $Timers/ComboAbilityTimer.time_left

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if teleporting:
		var new_transform = state.get_transform()
		new_transform.origin = teleport_pos
		state.set_transform(new_transform)

		# Reset velocities to avoid the object going through walls
		state.set_linear_velocity(Vector2())
		state.set_angular_velocity(0.0)

		teleporting = false

func _apply_actions(actions: Actions, _delta: float) -> void:
	if should_free:
		return
		
	# keep ground detector beneath player
	$JumpCollisionBelow.rotation = -self.rotation
	
	if $Timers/HitstunTimer.time_left > 0.0:
		return

	# get direction from input
	var input_x: float = actions.move_x
	
	# scale the force based on current speed + direction (increase turnaround time)
	var input_dir: float = sign(input_x)
	var input_magnitude: float = abs(input_x - clamp(self.linear_velocity.x / VELOCITY_THRESHOLD, -1, 1)) * MOVE_FORCE_SCALE
	
	# apply the movement force
	self.apply_central_force(Vector2(input_dir * input_magnitude, 0))
	
	# jump force
	if actions.jump and self.is_on_ground:
		self.is_mid_jump = true
		self.is_on_ground = false
		self.set_axis_velocity(JUMP_VELOCITY)
		
		var jump_torque: float = clamp(
			self.linear_velocity.x * JUMPING_TORQUE_SCALE,
			-JUMPING_TORQUE_MAX,
			JUMPING_TORQUE_MAX
		)
		self.apply_torque_impulse(jump_torque)
	
	# float (variable height + regrab)
	if actions.slow_fall:
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
	if actions.ability_1 and $Timers/LeftAbilityTimer.is_stopped():
		$Timers/LeftAbilityTimer.start(_activate_ability(ability_1))
	
	if actions.ability_2 and $Timers/MiddleAbilityTimer.is_stopped():
		$Timers/MiddleAbilityTimer.start(_activate_ability(ability_2))
	
	if actions.ability_3 and $Timers/RightAbilityTimer.is_stopped():
		$Timers/RightAbilityTimer.start(_activate_ability(ability_3))
		
	if actions.ability_combo and $Timers/ComboAbilityTimer.is_stopped():
		$Timers/ComboAbilityTimer.start(_activate_ability(ability_c))

func _activate_ability(ability: GameManager.Ability) -> float:
	match ability:
		GameManager.Ability.EMPTY:
			pass
		GameManager.Ability.DASH:
			_perform_dash()
		GameManager.Ability.SWORD:
			_slash()
		GameManager.Ability.GRENADE:
			_throw_grenade()
	
	return GameManager.ABILITY_COOLDOWN[ability]

func _perform_dash() -> void:
	self.linear_velocity = Vector2()
	self.set_axis_velocity(get_aim_direction() * DASH_VELOCITY_SCALE)

func _throw_grenade() -> void:
	var pos: Vector2 = $Visual/GrenadeAnchor.global_position
	var vel: Vector2 = get_aim_direction() * GRENADE_VELOCITY_SCALE
	
	vel += self.linear_velocity
	
	emit_signal("throw_grenade", pos, vel)

func _slash() -> void:
	var sword_rotation = get_aim_direction().angle() - self.rotation
	
	$Visual/SwordAnchor.position = Vector2.from_angle(sword_rotation) * SWORD_POMMEL_DISTANCE
	$Visual/SwordAnchor.rotation = sword_rotation
	if abs(sword_rotation) < PI/2:
		$Visual/SwordAnchor/SwordSlash.position.y = -abs($Visual/SwordAnchor/SwordSlash.position.y)
		$Visual/SwordAnchor/SwordSlash.flip_v = false
	else:
		$Visual/SwordAnchor/SwordSlash.position.y = abs($Visual/SwordAnchor/SwordSlash.position.y)
		$Visual/SwordAnchor/SwordSlash.flip_v = true
	
	$Visual/SwordAnchor/SwordSlash.visible = true
	$Visual/SwordAnchor/SwordSlash.play("default")
	
	$Timers/SlashStartupDelay.start(SWORD_STARTUP_DELAY)
	$Timers/ParryTimer.start(SWORD_PARRY_DURATION)

func handle_knockback(impulse: Vector2, source: Node2D) -> void:
	if $Timers/ParryTimer.time_left == 0:
		$Timers/HitstunTimer.start(HITSTUN_DURATION)
		self.apply_central_impulse(impulse)
	else:
		var parry_rotation: float = (source.global_position - self.global_position).angle() - self.rotation
		
		$ParryParticles.position = Vector2.from_angle(parry_rotation) * PARRY_PARTICLE_DISTANCE
		$ParryParticles.rotation = parry_rotation
		$ParryParticles.emitting = true

func kill(force: bool = false):
	# TODO add preventable death maybe
	if force or true:
		$DeathParticles.amount = clamp(int(self.linear_velocity.length() / 25), 4, 100)
		print($DeathParticles.amount)
		$DeathParticles.initial_velocity_min = self.linear_velocity.length() * 0.5
		$DeathParticles.initial_velocity_max = self.linear_velocity.length() * 3
		$DeathParticles.direction = -self.linear_velocity.rotated(-self.rotation)
		
		$DeathParticles.emitting = true
		
		$DeathParticles.color = $Visual/ColorRect2.color
		
		self._on_kill()

func _on_kill() -> void:
	$CollisionShape2D.disabled = true
	self.sleeping = true
	self.should_free = true

func _handle_mod_timer(time: float) -> void:
	var label = Label.new()
	$Timers/VisualTimer/TimerLabel/ModTime.add_child(label)
	$Timers/VisualTimer/TimerLabel/ModTime.move_child(label,0)
	var opacity_tween = create_tween()
	var timer_tween = create_tween()
	if time > 0.0:
		label.label_settings = load("res://assets/fonts/Default_add.tres")
		label.text = "+ " + str(time)
		$Timers/VisualTimer/TimerLabel.modulate = Color.GREEN
	elif time < 0.0:
		label.label_settings = load("res://assets/fonts/Default_remove.tres")
		label.text = "- " + str(abs(time))
		$Timers/VisualTimer/TimerLabel.modulate = Color.RED
	else:
		return
	if ($Timers/PlayerClock.time_left + time) >= 0.0: 
		$Timers/PlayerClock.start($Timers/PlayerClock.time_left + time)
	else:
		$Timers/PlayerClock.start(0.001)
	if $Timers/PlayerClock.time_left >= GameManager.PLAYER_MAX_TIME:
		$Timers/PlayerClock.start(GameManager.PLAYER_MAX_TIME)
		$Timers/VisualTimer/TimerLabel.modulate = Color.ROYAL_BLUE
	timer_tween.tween_property($Timers/VisualTimer/TimerLabel, "modulate", Color.WHITE, 0.5)
	opacity_tween.tween_property(label, "modulate:a", 0.0, 1.0)
	opacity_tween.tween_callback(label.queue_free)

func get_aim_direction() -> Vector2:
	return Vector2(1, 0)
	
func _teleport(destination: Vector2) -> void:
	teleporting = true
	teleport_pos = destination

####################
# INCOMING SIGNALS #
####################

func _on_jump_collision_nearby_body_entered(body: Node2D) -> void:
	# potentially change to group-based
	if body != self and $JumpCollisionBelow.overlaps_body(body):
		$Timers/CoyoteTimer.stop()
		self.is_mid_jump = false
		self.is_on_ground = true

func _on_jump_collision_below_body_exited(body: Node2D) -> void:
	# potentially change to group-based
	if body != self:
		$Timers/CoyoteTimer.start(DEFAULT_COYOTE_TIME)

func _on_coyote_timer_timeout() -> void:
	var validBodies: Array[Node2D] = $JumpCollisionBelow.get_overlapping_bodies()
	
	validBodies.erase(self)
	if validBodies.size() == 0:
		self.is_on_ground = false

func _on_slash_startup_delay_timeout() -> void:
	$Visual/SwordAnchor/SlashCollision.monitoring = true

func _on_sword_slash_animation_finished() -> void:
	$Visual/SwordAnchor/SwordSlash.visible = false
	$Visual/SwordAnchor/SwordSlash.stop()
	
	$Visual/SwordAnchor/SlashCollision.monitoring = false

func _on_slash_collision_body_entered(body: Node2D) -> void:
	if body.get("is_slashable"):
		var knockback_impulse: Vector2 = (body.position - self.position).normalized() * SWORD_IMPULSE_SCALE
		
		# add upkick when hitting horizontally
		if abs(knockback_impulse.dot(Vector2(1, 0))) > 0.8:
			knockback_impulse.y -= SWORD_IMPULSE_UPKICK
		
		if body.has_method("apply_central_impulse"):
			if body is ActorBase:
				body.handle_knockback(knockback_impulse, self)
			else:
				body.apply_central_impulse(knockback_impulse)
		
		if body.has_method("when_slashed"):
			body.when_slashed()
	
func _on_player_clock_timeout() -> void:
	kill(true)

func _on_death_particles_finished() -> void:
	if should_free:
		self.queue_free()

####################
# OUTGOING SIGNALS #
####################

signal throw_grenade(position: Vector2, velocity: Vector2)
