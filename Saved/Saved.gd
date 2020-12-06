extends Node

var saveData:Dictionary = {}
const SAVEGAME:String = "user://Savegame.json"
const defaultDic:Dictionary = {
	"playerName":"Unnamed",
	"IP":Network.DEFAULT_IP,
	"port":Network.DEFAULT_PORT,
	"masterVolume":-20,
	"sfxVolume":-20
	}

func _ready() -> void:
	saveData = getData()

func getData() -> Dictionary:
	var file:File = File.new()
	if !file.file_exists(SAVEGAME):
		saveData = defaultDic
		saveGame()
	file.open(SAVEGAME,File.READ)
	var content:String = file.get_as_text()
	var data = parse_json(content)
	saveData = data
	file.close()
	
	for key in defaultDic.keys():
		if !saveData.has(key):
			saveData[key] = defaultDic[key]
			saveGame()
	
	return data

func saveGame() -> void:
	var saveGame:File = File.new()
	saveGame.open(SAVEGAME,File.WRITE)
	saveGame.store_line(to_json(saveData))
	saveGame.close()
