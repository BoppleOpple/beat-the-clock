extends RigidBody2D

const BLAST_IMPULSE_SCALE: float = 85000.0

var isBlastable: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fuse_timeout() -> void:
	self.freeze = true
	$Collider.disabled = true
	
	$ExplosionSprite.visible = true
	$GrenadeSprite.visible = false
	
	$ExplosionSprite.play("default")
	$Smoke.emitting = true
	
	var blasted_nodes: Array[Node2D] = $BlastZone.get_overlapping_bodies()
	
	for node in blasted_nodes:
		if node.get("isBlastable"):
			_explode(node)

func _explode(other: Node2D) -> void:
	if other.has_method("apply_central_impulse"):
		var offset_vector: Vector2 = other.position - self.position
		var velocity_scale: float = (1/offset_vector.length()) * BLAST_IMPULSE_SCALE
		var impulse: Vector2 = offset_vector.normalized() * velocity_scale
		other.apply_central_impulse(impulse)

func _on_smoke_finished() -> void:
	self.queue_free()
