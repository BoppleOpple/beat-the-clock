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
const GRENADE_SPAWN_DISTANCE: float = 30.0

const PLAYER_TIMER_OFFSET: Vector2 = Vector2(-30,-25)

const SWORD_POMMEL_DISTANCE: float = 20.0
const SWORD_IMPULSE_SCALE: float = 900.0
const SWORD_STARTUP_DELAY: float = 0.2
const SWORD_PARRY_DURATION: float = 0.4
const SWORD_IMPULSE_UPKICK: float = 500.0

const PARRY_PARTICLE_DISTANCE: float = 25

const HITSTUN_DURATION: float = 0.8
const DEFAULT_BOUNCE: float = 0.25
const HITSTUN_BOUNCE: float = 0.8

const DEATH_TIME_MOD: float = -30.0
const KILL_TIME_MOD: float = 30.0

const KILL_EXPIRATION_TIME: float = 4.0

const jump_sfx = preload("res://assets/audio/abilities/jump.mp3")
const dash_sfx = preload("res://assets/audio/abilities/dash.mp3")
const sword_sfx = preload("res://assets/audio/abilities/sword.mp3")
const parry_sfx = preload("res://assets/audio/abilities/parry.mp3")
const throw_sfx = preload("res://assets/audio/abilities/throw.mp3")
const death_sfx = preload("res://assets/audio/entity/death.mp3")

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

var player_data := PlayerData.new()

var teleporting: bool = false
var teleport_pos: Vector2

var should_free: bool = false

@onready var ability_player: AudioStreamPlayer = $SFXPlayer

var motion_cause: ActorBase = self

@export var synced_time_left: float = 0.0

@export var owner_id: int = 0

###########
# METHODS #
###########

func _has_authority() -> bool:
	return multiplayer.multiplayer_peer == null or is_multiplayer_authority()

func _broadcast(method: StringName, args: Array = []) -> void:
	if multiplayer.multiplayer_peer != null:
		callv("rpc", [method] + args)
	else:
		callv(method, args)

func _ready() -> void:

	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	_set_motion_cause(self)
	$Timers/PlayerClock.start(GameManager.PLAYER_MAX_TIME / 2)
	if not _has_authority():
		freeze = true

	var main = get_tree().current_scene
	if main:
		if main.has_method("_on_actor_respawn"):
			respawn.connect(main._on_actor_respawn)
		if main.has_method("_on_player_throw_grenade"):
			throw_grenade.connect(main._on_player_throw_grenade)

func reset() -> void:
	_set_motion_cause(self)
	$CollisionShape2D.disabled = false
	self.sleeping = false
	self.should_free = false
	self.is_on_ground = false
	self.is_mid_jump = false

func _process(_delta: float):
	if _has_authority():
		synced_time_left = $Timers/PlayerClock.time_left
	# handle timers
	$Visual/VisualTimer/TimerLabel.text = str(snapped(synced_time_left, 0.1))
	$Visual/VisualTimer/TimerLabel.set_position(self.get_position() + PLAYER_TIMER_OFFSET)
	player_data.ability_1_cooldown = $Timers/LeftAbilityTimer.time_left
	player_data.ability_2_cooldown = $Timers/MiddleAbilityTimer.time_left
	player_data.ability_3_cooldown = $Timers/RightAbilityTimer.time_left
	player_data.ability_c_cooldown = $Timers/ComboAbilityTimer.time_left

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

	# keep unrotatable objects beneath player
	$Unrotatable.rotation = -self.rotation

	for node in $JumpCollisionNearby.get_overlapping_bodies():
		if node == self: continue

		if $Unrotatable/JumpCollisionBelow.overlaps_body(node):
			is_on_ground = true
			break

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
		SFXManager.try_play(ability_player, jump_sfx, 0.0, -30.0, randf_range(0.4,0.6))

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
	_set_motion_cause(self)
	_broadcast("_dash_visual")

func _throw_grenade() -> void:
	var vel: Vector2 = get_aim_direction() * GRENADE_VELOCITY_SCALE
	var pos: Vector2 = self.global_position + get_aim_direction() * GRENADE_SPAWN_DISTANCE

	vel += self.linear_velocity
	emit_signal("throw_grenade", self, pos, vel)
	SFXManager.try_play(ability_player, throw_sfx, 0.0, -22.0, randf_range(2.3,2.7))

func _slash() -> void:
	var sword_rotation = get_aim_direction().angle() - self.rotation
	_broadcast("_slash_visual", [sword_rotation])

	$Timers/SlashStartupDelay.start(SWORD_STARTUP_DELAY)
	$Timers/ParryTimer.start(SWORD_PARRY_DURATION)

func _set_motion_cause(source: Node2D):
	if source != self:
		$Timers/KillExpirationTimer.start(KILL_EXPIRATION_TIME)

	if source is ActorBase:
		self.motion_cause = source
	elif source is Grenade:
		if source.owning_actor == null:
			return
		self.motion_cause = source.owning_actor

func handle_knockback(impulse: Vector2, source: Node2D) -> void:
	if not _has_authority():
		request_knockback.rpc_id(get_multiplayer_authority(), impulse, source.get_path())
		return
	_apply_knockback_authoritative(impulse, source)

func _apply_knockback_authoritative(impulse: Vector2, source: Node2D) -> void:
	if $Timers/ParryTimer.time_left == 0:
		_set_motion_cause(source)
		self.apply_central_impulse(impulse)
		$Timers/HitstunTimer.start(HITSTUN_DURATION)
		self.physics_material_override.bounce = HITSTUN_BOUNCE
	else:
		var parry_rotation: float = (source.global_position - self.global_position).angle() - self.rotation
		_broadcast("_parry_visual", [parry_rotation])

func handle_blast_knockback(source: Grenade) -> void:
	if not _has_authority():
		request_blast_knockback.rpc_id(get_multiplayer_authority(), source.get_path())
		return
	_apply_blast_knockback_authoritative(source)

func _apply_blast_knockback_authoritative(source: Grenade) -> void:
	if source == null or not is_instance_valid(source):
		return
	var offset_vector: Vector2 = self.position - source.position
	var distance: float = max(offset_vector.length(), 0.001)  # guard divide-by-zero at point-blank range
	var velocity_scale: float = clamp((1.0 / distance) * source.BLAST_IMPULSE_SCALE, 0, source.BLAST_IMPULSE_CAP)
	var impulse: Vector2 = offset_vector.normalized() * velocity_scale
	_apply_knockback_authoritative(impulse, source)

func kill(force: bool = false, respawn: bool = true):
	if not _has_authority():
		return
	# TODO add preventable death maybe
	if force or true:
		if self._handle_mod_timer(DEATH_TIME_MOD) <= 0:
			respawn = false

		if motion_cause != self:
			if is_instance_valid(motion_cause):
				motion_cause.award_time_mod(KILL_TIME_MOD)

		_set_motion_cause(self)

		_broadcast("_death_visual", [respawn])

		if respawn:
			self._respawn()
		else:
			self._die_and_free()

func _respawn() -> void:
	emit_signal("respawn", self)

func _die_and_free() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	self.sleeping = true
	self.should_free = true
	$Visual.visible = false
	emit_signal("death", self)

func award_time_mod(amount: float) -> void:
	if not _has_authority():
		_request_time_mod.rpc_id(get_multiplayer_authority(), amount)
		return
	_handle_mod_timer(amount)

func _handle_mod_timer(time: float) -> float:
	var label = Label.new()
	$Visual/VisualTimer/TimerLabel/ModTime.add_child(label)
	$Visual/VisualTimer/TimerLabel/ModTime.move_child(label,0)
	var opacity_tween = create_tween()
	var timer_tween = create_tween()
	if time > 0.0:
		label.label_settings = load("res://assets/fonts/Default_add.tres")
		label.text = "+ " + str(time)
		$Visual/VisualTimer/TimerLabel.modulate = Color.GREEN
	elif time < 0.0:
		label.label_settings = load("res://assets/fonts/Default_remove.tres")
		label.text = "- " + str(abs(time))
		$Visual/VisualTimer/TimerLabel.modulate = Color.RED
	else:
		return $Timers/PlayerClock.time_left

	var result: float = $Timers/PlayerClock.time_left + time
	if result >= 0.0:
		$Timers/PlayerClock.start(result)
	else:
		$Timers/PlayerClock.stop()

	if $Timers/PlayerClock.time_left >= GameManager.PLAYER_MAX_TIME:
		$Timers/PlayerClock.start(GameManager.PLAYER_MAX_TIME)
		$Visual/VisualTimer/TimerLabel.modulate = Color.ROYAL_BLUE
	timer_tween.tween_property($Visual/VisualTimer/TimerLabel, "modulate", Color.WHITE, 0.5)
	opacity_tween.tween_property(label, "modulate:a", 0.0, 1.0)
	opacity_tween.tween_callback(label.queue_free)

	return result

func get_aim_direction() -> Vector2:
	return Vector2(1, 0)

func _teleport(destination: Vector2) -> void:
	teleporting = true
	teleport_pos = destination

####################
# INCOMING SIGNALS #
####################

func _on_jump_collision_below_body_exited(body: Node2D) -> void:
	# potentially change to group-based
	if body != self:
		$Timers/CoyoteTimer.start(DEFAULT_COYOTE_TIME)

func _on_coyote_timer_timeout() -> void:
	var validBodies: Array[Node2D] = $Unrotatable/JumpCollisionBelow.get_overlapping_bodies()

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
			body.when_slashed(self)

func _on_player_clock_timeout() -> void:
	if not _has_authority():
		return
	kill(true, false)

func _on_death_particles_finished() -> void:
	if should_free:
		self.queue_free()

func _on_kill_expiration_timer_timeout() -> void:
	_set_motion_cause(self)

func _on_hitstun_timer_timeout() -> void:
	# reset physics material
	self.physics_material_override.bounce = DEFAULT_BOUNCE

####################
#    RPC METHODS   #
####################

@rpc("authority", "call_local", "reliable")
func _slash_visual(sword_rotation: float) -> void:
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

	SFXManager.try_play(ability_player, sword_sfx, 0.0, -12.0, randf_range(0.6,2.4))

@rpc("authority", "call_local", "reliable")
func _dash_visual() -> void:
	SFXManager.try_play(ability_player, dash_sfx, 0.0, 0.0, randf_range(0.8,1.3))

@rpc("authority", "call_local", "reliable")
func _death_visual(respawn: bool) -> void:
	SFXManager.try_play(ability_player, death_sfx, 0.0, -12.0, randf_range(2.3,3.0))

	if respawn:
		$DeathParticles.amount = clamp(int(self.linear_velocity.length() / 25), 4, 100)
		$DeathParticles.initial_velocity_min = self.linear_velocity.length() * 0.5
		$DeathParticles.initial_velocity_max = self.linear_velocity.length() * 3
		$DeathParticles.direction = -self.linear_velocity.rotated(-self.rotation)
	else:
		$DeathParticles.amount = 100
		$DeathParticles.initial_velocity_min = 100
		$DeathParticles.initial_velocity_max = 300
		$DeathParticles.direction = Vector2.UP
		$DeathParticles.spread = 180

	$DeathParticles.color = $Visual/ColorRect2.color
	$DeathParticles.emitting = true

@rpc("any_peer", "call_remote", "reliable")
func request_knockback(impulse: Vector2, source_path: NodePath) -> void:
	if not is_multiplayer_authority():
		return  # ignore requests aimed at a peer that doesn't actually own this body
	var source = get_node_or_null(source_path)
	if source == null:
		return
	_apply_knockback_authoritative(impulse, source)

@rpc("any_peer", "call_remote", "reliable")
func request_blast_knockback(source_path: NodePath) -> void:
	if not is_multiplayer_authority():
		return  # ignore requests aimed at a peer that doesn't actually own this body
	var source = get_node_or_null(source_path)
	if source == null or not (source is Grenade):
		return
	_apply_blast_knockback_authoritative(source)

@rpc("any_peer", "call_remote", "reliable")
func _request_time_mod(amount: float) -> void:
	if not is_multiplayer_authority():
		return  # ignore requests aimed at a peer that doesn't actually own this body
	_handle_mod_timer(amount)

@rpc("authority", "call_local", "reliable")
func _parry_visual(parry_rotation: float) -> void:
	$ParryParticles.position = Vector2.from_angle(parry_rotation) * PARRY_PARTICLE_DISTANCE
	$ParryParticles.rotation = parry_rotation
	$ParryParticles.emitting = true

	SFXManager.try_play(ability_player, parry_sfx, 0.0, -12.0, randf_range(0.6,1.4))

####################
# OUTGOING SIGNALS #
####################

signal throw_grenade(player: ActorBase, position: Vector2, velocity: Vector2)

signal respawn(actor: ActorBase)

signal death(actor: ActorBase)
