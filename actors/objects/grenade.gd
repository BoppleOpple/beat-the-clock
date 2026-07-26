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

@onready var ability_player: AudioStreamPlayer = $SFXPlayer
var explosion_sfx = preload("res://assets/audio/abilities/explosion.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Fuse.time_left < FUSE_FLASH_BEGIN and $Fuse.time_left > 0:
		var traced_angle: float = (PI / 2) * (1.5 + FUSE_FLASH_BEGIN / FUSE_FLASH_FREQUENCY)
		var sin_angle: float = remap($Fuse.time_left, 0, FUSE_FLASH_BEGIN, traced_angle, 0)
		
		var flash_value: float = sin(sin_angle)**2 
		
		$FlashGrenadeSprite.visible = (flash_value > FUSE_FLASH_THRESHOLD)

func _on_fuse_timeout() -> void:
	set_deferred("freeze", true)
	$Collider.set_deferred("disabled", true)
	$TriggerZone/Collider.set_deferred("disabled", true)
	
	$ExplosionSprite.visible = true
	$GrenadeSprite.visible = false
	$FlashGrenadeSprite.visible = false
	
	$ExplosionSprite.play("default")
	$Smoke.emitting = true
	
	var playback = ability_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if playback:
		playback.play_stream(explosion_sfx, 0.0, -12.0, randf_range(0.9,1.1))
	
	var blasted_nodes: Array[Node2D] = $BlastZone.get_overlapping_bodies()
	
	for node in blasted_nodes:
		if node.get("is_blastable") and node != self:
			_explode(node)

func _explode(other: Node2D) -> void:
	
	if other.has_method("apply_central_impulse"):
		var offset_vector: Vector2 = other.position - self.position
		var velocity_scale: float = clamp((1/offset_vector.length()) * BLAST_IMPULSE_SCALE, 0, BLAST_IMPULSE_CAP)
		var impulse: Vector2 = offset_vector.normalized() * velocity_scale
		
		if other is ActorBase:
			other.handle_knockback(impulse, self)
		else:
			other.apply_central_impulse(impulse)

func when_slashed(by: ActorBase):
	self.owning_actor = by

func _on_smoke_finished() -> void:
	self.queue_free()

func _on_trigger_zone_body_entered(body: Node2D) -> void:
	if body is ActorBase and $PrimedTimer.time_left == 0:
		$Fuse.stop()
		self._on_fuse_timeout()
