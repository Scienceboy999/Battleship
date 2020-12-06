extends Popup

func _ready() -> void:
	$ColorRect/GridContainer/GridContainer/Master.value = Saved.saveData["masterVolume"]
	$ColorRect/GridContainer/GridContainer/SFX.value = Saved.saveData["sfxVolume"]

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		_on_DoneButton_pressed()

func _on_DoneButton_pressed() -> void:
	hide()

func _on_QuitButton_pressed() -> void:
	get_tree().quit()

func _on_BackToLobbyButton_pressed() -> void:
	get_tree().change_scene("res://Lobby/Lobby.tscn")
	if Network.peer != null:
		Network.peer.close_connection()

func _on_Master_value_changed(value: float) -> void:
	Saved.saveData["masterVolume"] = value
	Saved.saveGame()
	AudioServer.set_bus_volume_db(0,value)

func _on_SFX_value_changed(value: float) -> void:
	Saved.saveData["sfxVolume"] = value
	Saved.saveGame()
	AudioServer.set_bus_volume_db(1,value)
