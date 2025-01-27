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
var has_registered_move: bool
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
	has_registered_move = false
	
func _ready():
	board.connect("turn_completed", _on_all_moves_completed)

# Executes ability orders (placeholder for specific logic)
func execute_ability_order() -> void:
	if self.unitType == "Worker":
		pass  # Capture the mine or perform other actions

# Registers the move order with the board
func execute_move_order() -> void:
	if orders.size() == 0:
		emit_signal("move_completed")
		return

	# Only process the first order
	if orders.size() > 0:
		var current_order = orders[0]  # Get the first order
		print("Executing move order: " + current_order)  # Debug

		var move_vector = UNIT_ORDERS[unitType].get(current_order, Vector2.ZERO)
		print("Move vector: " + str(move_vector))  # Debug

		var target_position = boardPosition + move_vector
		print("Target position (board): " + str(target_position))  # Debug

		# Convert to local position
		var local_target_position = board.boardPositionToLocalPosition(target_position)
		print("Target position (local): " + str(local_target_position))  # Debug

		# Register the move with the board
		board.register_move(self, target_position)

		# Remove the first order after it's executed
		orders.pop_front()  # Remove the first order
		print("Remaining orders: " + str(orders))  # Debug
		self.has_registered_move = true
	else:
		print("No orders to execute.")


# Checks if a space is occupied (considering vacated spaces from the board)
func is_space_occupied(space: Vector2) -> bool:
	return board.is_space_occupied(space)

func _on_all_moves_completed():
	self.has_registered_move = false
	self.state = "SELECTING_UNIT"

# Signal emitted when a move is completed
signal move_completed
