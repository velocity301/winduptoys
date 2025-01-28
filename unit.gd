# unit.gd
extends Node2D

class_name Unit
const TWEEN_TIME = 0.7
@onready var board = $"/root/Main/Board"
signal move_completed
# Unit properties
var state: String
var team: int
var unitType: String
var boardPosition: Vector2
var orders: Array = []
var is_alive: bool
var has_registered_move: bool

# Movement directions and abilities for each unit type
const UNIT_ORDERS = {
	"Worker": {
		"N": Vector2(0, 1), "E": Vector2(1, 0), "S": Vector2(0, -1), "W": Vector2(-1, 0),
		"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
	},
	"Soldier": {
		"N": Vector2(0, 1), "E": Vector2(1, 0), "S": Vector2(0, -1), "W": Vector2(-1, 0),
		"AN": Vector2(0, 1), "AE": Vector2(1, 0), "AS": Vector2(0, -1), "AW": Vector2(-1, 0),
	},
	"Archer": {
		"N": Vector2(0, 1), "E": Vector2(1, 0), "S": Vector2(0, -1), "W": Vector2(-1, 0),
		"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
	},
	"Mage": {
		"N": Vector2(-1, 1), "E": Vector2(1, 1), "S": Vector2(1, -1), "W": Vector2(-1, -1),
		"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
	},
	"Spy": {
		"N": Vector2(0, 2), "E": Vector2(2, 0), "S": Vector2(0, -2), "W": Vector2(-2, 0),
		"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
	},
	"Builder": {
		"N": Vector2(0, 1), "E": Vector2(1, 0), "S": Vector2(0, -1), "W": Vector2(-1, 0),
		"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
	}
}

func initialize(team: int, unitType: String, board_position: Vector2, orders: Array):
	self.state = "IDLE"
	self.team = team
	self.unitType = unitType
	self.boardPosition = board_position
	self.orders = orders
	self.is_alive = true
	has_registered_move = false

func _ready():
	board.connect("turn_completed", _on_all_moves_completed)

func execute_ability_order() -> void:
	if self.unitType == "Worker":
		pass  # Placeholder for Worker-specific actions

func execute_move_order() -> void:
	var current_order = orders[0]
	var move_vector = UNIT_ORDERS[unitType].get(current_order, Vector2.ZERO)
	var target_position = boardPosition + move_vector
	var local_target_position = board.boardPositionToLocalPosition(target_position)
	if not is_within_board(target_position):
		target_position = boardPosition
	board.register_move(self, target_position)
	orders.pop_front()
	self.has_registered_move = true

func is_space_occupied(space: Vector2) -> bool:
	return board.is_space_occupied(space)

func is_within_board(board_position: Vector2) -> bool:
	return board_position.x >= 0 and board_position.x < board.BOARD_SIZE and board_position.y >= 0 and board_position.y < board.BOARD_SIZE



func _on_all_moves_completed():
	self.has_registered_move = false
	self.state = "IDLE"
