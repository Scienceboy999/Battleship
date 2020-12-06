extends TileMap

export var NUKEFRAMES:int = 10
export var WATERFRAMES:int = 10
export var EXPLOSIONFRAMES:int = 10

func nuke(coord:Vector2) -> void:
	for i in range(NUKEFRAMES):
		set_cell(coord.x,coord.y,i)
		yield(get_tree().create_timer(0.1),"timeout")
	set_cell(coord.x,coord.y,-1)

func waterSplash(coord:Vector2) -> void:
	$Splash.play()
	for i in range(NUKEFRAMES+EXPLOSIONFRAMES,NUKEFRAMES + EXPLOSIONFRAMES + WATERFRAMES):
		set_cell(coord.x,coord.y,i)
		yield(get_tree().create_timer(0.1),"timeout")
	set_cell(coord.x,coord.y,-1)

func explosionSplash(coord:Vector2) -> void:
	$Explosion.play()
	for i in range(NUKEFRAMES,NUKEFRAMES + EXPLOSIONFRAMES):
		set_cell(coord.x,coord.y,i)
		yield(get_tree().create_timer(0.1),"timeout")
	set_cell(coord.x,coord.y,-1)
