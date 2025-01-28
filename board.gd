# board.gd
extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18
const SPAWN_POSITIONS: Array = [Vector2(0, 0), Vector2(7, 7)]
const TWEEN_TIME = 0.7
signal turn_completed

const UNIT = preload("res://unit.tscn")
const TANK = preload("res://Assets/P1Tank.png")
const TEXTURE_HOLDER = preload("res://texture_holder.tscn")
@onready var input_handler: Node2D = $"../InputHandler"

var state: bool = true
var units: Array
var P1_submitted: bool
var P2_submitted: bool
var planned_moves: Dictionary = {}
var vacated_spaces: Array = []

func _ready() -> void:
	pass
	#spawn_unit(0, "Worker", Vector2(0, 0), ["W", "W", "S"])
	#spawn_unit(0, "Soldier", Vector2(1, 1), ["E", "W", "S"])
	#spawn_unit(0, "Archer", Vector2(2, 2), ["S", "W", "S"])
	#spawn_unit(0, "Mage", Vector2(5, 5), ["N", "W", "S"])
	#perform_turn()
	input_handler.connect("both_players_submitted", perform_turn)

func boardPositionToLocalPosition(boardPosition: Vector2) -> Vector2:
	var localPosition = Vector2(0, 0)
	localPosition.x = boardPosition.x * CELL_WIDTH + CELL_WIDTH / 2 - 4 * CELL_WIDTH
	localPosition.y = -boardPosition.y * CELL_WIDTH - CELL_WIDTH / 2 + 4 * CELL_WIDTH
	return localPosition

func localPositionToBoardPosition(localPosition: Vector2) -> Vector2:
	var boardPosition = Vector2(0, 0)
	boardPosition.x = localPosition.x / CELL_WIDTH + 3.5
	boardPosition.y = -localPosition.y / CELL_WIDTH + 3.5
	return boardPosition

func spawn_unit(team: int, unitType: String, boardPosition: Vector2, orders: Array) -> void:
	var unit_instance = UNIT.instantiate()
	unit_instance.initialize(team, unitType, boardPosition, orders)
	unit_instance.position = boardPositionToLocalPosition(boardPosition)
	units.append(unit_instance)
	$Units.add_child(unit_instance)

func register_move(unit: Unit, target_position: Vector2) -> void:
	if !planned_moves.has(target_position):
		planned_moves[target_position] = []
	planned_moves[target_position].append(unit)

	if unit.boardPosition not in vacated_spaces:
		vacated_spaces.append(unit.boardPosition)

	if all_units_registered():
		resolve_moves()

func resolve_moves() -> void:
	for target_position in planned_moves.keys():
		var units = planned_moves[target_position]
		if units.size() == 1:
			perform_move(units[0], target_position)
		else:
			for unit in units:
				unit.emit_signal("move_completed")
	planned_moves.clear()
	vacated_spaces.clear()

func perform_move(unit: Unit, target_position: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(unit, "position", boardPositionToLocalPosition(target_position), Unit.TWEEN_TIME)
	unit.boardPosition = target_position
	unit.emit_signal("move_completed")

func is_space_occupied(space: Vector2) -> bool:
	if space in vacated_spaces:
		return false
	for unit in units:
		if unit.boardPosition == space:
			return true
	return false


func all_units_registered() -> bool:
	for unit in units:
		if not unit.has_registered_move:
			return false
	return true

func perform_turn(players) -> void:
	for unit in units:
		if unit.orders.size() > 0:
			unit.execute_move_order()
	if all_units_registered():
		resolve_moves()
	spawn_unit(0, players[0].selectedUnit, SPAWN_POSITIONS[0], players[0].orders)
	spawn_unit(1, players[1].selectedUnit, SPAWN_POSITIONS[1], players[1].orders)
	emit_signal("turn_completed")
