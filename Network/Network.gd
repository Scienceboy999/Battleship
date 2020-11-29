extends Node

const DEFAULT_IP:String = "127.0.0.1"
const DEFAULT_PORT:int = 32023

var peer:NetworkedMultiplayerENet = null

var selected_IP:String = DEFAULT_IP
var selected_PORT:int = DEFAULT_PORT

var local_player_id:int = 0
sync var players:Dictionary = {}
sync var player_data:Dictionary = {}

signal player_disconnected
signal server_disconnected

func restartSingleton() -> void:
	if peer != null:
		peer.close_connection()
	peer = null
	selected_IP = DEFAULT_IP
	selected_PORT = DEFAULT_PORT
	local_player_id = 0
	players = {}
	player_data = {}

func _ready() -> void:
	get_tree().connect("network_peer_connected",self,"_onPlayerConnected")
	get_tree().connect("network_peer_disconnected",self,"_onPlayerDisconnected")
	get_tree().connect("server_disconnected",self,"_onServerDisconnected")

func _onPlayerConnected(id:int) -> void:
	rpc("updateWaitingRoom")

func _onPlayerDisconnected(id:int) -> void:
	players.erase(id)
	if get_tree().current_scene.get_name() == "Lobby":
		rpc("updateWaitingRoom")
	else:
		backToLobby()

func _onServerDisconnected() -> void:
	players = {}
	rset("players",players)
	rpc("backToLobby")

func createServer(name:String) -> void:
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(selected_PORT,1)
	get_tree().set_network_peer(peer)
	local_player_id = get_tree().get_network_unique_id()
	player_data["name"] = name
	player_data["finishedPlacing"] = false
	player_data["boats"] = null
	players[local_player_id] = player_data
	rpc("updateWaitingRoom")

func connectToServer(name:String) -> void:
	peer = NetworkedMultiplayerENet.new()
	get_tree().connect("connected_to_server",self,"_onConnectedToServer")
	get_tree().connect("connection_failed",self,"_onConnectionFailed")
	peer.create_client(selected_IP,selected_PORT)
	player_data["name"] = name
	player_data["finishedPlacing"] = false
	player_data["boats"] = null
	get_tree().set_network_peer(peer)

func _onConnectedToServer() -> void:
	local_player_id = get_tree().get_network_unique_id()
	rpc_id(1,"addPlayer",local_player_id,player_data)

func _onConnectionFailed() -> void:
	get_tree().change_scene("res://Lobby/Lobby.tscn")

remote func addPlayer(id:int,data:Dictionary) -> void:
	players[id] = data
	rset("players",players)
	rpc("updateWaitingRoom")

sync func backToLobby() -> void:
	get_tree().change_scene("res://Lobby/Lobby.tscn")

sync func updateWaitingRoom() -> void:
	get_tree().call_group("waitingRoom","refresh",players)

func startPlacing() -> void:
	rpc("loadPlacing")

sync func loadPlacing() -> void:
	get_tree().change_scene("res://Placer/Placer.tscn")

func finishedPlacing(boats:Array) -> void:
	if local_player_id == 1:
		players[1]["finishedPlacing"] = true
		players[1]["boats"] = boats
		rset("players",players)
		checkLoadGame()
	else:
		rpc_id(1,"setPlayerFinishedPlacing",local_player_id,boats)
		rpc_id(1,"checkLoadGame")

remote func setPlayerFinishedPlacing(id:int,boats:Array) -> void:
	players[id]["finishedPlacing"] = true
	players[id]["boats"] = boats
	rset("players",players)

remote func checkLoadGame() -> void:
	for playerID in players:
		if !players[playerID]["finishedPlacing"]:
			return
	rpc("loadGame")

sync func loadGame() -> void:
	get_tree().change_scene("res://Game/Game.tscn")
