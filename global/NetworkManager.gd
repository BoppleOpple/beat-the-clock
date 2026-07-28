extends Node

#############
# CONSTANTS #
#############

###########
# GLOBALS #
###########

@export var port: int = 7777
@export var max_players: int = 4

var players: Dictionary = {}

###########
# METHODS #
###########

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(input_port: int = port, input_max_players: int = max_players) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(input_port, input_max_players)
	if error != OK:
		push_error("Failed to create server: " + str(error))
		return
	multiplayer.multiplayer_peer = peer
	players[1] = {"name": "Host"}
	server_created.emit()
	print("Server started on port ", input_port) # TODO TEMP
	
func join_game(ip_address: String, input_port: int = port) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_address, input_port)
	if error != OK:
		push_error("Failed to create client: " + str(error))
		return
	multiplayer.multiplayer_peer = peer
	
func disconnect_game() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	players.clear()
	
func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)
	players[id] = {"name": "Player " + str(id)}
	player_connected.emit(id)
	
func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)
	
func _on_connected_ok() -> void:
	print("Successfully connected to server")
	var my_id = multiplayer.get_unique_id()
	players[my_id] = {"name": "Player " + str(my_id)}
	player_connected.emit(my_id)
	
func _on_connected_fail() -> void:
	print("Connection failed")
	multiplayer.multiplayer_peer = null
	connection_failed.emit()
	
func _on_server_disconnected() -> void:
	print("Server disconnected")
	multiplayer.multiplayer_peer = null
	players.clear()
	
####################
# INCOMING SIGNALS #
####################
	
####################
# OUTGOING SIGNALS #
####################
	
signal player_connected(id: int)
signal player_disconnected(id: int)
signal server_created()
signal connection_failed()
