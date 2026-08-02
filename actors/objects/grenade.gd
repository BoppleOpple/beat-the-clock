class_name Grenade
extends RigidBody2D

const BLAST_IMPULSE_SCALE: float = 85000.0
const BLAST_IMPULSE_CAP: float = 1800.0

const FUSE_FLASH_BEGIN: float = 1.5
const FUSE_FLASH_FREQUENCY: float = 0.5
const FUSE_FLASH_THRESHOLD: float = 0.75

var is_blastable: bool = true
var is_slashable: bool = true

var owning_actor: ActorBase = null

var detonated: bool = false

@onready var ability_player: AudioStreamPlayer = $SFXPlayer
var explosion_sfx = preload("res://assets/audio/abilities/explosion.mp3")


func _has_authority() -> bool:
	return multiplayer.multiplayer_peer == null or is_multiplayer_authority()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	if not _has_authority():
		freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Fuse.time_left < FUSE_FLASH_BEGIN and $Fuse.time_left > 0:
		var traced_angle: float = (PI / 2) * (1.5 + FUSE_FLASH_BEGIN / FUSE_FLASH_FREQUENCY)
		var sin_angle: float = remap($Fuse.time_left, 0, FUSE_FLASH_BEGIN, traced_angle, 0)

		var flash_value: float = sin(sin_angle)**2

		$FlashGrenadeSprite.visible = (flash_value > FUSE_FLASH_THRESHOLD)

func _on_fuse_timeout() -> void:
	if not _has_authority():
		return
	if detonated:
		return
	detonated = true

	set_deferred("freeze", true)

	if multiplayer.multiplayer_peer != null:
		_explosion_visual.rpc()
	else:
		_explosion_visual()

	var blasted_nodes: Array[Node2D] = $BlastZone.get_overlapping_bodies()
	for node in blasted_nodes:
		if node.get("is_blastable") and node != self:
			_explode(node)

func _explode(other: Node2D) -> void:
	if not _has_authority():
		return

	if other.has_method("apply_central_impulse"):
		if other is ActorBase:

			other.handle_blast_knockback(self)
		else:
			var offset_vector: Vector2 = other.position - self.position
			var velocity_scale: float = clamp((1/offset_vector.length()) * BLAST_IMPULSE_SCALE, 0, BLAST_IMPULSE_CAP)
			var impulse: Vector2 = offset_vector.normalized() * velocity_scale
			other.apply_central_impulse(impulse)

func when_slashed(by: ActorBase):
	self.owning_actor = by

func _on_smoke_finished() -> void:
	self.queue_free()

func _on_trigger_zone_body_entered(body: Node2D) -> void:
	if body is ActorBase and $PrimedTimer.time_left == 0:
		if _has_authority():
			$Fuse.stop()
			self._on_fuse_timeout()
		else:
			
			_request_early_detonation.rpc_id(get_multiplayer_authority())

####################
#    RPC METHODS   #
####################

@rpc("any_peer", "call_remote", "reliable")
func _request_early_detonation() -> void:
	if not is_multiplayer_authority():
		return
	$Fuse.stop()
	_on_fuse_timeout()

@rpc("authority", "call_local", "reliable")
func _explosion_visual() -> void:
	$Collider.set_deferred("disabled", true)
	$TriggerZone/Collider.set_deferred("disabled", true)

	$Fuse.stop()
	detonated = true

	$ExplosionSprite.visible = true
	$GrenadeSprite.visible = false
	$FlashGrenadeSprite.visible = false
	$ExplosionSprite.play("default")
	$Smoke.emitting = true

	var playback = ability_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if playback:
		playback.play_stream(explosion_sfx, 0.0, -12.0, randf_range(0.9,1.1))
