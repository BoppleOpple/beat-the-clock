class_name StageBase
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background/BG.offset.y = -100
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_area_body_exited(body: Node2D) -> void:
	if body is ActorBase:
		if not body.should_free:
			body.kill(true)
