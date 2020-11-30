extends Node2D

var size:int = 10
var time:int = 3

onready var P1Boats:TileMap = $P1Panel/P1Board/Boats
onready var P2Boats:TileMap = $P2Panel/P2Board/Boats
onready var P1Markers:TileMap = $P1Panel/P1Markers
onready var P2Markers:TileMap = $P2Panel/P2Markers
onready var P1Cursor:TileMap = $P2Panel/P1Cursor
onready var P2Cursor:TileMap = $P1Panel/P2Cursor
onready var P1FireEffect:TileMap = $P1Panel/P1FireEffects
onready var P2FireEffect:TileMap = $P2Panel/P2FireEffects

sync var P1BoatsDic:Dictionary = {0:{"startPos":Vector2(-1,-1),"rotated":false},1:{"startPos":Vector2(-1,-1),"rotated":false},2:{"startPos":Vector2(-1,-1),"rotated":false},3:{"startPos":Vector2(-1,-1),"rotated":false},4:{"startPos":Vector2(-1,-1),"rotated":false}}
sync var P2BoatsDic:Dictionary = {0:{"startPos":Vector2(-1,-1),"rotated":false},1:{"startPos":Vector2(-1,-1),"rotated":false},2:{"startPos":Vector2(-1,-1),"rotated":false},3:{"startPos":Vector2(-1,-1),"rotated":false},4:{"startPos":Vector2(-1,-1),"rotated":false}}

var p1ID:int = 1
var p2ID:int 

var host:bool = Network.local_player_id == 1
sync var P1turn:bool
var firePos:Vector2
var gameOver:bool = false

func _ready() -> void:
	for playerID in Network.players:
		if playerID == 1:
			$ControlPanel/P1NameLabel.text = Network.players[playerID]["name"]
		else:
			$ControlPanel/P2NameLabel.text = Network.players[playerID]["name"]
			p2ID = playerID
	if host:
		CalcBoatPositions()
	
	if host:
		rset("P1turn",randi() % 2 == 0)
		rpc("turnChanged")
		$P1Panel/P2Fire.visible = false
	else:
		$P2Panel/P1Fire.visible = false

func _physics_process(delta: float) -> void:
	if gameOver:
		return
	
	if host:
		rpc_unreliable("updateTimer",$ControlPanel/Timer.time_left)
	
	if Input.is_action_just_pressed("leftClick"):
		if host && P1turn:
			var mousePos:Vector2 = get_global_mouse_position() - P1Cursor.global_position
			var tilePos:Vector2 = P1Cursor.world_to_map(mousePos)
			if tilePos.x >= 0 && tilePos.x < size && tilePos.y >= 0 && tilePos.y < size && P2Markers.get_cell(tilePos.x,tilePos.y) == -1:
				P1Cursor.clear()
				P1Cursor.set_cell(tilePos.x,tilePos.y,0)
				firePos = Vector2(tilePos.x,tilePos.y)
		elif !host && !P1turn:
			var mousePos:Vector2 = get_global_mouse_position() - P2Cursor.global_position
			var tilePos:Vector2 = P2Cursor.world_to_map(mousePos)
			if tilePos.x >= 0 && tilePos.x < size && tilePos.y >= 0 && tilePos.y < size && P1Markers.get_cell(tilePos.x,tilePos.y) == -1:
				P2Cursor.clear()
				P2Cursor.set_cell(tilePos.x,tilePos.y,0)
				firePos = Vector2(tilePos.x,tilePos.y)

sync func updateTimer(val:float) -> void:
	$ControlPanel/TimeLabel.text = "%d seconds left"%val

sync func turnChanged() -> void:
	firePos = Vector2(-1,-1)
	P1Cursor.clear()
	P2Cursor.clear()
	if host:
		$ControlPanel/Timer.stop()
		$ControlPanel/Timer.wait_time = time * 60
		$ControlPanel/Timer.start()
	
	if P1turn && !gameOver:
		$P1Panel/P2Fire.disabled = true
		$P2Panel/P1Fire.disabled = false
		$ControlPanel/TurnLabel.text = "%s 's turn"%Network.players[1]["name"]
	elif !P1turn && !gameOver:
		$P1Panel/P2Fire.disabled = false
		$P2Panel/P1Fire.disabled = true
		$ControlPanel/TurnLabel.text = "%s 's turn"%Network.players[p2ID]["name"]

remote func CalcBoatPositions() -> void:
	var p1boatFlags = [Vector2(-1,-1),Vector2(-1,-1),Vector2(-1,-1),Vector2(-1,-1),Vector2(-1,-1)]
	var p2boatFlags = [Vector2(-1,-1),Vector2(-1,-1),Vector2(-1,-1),Vector2(-1,-1),Vector2(-1,-1)]
	for x in range(size):
		for y in range(size):
			if Network.players[p1ID]["boats"][x][y] != -1:
				if p1boatFlags[Network.players[p1ID]["boats"][x][y]] != Vector2(-2,-2):
					if p1boatFlags[Network.players[p1ID]["boats"][x][y]] == Vector2(-1,-1):
						p1boatFlags[Network.players[p1ID]["boats"][x][y]] = Vector2(x,y)
					else:
						var rotated:bool 
						if p1boatFlags[Network.players[p1ID]["boats"][x][y]].x == x:
							rotated = true
						else:
							rotated = false
						P1BoatsDic[Network.players[p1ID]["boats"][x][y]]["startPos"] = p1boatFlags[Network.players[p1ID]["boats"][x][y]]
						P1BoatsDic[Network.players[p1ID]["boats"][x][y]]["rotated"] = rotated
						p1boatFlags[Network.players[p1ID]["boats"][x][y]] = Vector2(-2,-2)
			if Network.players[p2ID]["boats"][x][y] != -1:
				if p2boatFlags[Network.players[p2ID]["boats"][x][y]] != Vector2(-2,-2):
					if p2boatFlags[Network.players[p2ID]["boats"][x][y]] == Vector2(-1,-1):
						p2boatFlags[Network.players[p2ID]["boats"][x][y]] = Vector2(x,y)
					else:
						var rotated:bool 
						if p2boatFlags[Network.players[p2ID]["boats"][x][y]].x == x:
							rotated = true
						else:
							rotated = false
						P2BoatsDic[Network.players[p2ID]["boats"][x][y]]["startPos"] = p2boatFlags[Network.players[p2ID]["boats"][x][y]]
						P2BoatsDic[Network.players[p2ID]["boats"][x][y]]["rotated"] = rotated
						p2boatFlags[Network.players[p2ID]["boats"][x][y]] = Vector2(-2,-2)
	rset("P1BoatsDic",P1BoatsDic)
	rset("P2BoatsDic",P2BoatsDic)
	rpc("displayMyBoats")

sync func displayMyBoats() -> void:
	if Network.local_player_id == 1:
		for i in range(5):
			if P1BoatsDic[i]["rotated"]:
				P1Boats.set_cellv(P1BoatsDic[i]["startPos"],i,true,false,true)
			else:
				P1Boats.set_cellv(P1BoatsDic[i]["startPos"],i)
	else:
		for i in range(5):
			if P2BoatsDic[i]["rotated"]:
				P2Boats.set_cellv(P2BoatsDic[i]["startPos"],i,true,false,true)
			else:
				P2Boats.set_cellv(P2BoatsDic[i]["startPos"],i)

sync func displayAllBoats() -> void:
	for i in range(5):
			if P1BoatsDic[i]["rotated"]:
				P1Boats.set_cellv(P1BoatsDic[i]["startPos"],i,true,false,true)
			else:
				P1Boats.set_cellv(P1BoatsDic[i]["startPos"],i)
			
			if P2BoatsDic[i]["rotated"]:
				P2Boats.set_cellv(P2BoatsDic[i]["startPos"],i,true,false,true)
			else:
				P2Boats.set_cellv(P2BoatsDic[i]["startPos"],i)

func _on_P2Fire_pressed() -> void:
	if firePos == Vector2(-1,-1):
		return
	
	rpc_id(1,"fire",firePos)

func _on_P1Fire_pressed() -> void:
	if firePos == Vector2(-1,-1):
		return
	
	fire(firePos)

func _on_Timer_timeout() -> void:
	rset("P1turn",P1turn)
	rpc("turnChanged")

remote func fire(coord:Vector2) -> void:
	if P1turn:
		if Network.players[p2ID]["boats"][coord.x][coord.y] != -1:
			rpc("setMarker",1,0,coord)
			if checkSunk(1,Network.players[p2ID]["boats"][coord.x][coord.y]):
				var i:int = Network.players[p2ID]["boats"][coord.x][coord.y]
				setBoat(p1ID,i)
				rpc("displaySunk",p1ID,i)
				checkWin()
			rpc("fireEffect",p1ID,0,coord)
		else:
			rpc("setMarker",1,1,coord)
			rpc("fireEffect",p1ID,1,coord)
	else:
		if Network.players[p1ID]["boats"][coord.x][coord.y] != -1:
			rpc("setMarker",p2ID,0,coord)
			if checkSunk(p2ID,Network.players[p1ID]["boats"][coord.x][coord.y]):
				var i:int = Network.players[p1ID]["boats"][coord.x][coord.y]
				rpc_id(p2ID,"setBoat",p2ID,i)
				rpc("displaySunk",p2ID,i)
				checkWin()
			rpc("fireEffect",p2ID,0,coord)
		else:
			rpc("setMarker",p2ID,1,coord)
			rpc("fireEffect",p2ID,1,coord)
	
	rset("P1turn",!P1turn)
	rpc("turnChanged")
 
func checkWin() -> void:
	var P1:bool = true
	var P2:bool = true
	
	for i in range(5):
		if !checkSunk(1,i):
			P1 = false
	
	for i in range(5):
		if !checkSunk(p2ID,i):
			P2 = false
	
	if P1:
		rpc("gameOver",Network.players[p1ID]["name"])
	if P2:
		rpc("gameOver",Network.players[p2ID]["name"])

sync func gameOver(name:String) -> void:
	$ControlPanel/TurnLabel.text = "%s WINS!!!!!!!!!!!!!"%name
	$ControlPanel/TimeLabel.text = ""
	displayAllBoats()
	$P1Panel/P2Fire.disabled = true
	$P2Panel/P1Fire.disabled = true
	gameOver = true
	if host:
		$ControlPanel/Timer.stop()
		$ControlPanel/RestartButton.visible = true
		$ControlPanel/BackToLobbyButton.visible = true

remote func setBoat(id:int,i:int) -> void:
	if id == 1:
		if P2BoatsDic[i]["rotated"]:
			P2Boats.set_cellv(P2BoatsDic[i]["startPos"],i,true,false,true)
		else:
			P2Boats.set_cellv(P2BoatsDic[i]["startPos"],i)
	else:
		if P1BoatsDic[i]["rotated"]:
			P1Boats.set_cellv(P1BoatsDic[i]["startPos"],i,true,false,true)
		else:
			P1Boats.set_cellv(P1BoatsDic[i]["startPos"],i)

sync func setMarker(id:int,type:int,coord:Vector2) -> void:
	if id == 1:
		P2Markers.set_cellv(coord,type)
	else:
		P1Markers.set_cellv(coord,type)

sync func fireEffect(id:int,type:int,coord:Vector2) -> void:
	if id == 1:
		yield(P2FireEffect.nuke(coord),"completed")
		if type == 0:
			yield(P2FireEffect.explosionSplash(coord),"completed")
		else:
			yield(P2FireEffect.waterSplash(coord),"completed")
	else:
		yield(P1FireEffect.nuke(coord),"completed")
		if type == 0:
			yield(P1FireEffect.explosionSplash(coord),"completed")
		else:
			yield(P1FireEffect.waterSplash(coord),"completed")

sync func displaySunk(playerID:int,i:int) -> void:
	if playerID == 1:
		match i:
			0: 
				$P2Panel/P2PatrolBoatDisplay.modulate = Color(1,0,0,0.3)
			1:
				$P2Panel/P2SubmarineDisplay.modulate = Color(1,0,0,0.3)
			2:
				$P2Panel/P2DestroyerDisplay.modulate = Color(1,0,0,0.3)
			3:
				$P2Panel/P2BattleshipDisplay.modulate = Color(1,0,0,0.3)
			4:
				$P2Panel/P2CarrierDisplay.modulate = Color(1,0,0,0.3)
	else:
		match i:
			0:
				$P1Panel/P1PatrolBoatDisplay.modulate = Color(1,0,0,0.3)
			1:
				$P1Panel/P1SubmarineDisplay.modulate = Color(1,0,0,0.3)
			2:
				$P1Panel/P1DestroyerDisplay.modulate = Color(1,0,0,0.3)
			3:
				$P1Panel/P1BattleshipDisplay.modulate = Color(1,0,0,0.3)
			4:
				$P1Panel/P1CarrierDisplay.modulate = Color(1,0,0,0.3)

func checkSunk(id:int,index:int) -> bool:
	if id == 1:
		for x in range(size):
			for y in range(size):
				if Network.players[p2ID]["boats"][x][y] == index:
					if P2Markers.get_cell(x,y) != 0:
						return false
		return true
	else:
		for x in range(size):
			for y in range(size):
				if Network.players[p1ID]["boats"][x][y] == index:
					if P1Markers.get_cell(x,y) != 0:
						return false
		return true

func _on_RestartButton_pressed() -> void:
	Network.players[p1ID]["boats"] = null
	Network.players[p1ID]["finishedPlacing"] = false
	Network.players[p2ID]["boats"] = null
	Network.players[p2ID]["finishedPlacing"] = false
	rset("Network.players",Network.players)
	rpc("restart")

sync func restart() -> void:
	get_tree().change_scene("res://Placer/Placer.tscn")

func _on_BackToLobbyButton_pressed() -> void:
	rpc("backToLobby")

sync func backToLobby() -> void:
	get_tree().change_scene("res://Lobby/Lobby.tscn")


func _on_SettingsButton_pressed() -> void:
	$Settings.popup_centered()
