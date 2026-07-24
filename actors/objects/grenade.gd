extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fuse_timeout() -> void:
	$ExplosionSprite.visible = true
	$GrenadeSprite.visible = false
	
	$ExplosionSprite.play("default")
	$Smoke.emitting = true
