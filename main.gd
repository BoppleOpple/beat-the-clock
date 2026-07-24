extends Node

const GRENADE_SCENE = preload("res://actors/objects/grenade.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_throw_grenade(position: Vector2, velocity: Vector2) -> void:
	var newGrenade: RigidBody2D = GRENADE_SCENE.instantiate()
	newGrenade.global_position = position
	newGrenade.linear_velocity = velocity
	$Objects.add_child(newGrenade)
