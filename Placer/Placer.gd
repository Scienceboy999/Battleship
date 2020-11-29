extends Node2D

onready var Boats:TileMap = $Board/Boats
onready var BoatsPreview:TileMap = $Preview

var size:int = 10
var rotated:bool = false
var selected_boat:int = 0
var boatsSize:Array = [2,3,3,4,5]
var boats:Array

func _ready() -> void:
	$Control/Panel/DoneButton.disabled = true
	selected_boat = -1
	boats = []
	for x in range(size):
		boats.append([])
		boats[x] = []
		for y in range(size):
			boats[x].append([])
			boats[x][y] = -1

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("rotate"):
		rotated = !rotated
	elif Input.is_action_just_pressed("1") && !$Control/Panel/GridContainer/PlaceCarrier.disabled:
		_on_PlaceCarrier_pressed()
	elif Input.is_action_just_pressed("2") && !$Control/Panel/GridContainer/PlaceBattleShip.disabled:
		_on_PlaceBattleShip_pressed()
	elif Input.is_action_just_pressed("3") && !$Control/Panel/GridContainer/PlaceDestroyer.disabled:
		_on_PlaceDestroyer_pressed()
	elif Input.is_action_just_pressed("4") && !$Control/Panel/GridContainer/PlaceSubmarine.disabled:
		_on_PlaceSubmarine_pressed()
	elif Input.is_action_just_pressed("5") && !$Control/Panel/GridContainer/PlacePatrolBoat.disabled:
		_on_PlacePatrolBoat_pressed()

func _physics_process(delta: float) -> void:
	if selected_boat == -1:
		return
	
	var placement:Vector2
	if rotated:
		placement = (boatsSize[selected_boat] - 1) * Vector2(0,1)
	else:
		placement = (boatsSize[selected_boat] - 1) * Vector2(1,0)
	
	var mousePos:Vector2 = get_global_mouse_position()
	var tilePos:Vector2 = Boats.world_to_map(mousePos - Boats.global_position)
	
	BoatsPreview.clear()
	if validPlacement(tilePos,tilePos + placement):
		if rotated:
			BoatsPreview.set_cellv(tilePos,selected_boat,true,false,true)
		else:
			BoatsPreview.set_cellv(tilePos,selected_boat)
		
		if Input.is_action_just_pressed("leftClick"):
			if rotated:
				Boats.set_cellv(tilePos,selected_boat,true,false,true)
			else:
				Boats.set_cellv(tilePos,selected_boat)
			for x in range(tilePos.x,(tilePos + placement).x + 1):
				for y in range(tilePos.y,(tilePos + placement).y + 1):
					boats[x][y] = selected_boat
			match selected_boat:
				0:
					$Control/Panel/GridContainer/PlacePatrolBoat.disabled = true
				1:
					$Control/Panel/GridContainer/PlaceSubmarine.disabled = true
				2:
					$Control/Panel/GridContainer/PlaceDestroyer.disabled = true
				3:
					$Control/Panel/GridContainer/PlaceBattleShip.disabled = true
				4:
					$Control/Panel/GridContainer/PlaceCarrier.disabled = true
			selected_boat = -1
			checkDone()

func validPlacement(start:Vector2,end:Vector2) -> bool:
	for x in range(start.x,end.x + 1):
		for y in range(start.y,end.y + 1):
			if x < 0 || y < 0 || x >= size || y >= size:
				return false
			if boats[x][y] != -1:
				return false
	return true

func checkDone() -> void:
	if $Control/Panel/GridContainer/PlaceCarrier.disabled && $Control/Panel/GridContainer/PlaceBattleShip.disabled && $Control/Panel/GridContainer/PlaceDestroyer.disabled && $Control/Panel/GridContainer/PlaceSubmarine.disabled && $Control/Panel/GridContainer/PlacePatrolBoat.disabled :
		$Control/Panel/DoneButton.disabled = false
	else:
		$Control/Panel/DoneButton.disabled = true

func removeBoat(index:int) -> void:
	BoatsPreview.clear()
	var flag:bool = true
	for x in range(size):
		for y in range(size):
			if boats[x][y] == index:
				if flag:
					flag = false
					Boats.set_cell(x,y,-1)
					match index:
						0:
							$Control/Panel/GridContainer/PlacePatrolBoat.disabled = false
						1:
							$Control/Panel/GridContainer/PlaceSubmarine.disabled = false
						2:
							$Control/Panel/GridContainer/PlaceDestroyer.disabled = false
						3:
							$Control/Panel/GridContainer/PlaceBattleShip.disabled = false
						4:
							$Control/Panel/GridContainer/PlaceCarrier.disabled = false
				boats[x][y] = -1

func _on_PlaceAll_pressed() -> void:
	_on_ClearAll_pressed()
	for i in range(5):
		selected_boat = i
		var randomRotation:bool = randi() % 2 == 0
		var randomStartTile:Vector2 = Vector2(randi() % 10 , randi() % 10)
		var placement:Vector2
		if randomRotation:
			placement = (boatsSize[selected_boat] - 1) * Vector2(0,1)
		else:
			placement = (boatsSize[selected_boat] - 1) * Vector2(1,0)
		
		while !validPlacement(randomStartTile,randomStartTile + placement):
			randomRotation = randi() % 2 == 0
			randomStartTile = Vector2(randi() % 10 , randi() % 10)
			if randomRotation:
				placement = (boatsSize[selected_boat] - 1) * Vector2(0,1)
			else:
				placement = (boatsSize[selected_boat] - 1) * Vector2(1,0)
		
		if randomRotation:
			Boats.set_cellv(randomStartTile,selected_boat,true,false,true)
		else:
			Boats.set_cellv(randomStartTile,selected_boat)
		for x in range(randomStartTile.x,(randomStartTile + placement).x + 1):
			for y in range(randomStartTile.y,(randomStartTile + placement).y + 1):
				boats[x][y] = selected_boat
		match selected_boat:
			0:
				$Control/Panel/GridContainer/PlacePatrolBoat.disabled = true
			1:
				$Control/Panel/GridContainer/PlaceSubmarine.disabled = true
			2:
				$Control/Panel/GridContainer/PlaceDestroyer.disabled = true
			3:
				$Control/Panel/GridContainer/PlaceBattleShip.disabled = true
			4:
				$Control/Panel/GridContainer/PlaceCarrier.disabled = true
		selected_boat = -1
		checkDone()

func _on_ClearAll_pressed() -> void:
	for i in range(5):
		removeBoat(i)
	checkDone()

func _on_PlaceCarrier_pressed() -> void:
	selected_boat = 4
	rotated = false

func _on_ClearCarrier_pressed() -> void:
	selected_boat = -1
	removeBoat(4)
	checkDone()

func _on_PlaceBattleShip_pressed() -> void:
	selected_boat = 3
	rotated = false

func _on_ClearBattleship_pressed() -> void:
	selected_boat = -1
	removeBoat(3)
	checkDone()

func _on_PlaceDestroyer_pressed() -> void:
	selected_boat = 2
	rotated = false

func _on_ClearDestroyer_pressed() -> void:
	selected_boat = -1
	removeBoat(2)
	checkDone()

func _on_PlaceSubmarine_pressed() -> void:
	selected_boat = 1
	rotated = false

func _on_ClearSubmarine_pressed() -> void:
	selected_boat = -1
	removeBoat(1)
	checkDone()

func _on_PlacePatrolBoat_pressed() -> void:
	selected_boat = 0
	rotated = false

func _on_ClearPatrolBoat_pressed() -> void:
	selected_boat = -1
	removeBoat(0)
	checkDone()

func _on_DoneButton_pressed() -> void:
	$Control/Panel/WaitingLabel.visible = true
	$Control/Panel/DoneButton.disabled = true
	for child in $Control/Panel/GridContainer.get_children():
		if child is Button:
			child.disabled = true
	Network.finishedPlacing(boats)
