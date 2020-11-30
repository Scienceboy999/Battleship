extends Control

func _ready() -> void:
	Network.restartSingleton()
	if OS.has_feature("standalone"):
		OS.window_fullscreen = true
		OS.window_borderless = true
	$ColorRect/VBoxContainer/IPEdit.text = Network.DEFAULT_IP
	$ColorRect/VBoxContainer/PortEdit.text = str(Network.DEFAULT_PORT)

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
