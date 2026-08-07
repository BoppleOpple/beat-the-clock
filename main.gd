extends Node

const GRENADE_SCENE = preload("res://actors/objects/grenade.tscn")
const PLAYER_SCENE = preload("res://player/player.tscn")

const STAGE_POOL: Array[PackedScene] = [
	preload("res://stages/final_destination.tscn"),
	preload("res://stages/outdoors.tscn"),
	preload("res://stages/cloud_67.tscn"),
	preload("res://stages/cloud_moving.tscn"),
	preload("res://stages/forest.tscn"),
	preload("res://stages/windmill.tscn"),
	preload("res://stages/the_one.tscn"),
]

const CAMERA_TRACKING_SCALE: float = 5.0
const CAMERA_ZOOMING_SCALE: float = 10.0
const CAMERA_PADDING: Vector2 = Vector2(200, 200)

const ENEMY_SCENES: Dictionary[String, PackedScene] = {
	"MELEE":  preload("res://actors/enemies/melee/enemy_melee.tscn"  ),
	"BOMBER": preload("res://actors/enemies/bomber/enemy_bomber.tscn")
}

const ENEMY_PROPORTIONS: Dictionary[String, float] = {
	"MELEE":  0.75,
	"BOMBER": 0.25
}

var player_spawn_point: Node2D

var replacing_stage: bool = false
var new_stage: StageBase

var current_stage_index: int = -1
var current_enemy_list: Array = []

var _grenade_spawn_count: int = 0
var _enemy_spawn_count: int = 0
var _player_spawn_count: int = 0

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

func _ready() -> void:
	NetworkManager.player_disconnected.connect(_remove_player)

	if _is_server_or_singleplayer():
		_decide_stage_and_enemies()
		_build_stage_and_enemies(current_stage_index, current_enemy_list)
		_spawn_player(_local_peer_id())
	elif multiplayer.multiplayer_peer != null:
		_notify_ready.rpc_id(1)

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


func _spawn_player(id: int) -> void:
	if not _is_server_or_singleplayer():
		return

	var player := PLAYER_SCENE.instantiate()

	player.name = "Player_%d" % _player_spawn_count
	_player_spawn_count += 1
	player.owner_id = id

	$Players.add_child(player)

	_on_actor_respawn(player)

	if multiplayer.multiplayer_peer != null:
		_confirm_player_authority.rpc(player.get_path(), id)
	else:
		_confirm_player_authority(player.get_path(), id)

func _remove_player(id: int) -> void:
	var player = GameManager.get_player(id)
	if player:
		player.queue_free()
		GameManager.unregister_player(id, player)

func _add_enemy(enemy_scene: PackedScene) -> void:
	if not _is_server_or_singleplayer():
		return

	var enemy: EnemyBase = enemy_scene.instantiate()
	enemy.name = "Enemy_%d" % _enemy_spawn_count
	_enemy_spawn_count += 1
	enemy.set_hue(randf())
	enemy.set_multiplayer_authority(_local_peer_id())

	$Enemies.add_child(enemy)

func _move_actor_to_spawn_point(actor: ActorBase) -> void:
	var selected_spawn_location: Vector2 = Vector2.ZERO

	if actor is Player:
		if player_spawn_point:
			selected_spawn_location = player_spawn_point.global_position
	else:
		var spawn_points: Array[Node] = $Stage.get_spawn_points().filter(_is_Node2D)

		spawn_points = spawn_points.filter(_is_not_player_spawn)

		if not spawn_points.is_empty():
			selected_spawn_location = spawn_points[randi_range(0, spawn_points.size() - 1)].global_position

	actor._teleport(selected_spawn_location)

func _is_server_or_singleplayer() -> bool:
	return multiplayer.multiplayer_peer == null or multiplayer.is_server()

func _local_peer_id() -> int:
	return multiplayer.get_unique_id() if multiplayer.multiplayer_peer != null else 0

func _decide_stage_and_enemies() -> void:
	current_stage_index = randi_range(0, STAGE_POOL.size() - 1)
	current_enemy_list.clear()
	for i in range(GameManager.options.num_of_enemies):
		var rand_val: float = randf()
		for enemy_type in ENEMY_PROPORTIONS.keys():
			rand_val -= ENEMY_PROPORTIONS[enemy_type]
			if rand_val <= 0:
				current_enemy_list.append(enemy_type)
				break

func _build_stage_and_enemies(stage_index: int, enemy_list: Array) -> void:
	_set_stage(STAGE_POOL[stage_index])
	for enemy_type in enemy_list:
		_add_enemy(ENEMY_SCENES[enemy_type])

func _on_peer_joined(id: int) -> void:
	if not _is_server_or_singleplayer():
		return

	if multiplayer.multiplayer_peer != null:
		_receive_stage_and_enemies.rpc_id(id, current_stage_index, current_enemy_list)

	_spawn_player(id)

func _restart_game() -> void:
	if not _is_server_or_singleplayer():
		return

	for player in $Players.get_children():
		player.queue_free()
	for enemy in $Enemies.get_children():
		enemy.queue_free()
	for obj in $Objects.get_children():
		obj.queue_free()

	_decide_stage_and_enemies()
	_build_stage_and_enemies(current_stage_index, current_enemy_list)

	_spawn_player(_local_peer_id())

	if multiplayer.multiplayer_peer != null:
		for id in NetworkManager.players.keys():
			if id != multiplayer.get_unique_id():
				_receive_stage_and_enemies.rpc_id(id, current_stage_index, current_enemy_list)
				_spawn_player(id)

	if multiplayer.multiplayer_peer != null:
		$GameOver._reset.rpc()
	else:
		$GameOver._reset()

####################
# INCOMING SIGNALS #
####################

func _on_player_throw_grenade(player: ActorBase, position: Vector2, velocity: Vector2) -> void:
	if not _is_server_or_singleplayer():
		_request_throw_grenade.rpc_id(1, player.get_path(), position, velocity)
		return
	_spawn_grenade(player, position, velocity)

func _spawn_grenade(player: ActorBase, position: Vector2, velocity: Vector2) -> void:
	var new_grenade: Grenade = GRENADE_SCENE.instantiate()
	new_grenade.name = "Grenade_%d" % _grenade_spawn_count
	_grenade_spawn_count += 1
	new_grenade.global_position = position
	new_grenade.linear_velocity = velocity
	new_grenade.owning_actor = player

	new_grenade.set_multiplayer_authority(_local_peer_id())

	$Objects.add_child(new_grenade)


func _on_actor_respawn(actor: ActorBase) -> void:
	if actor is Player:
		var spawn_points: Array[Node] = $Stage.get_spawn_points().filter(_is_Node2D)
		# assign a spawn to the player
		if not spawn_points.is_empty():
			player_spawn_point = spawn_points[randi_range(0, spawn_points.size() - 1)]

	_move_actor_to_spawn_point(actor)

func _on_stage_tree_exited() -> void:
	if new_stage != null:
		self.add_child(new_stage)
		new_stage = null

	if get_tree() != null:
		var actors: Array[Node] = []
		actors += get_tree().get_nodes_in_group("Players").filter(_is_ActorBase)
		actors += get_tree().get_nodes_in_group("baddies").filter(_is_ActorBase)

		for actor in actors:
			_on_actor_respawn(actor)

	replacing_stage = false

####################
#    RPC METHODS   #
####################
@rpc("authority", "call_remote", "reliable")
func _receive_stage_and_enemies(stage_index: int, enemy_list: Array) -> void:
	current_stage_index = stage_index
	current_enemy_list = enemy_list
	_set_stage(STAGE_POOL[stage_index])

@rpc("any_peer", "call_remote", "reliable")
func _request_throw_grenade(player_path: NodePath, position: Vector2, velocity: Vector2) -> void:
	if not multiplayer.is_server():
		return
	var sender_id = multiplayer.get_remote_sender_id()
	var player = get_node_or_null(player_path)
	if player == null or player.get_multiplayer_authority() != sender_id:
		return
	_spawn_grenade(player, position, velocity)

@rpc("any_peer", "call_remote", "reliable")
func _notify_ready() -> void:
	if not multiplayer.is_server():
		return
	var id = multiplayer.get_remote_sender_id()
	_on_peer_joined(id)

@rpc("authority", "call_local", "reliable")
func _confirm_player_authority(player_path: NodePath, owner_peer_id: int) -> void:
	var player = get_node_or_null(player_path)
	if player:
		player.set_multiplayer_authority(owner_peer_id)
		player.freeze = not player._has_authority()
