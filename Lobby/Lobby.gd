extends Control

func _ready() -> void:
	Network.restartSingleton()
	if OS.has_feature("standalone"):
		OS.window_fullscreen = true
		OS.window_borderless = true
	$ColorRect/VBoxContainer/NameEdit.text = Saved.saveData["playerName"]
	$ColorRect/VBoxContainer/IPEdit.text = Saved.saveData["IP"]
	$ColorRect/VBoxContainer/PortEdit.text = str(Saved.saveData["port"])

func _on_HostButton_pressed() -> void:
	Network.selected_IP = $ColorRect/VBoxContainer/IPEdit.text
	Network.selected_PORT = int($ColorRect/VBoxContainer/PortEdit.text)
	Network.createServer($ColorRect/VBoxContainer/NameEdit.text)
	$WaitingRoom.popup_centered()

func _on_JoinButton_pressed() -> void:
	Network.selected_IP = $ColorRect/VBoxContainer/IPEdit.text
	Network.selected_PORT = int($ColorRect/VBoxContainer/PortEdit.text)
	Network.connectToServer($ColorRect/VBoxContainer/NameEdit.text)
	$WaitingRoom.popup_centered()

func _on_SettingsButton_pressed() -> void:
	$Settings.popup_centered()

func _on_NameEdit_text_changed(new_text: String) -> void:
	Saved.saveData["playerName"] = $ColorRect/VBoxContainer/NameEdit.text
	Saved.saveGame()

func _on_IPEdit_text_changed(new_text: String) -> void:
	Saved.saveData["IP"] = $ColorRect/VBoxContainer/IPEdit.text
	Saved.saveGame()

func _on_PortEdit_text_changed(new_text: String) -> void:
	Saved.saveData["port"] = $ColorRect/VBoxContainer/PortEdit.text
	Saved.saveGame()
