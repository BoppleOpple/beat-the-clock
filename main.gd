extends Node

const GRENADE_SCENE = preload("res://actors/objects/grenade.tscn")
const PLAYER_SCENE = preload("res://player/player.tscn")

const CAMERA_TRACKING_SCALE: float = 5.0
const CAMERA_ZOOMING_SCALE: float = 10.0
const CAMERA_PADDING: Vector2 = Vector2(200, 200)

###########
# METHODS #
###########

### FILTERS ###

func _is_Node2D(node: Node) -> bool:
		return node is Node2D

func _is_ActorBase(node: Node) -> bool:
		return node is ActorBase

### LOGIC ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("baddies").filter(_is_ActorBase)
	
	for actor in enemies:
		actor.connect("throw_grenade", _on_player_throw_grenade)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var camera_target_rect: Rect2 = _get_camera_bounds()
	
	_move_camera(camera_target_rect.get_center(), delta)
	
	var cam_position: Vector2 = $CameraSystem/Camera.global_position
	
	var minimum_needed_viewport_size: Vector2 = get_viewport().get_visible_rect().size / camera_target_rect.size
	
	var target_zoom: float = min(minimum_needed_viewport_size.x, minimum_needed_viewport_size.y)
	
	var zoom_proportion: float = clamp(abs($CameraSystem/Camera.zoom.x - target_zoom) * CAMERA_ZOOMING_SCALE * delta, 0, 1)
	
	var cam_zoom: float = lerp($CameraSystem/Camera.zoom.x, target_zoom, zoom_proportion)
	$CameraSystem/Camera.zoom = Vector2(cam_zoom, cam_zoom)

func _move_camera(target_pos: Vector2, delta: float) -> void:
	$CameraSystem/CameraTarget.global_position = target_pos
	var target_vector: Vector2 = $CameraSystem/CameraTarget.global_position - $CameraSystem/Camera.global_position
	var movement_scale: float = clamp((1-(1/target_vector.length())) * CAMERA_TRACKING_SCALE * delta, 0, 1)
	
	$CameraSystem/Camera.global_position += target_vector * movement_scale

func _get_camera_bounds() -> Rect2:
	var points_of_interest: Array[Node] = get_tree().get_nodes_in_group("POI").filter(_is_Node2D)
	
	var min_corner: Vector2 = Vector2( INF,  INF)
	var max_corner: Vector2 = Vector2(-INF, -INF)
	
	for node in points_of_interest:
		min_corner.x = min(min_corner.x, node.global_position.x)
		min_corner.y = min(min_corner.y, node.global_position.y)
		
		max_corner.x = max(max_corner.x, node.global_position.x)
		max_corner.y = max(max_corner.y, node.global_position.y)
	
	min_corner -= CAMERA_PADDING
	max_corner += CAMERA_PADDING
	
	var blast_zone_rect: Rect2 = $Stage/PlayArea/CollisionShape2D.shape.get_rect()
	
	min_corner = min_corner.clamp(blast_zone_rect.position, blast_zone_rect.position + blast_zone_rect.size)
	max_corner = max_corner.clamp(blast_zone_rect.position, blast_zone_rect.position + blast_zone_rect.size)
	
	return Rect2(min_corner, max_corner - min_corner)

####################
# INCOMING SIGNALS #
####################

func _on_player_throw_grenade(position: Vector2, velocity: Vector2) -> void:
	var newGrenade: RigidBody2D = GRENADE_SCENE.instantiate()
	newGrenade.global_position = position
	newGrenade.linear_velocity = velocity
	$Objects.add_child(newGrenade)

func _on_player_respawn_player() -> void:
	$Player.queue_free()
	$Player.name = "player_old"
	
	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.name = "Player"
	
	new_player.connect("respawn_player", _on_player_respawn_player)
	new_player.connect("throw_grenade", _on_player_throw_grenade)
	GameManager.player_ref = new_player
	
	self.add_child(new_player)
