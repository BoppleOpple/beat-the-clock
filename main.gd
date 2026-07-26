extends Node

const GRENADE_SCENE = preload("res://actors/objects/grenade.tscn")
const PLAYER_SCENE = preload("res://player/player.tscn")

const STAGE_POOL: Array[PackedScene] = [
	preload("res://stages/final_destination.tscn"),
	preload("res://stages/outdoors.tscn")
]

const CAMERA_TRACKING_SCALE: float = 5.0
const CAMERA_ZOOMING_SCALE: float = 10.0
const CAMERA_PADDING: Vector2 = Vector2(200, 200)

var player_spawn_point: Node2D

var replacing_stage: bool = false
var new_stage: StageBase

###########
# METHODS #
###########

### FILTERS ###

func _is_Node2D(node: Node) -> bool:
		return node is Node2D

func _is_ActorBase(node: Node) -> bool:
		return node is ActorBase

func _is_not_player_spawn (spawn: Node):
	return spawn != player_spawn_point

### LOGIC ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_randomize_stage()
	
	var actors: Array[Node] = [$Player]
	actors += get_tree().get_nodes_in_group("baddies").filter(_is_ActorBase)
	
	for actor in actors:
		actor.connect("throw_grenade", _on_player_throw_grenade)
		actor.connect("respawn", _on_actor_respawn)
		_on_actor_respawn(actor)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if replacing_stage:
		return
	
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
	
	var blast_zone_rect: Rect2 = $Stage.get_blast_zone()
	
	min_corner = min_corner.clamp(blast_zone_rect.position, blast_zone_rect.position + blast_zone_rect.size)
	max_corner = max_corner.clamp(blast_zone_rect.position, blast_zone_rect.position + blast_zone_rect.size)
	
	return Rect2(min_corner, max_corner - min_corner)

func _set_stage(stage: PackedScene) -> void: 
	new_stage = stage.instantiate()
	new_stage.name = "Stage"
	new_stage.connect("tree_exited", _on_stage_tree_exited)
	
	$Stage.queue_free()
	replacing_stage = true

func _randomize_stage() -> void:
	var selected_index: int = randi_range(0, STAGE_POOL.size() - 1)
	_set_stage(STAGE_POOL[selected_index])

func _move_actor_to_spawn_point(actor: ActorBase) -> void:
	var selected_spawn_location: Vector2 = Vector2.ZERO
	
	if actor is Player:
		selected_spawn_location = player_spawn_point.global_position
	else:
		var spawn_points: Array[Node] = $Stage.get_spawn_points().filter(_is_Node2D)
		
		spawn_points = spawn_points.filter(_is_not_player_spawn)
		
		if not spawn_points.is_empty():
			selected_spawn_location = spawn_points[randi_range(0, spawn_points.size() - 1)].global_position
	
	actor._teleport(selected_spawn_location)

####################
# INCOMING SIGNALS #
####################

func _on_player_throw_grenade(player: ActorBase, position: Vector2, velocity: Vector2) -> void:
	var new_grenade: Grenade = GRENADE_SCENE.instantiate()
	new_grenade.global_position = position
	new_grenade.linear_velocity = velocity
	new_grenade.owning_actor = player
	$Objects.add_child(new_grenade)


func _on_actor_respawn(actor: ActorBase) -> void:
	if actor is Player:
		var spawn_points: Array[Node] = $Stage.get_spawn_points().filter(_is_Node2D)
		# assign a spawn to the player
		if not spawn_points.is_empty():
			player_spawn_point = spawn_points[randi_range(0, spawn_points.size() - 1)]
	
	_move_actor_to_spawn_point(actor)

func _on_stage_tree_exited() -> void:
	self.add_child(new_stage)
	replacing_stage = false
