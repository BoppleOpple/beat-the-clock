extends Node

#############
# CONSTANTS #
#############

const PLAYER_MAX_TIME: float = 300.5

const SAVE_GAME_PATH := "user://savegame.save"
const SAVE_OPTIONS_PATH := "user://options.save"

const ABILITY_COOLDOWN: Array[float] = [10.0, 2.0, 2.5, 3.0]

###########
# GLOBALS #
###########

var options: Options
# -----------
# ABILITY VALUES
# 0 - Empty
# 1 - Dash
# 2 - Sword
# 3 - Grenade
# -----------
enum Ability {
	EMPTY = 0,
	DASH = 1,
	SWORD = 2,
	GRENADE = 3,
}
enum InputDevice { KEYBOARD_MOUSE, CONTROLLER }
var current_device := InputDevice.KEYBOARD_MOUSE
var players: Dictionary = {}

###########
# METHODS #
###########

func _ready() -> void:
	options = Options.new()
	load_options()

func _process(delta: float) -> void:
	pass

func save_options() -> void:
	var options_dict := {
		"resolution_x": options.resolution_x,
		"resolution_y": options.resolution_y,
		"fullscreen": options.fullscreen,
		"vsync": options.vsync,
		"framerate": options.framerate,
		"volume_master": options.volume_master,
		"volume_music": options.volume_music,
		"volume_sfx": options.volume_sfx,
		"num_of_enemies": options.num_of_enemies,
		"last_used_ip": options.last_used_ip,
		"last_used_port": options.last_used_port
		}
	var file := FileAccess.open(SAVE_OPTIONS_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(options_dict))
	file.close()
	
func load_options() -> void:
	if not FileAccess.file_exists(SAVE_OPTIONS_PATH):
		return
	var file := FileAccess.open(SAVE_OPTIONS_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if data == null:
		return
	options.resolution_x = data.get("resolution_x", 0)
	options.resolution_y = data.get("resolution_y", 0)
	options.fullscreen = data.get("fullscreen", 0)
	options.vsync = data.get("vsync", 0)
	options.framerate = data.get("framerate", 0)
	options.volume_master = data.get("volume_master", 0)
	options.volume_music = data.get("volume_music", 0)
	options.volume_sfx = data.get("volume_sfx", 0)
	options.num_of_enemies = data.get("num_of_enemies", 0)
	if not data.get("last_used_ip",0) == null:
		options.last_used_ip = data.get("last_used_ip", 0)
	if not data.get("last_used_port",0) == null:	
		options.last_used_port = data.get("last_used_port", 0)
	_once_options_loaded()
	
func set_master_volume(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
func set_music_volume(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
func set_sfx_volume(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		current_device = InputDevice.KEYBOARD_MOUSE
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		current_device = InputDevice.CONTROLLER
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
func _once_options_loaded() -> void:
	DisplayServer.window_set_size(Vector2i(options.resolution_x, options.resolution_y))
	if options.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if options.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		options.framerate = DisplayServer.screen_get_refresh_rate()
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = options.framerate
	set_master_volume(options.volume_master / 100.0)
	set_music_volume(options.volume_music / 100.0)
	set_sfx_volume(options.volume_sfx / 100.0)
	
func register_player(player: Player, id: int = -1) -> void:
	if id == -1:
		id = player.owner_id
	players[id] = player
	player_registered.emit(player)
	if _is_local_player(player):
		local_player_ready.emit(player)
	
func unregister_player(id: int, player: Player = null) -> void:
	if players.has(id):
		var p = players[id]
		if player != null and p != player:
			return
		players.erase(id)
		player_unregistered.emit(p)
		
func get_player(id: int) -> Player:
	return players.get(id)
	
func _is_local_player(player: Player) -> bool:
	if multiplayer.multiplayer_peer == null:
		return true
	return player.owner_id == multiplayer.get_unique_id()

func get_local_player() -> Player:
	for p in players.values():
		if is_instance_valid(p) and _is_local_player(p):
			return p
	return null

func get_all_players() -> Array:
	return players.values().filter(func(p): return is_instance_valid(p))
	
####################
# OUTGOING SIGNALS #
####################

signal player_registered(player: Player)
signal player_unregistered(player: Player)
signal local_player_ready(player: Player)
