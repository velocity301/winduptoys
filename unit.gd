# unit.gd
extends Node2D

class_name Unit

# Properties for the unit
@export var team: int
@export var unitType: String
@export var boardPosition: Vector2
@export var legalMoves: Array = []
@export var orders: Array = []
@export var is_alive: bool

func _init(
	team: int,
	unitType: String, 
	board_position: Vector2, 
	orders: Array):
	self.team = team
	self.unitType = unitType
	self.boardPosition = board_position
	self.orders = orders
	self.is_alive = true
	

#func _ready():
	#var sprite = Sprite2D.new() 
	#sprite.texture = load("res://Assets/%s.png" % unitType)
	#self.add_child(sprite)
