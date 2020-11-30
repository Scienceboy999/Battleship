extends Popup

onready var PlayerList:ItemList = $ColorRect/ItemList

func _ready() -> void:
	PlayerList.clear()

func _on_StartButton_pressed() -> void:
	Network.startPlacing()

func refresh(players:Dictionary) -> void:
	PlayerList.clear()
	for playerID in players:
		PlayerList.add_item(players[playerID]["name"],null,false)
	$ColorRect/StartButton.visible = (Network.local_player_id == 1 && Network.players.size() == 2)

func _on_backToLobbyButton_pressed() -> void:
	if Network.local_player_id == 1:
		rpc("backToLobby")
	else:
		get_tree().change_scene("res://Lobby/Lobby.tscn")
		Network.peer.close_connection()

sync func backToLobby() -> void:
	get_tree().change_scene("res://Lobby/Lobby.tscn")

func _on_SettingsButton_pressed() -> void:
	$ColorRect/Settings.popup_centered()
