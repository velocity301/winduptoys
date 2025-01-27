# unit.gd
extends Node2D

class_name Unit
const TWEEN_TIME = 0.7
@onready var board = $"/root/Main/Board"

# Properties for the unit
var state: String
var team: int
var unitType: String
var boardPosition: Vector2
var orders: Array = []
var is_alive: bool
const UNIT_ORDERS = {
	 "Worker": {
		"N": Vector2(0, 1),
		"E": Vector2(1, 0),
		"S": Vector2(0, -1),
		"W": Vector2(-1, 0),
		"AN": Vector2(0, 0),
		"AE": Vector2(0, 0),
		"AS": Vector2(0, 0),
		"AW": Vector2(0, 0),
	},
	"Soldier": {
		"N": Vector2(0, 1),
		"E": Vector2(1, 0),
		"S": Vector2(0, -1),
		"W": Vector2(-1, 0),
		"AN": Vector2(0, 1),
		"AE": Vector2(1, 0),
		"AS": Vector2(0, -1),
		"AW": Vector2(-1, 0),
	},
	"Archer": {
		"N": Vector2(0, 1),
		"E": Vector2(1, 0),
		"S": Vector2(0, -1),
		"W": Vector2(-1, 0),
		"AN": Vector2(0, 0),
		"AE": Vector2(0, 0),
		"AS": Vector2(0, 0),
		"AW": Vector2(0, 0),
	},
	"Mage": {
		"N": Vector2(-1, 1),  # Diagonal up-left
		"E": Vector2(1, 1),   # Diagonal up-right
		"S": Vector2(1, -1),  # Diagonal down-right
		"W": Vector2(-1, -1), # Diagonal down-left
		"AN": Vector2(0, 0),
		"AE": Vector2(0, 0),
		"AS": Vector2(0, 0),
		"AW": Vector2(0, 0),
	},
	"Spy": {
		"N": Vector2(0, 2),
		"E": Vector2(2, 0),
		"S": Vector2(0, -2),
		"W": Vector2(-2, 0),
		"AN": Vector2(0, 0),
		"AE": Vector2(0, 0),
		"AS": Vector2(0, 0),
		"AW": Vector2(0, 0),
	},
	"Builder": {
		"N": Vector2(0, 1),
		"E": Vector2(1, 0),
		"S": Vector2(0, -1),
		"W": Vector2(-1, 0),
		"AN": Vector2(0, 0),
		"AE": Vector2(0, 0),
		"AS": Vector2(0, 0),
		"AW": Vector2(0, 0),
	}
}

#func _init(
	#team: int,
	#unitType: String, 
	#board_position: Vector2, 
	#orders: Array):
	#self.state = "IDLE"
	#self.team = team
	#self.unitType = unitType
	#self.boardPosition = board_position
	#self.orders = orders
	#self.is_alive = true
	
func initialize(
	team: int,
	unitType: String, 
	board_position: Vector2, 
	orders: Array):
	self.state = "IDLE"
	self.team = team
	self.unitType = unitType
	self.boardPosition = board_position
	self.orders = orders
	self.is_alive = true
	

func _ready() -> void:
	pass
	
	
func execute_ability_order():
	if self.unitType == "Worker":
		pass # capture the mine underneath the worker

func execute_move_order():
	var tween = create_tween()
	var startPosition = board.boardPositionToLocalPosition(self.boardPosition)
	var current_order = self.orders[0]
	var move_vector = UNIT_ORDERS[self.unitType][current_order]
	var target_position = self.boardPosition + move_vector
	# TODO: check inbetween path squares here
	if is_space_occupied(target_position): 
		self.orders.pop_front()
		return
	tween.tween_property(self, "position", board.boardPositionToLocalPosition(target_position), TWEEN_TIME)
	self.boardPosition = target_position	
	self.orders.pop_front()


func is_space_occupied(space: Vector2) -> bool:
	for unit in board.units:
		if unit.boardPosition == space:
			print(str(unit.boardPosition) + " is occupied")
			return true
	return false
