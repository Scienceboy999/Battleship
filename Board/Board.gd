extends Node2D

onready var Water:TileMap = $Water

export var waterFrames:int = 10

var size:int = 10

func _ready() -> void:
	Water.clear()
	randomize()
	for x in range(size):
		for y in range(size):
			Water.set_cell(x,y,randi() % waterFrames)
