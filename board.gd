# board.gd
extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18
const SPAWN_POSITIONS: Array = [Vector2(0, 0), Vector2(7, 7)]
const TWEEN_TIME = 0.7
signal turn_completed

const UNIT = preload("res://unit.tscn")
@onready var terrain: Node2D = $Terrain
const ResourceNode = preload("res://resource_node.gd")
const TEXTURE_HOLDER = preload("res://texture_holder.tscn")
@onready var input_handler: Node2D = $"../InputHandler"

var state: bool = true
var units: Array
var P1_submitted: bool
var P2_submitted: bool
var planned_moves: Dictionary = {}
var planned_abilities: Dictionary = { 
	"Captures": [],
	"Walls": [],
	"Attacks": [] 
}
var vacated_spaces: Array = []

func _ready() -> void:
	#spawn_unit(1, "Worker", Vector2(0, 0), ["AS", "W", "S"])
	#spawn_unit(0, "Worker", Vector2(7,7), ["AS", "W", "S"])
	#spawn_unit(0, "Soldier", Vector2(1, 1), ["E", "W", "S"])
	#spawn_unit(0, "Archer", Vector2(2, 2), ["S", "W", "S"])
	#spawn_unit(0, "Mage", Vector2(5, 5), ["N", "W", "S"])
	#perform_turn()
	input_handler.connect("both_players_submitted", perform_turn)
	#capture_space(units[0])

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
	if unitType == "":
		return
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

func capture_space(unit: Unit) -> void:
	var space = unit.boardPosition
	if terrain.is_resource_node(unit.boardPosition):
		for instance in terrain.terrain:
			if unit.team == 0 and instance.boardPosition == space:
				instance.set_state(ResourceNode.State.PLAYER_0)
			elif unit.team == 1 and instance.boardPosition == space:
				instance.set_state(ResourceNode.State.PLAYER_1)

func attack_space(target_space: Vector2) -> void:
	for unit in units:
		if unit.boardPosition == target_space:
			unit.is_alive = false
			#units.remove_at(i)  # Remove from the array

func process_killed_units() -> void:
	for i in range(units.size() - 1, -1, -1):  # Iterate from last to first
		if units[i].is_alive == false:
			units[i].queue_free()
			units.remove_at(i)  # Remove from the array


func destroy_terrain(target_space: Vector2) -> void:
	for i in range(terrain.terrain.size() - 1, -1, -1):
		if terrain.terrain[i].boardPosition == target_space:
			terrain.terrain[i].queue_free()
			terrain.terrain.remove_at(i)

func resolve_abilities():
	pass

func perform_abilities():
	pass

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
	#upgrades phase upgrade cost = current memory
	for playerIndex in range(players.size()): 
		if input_handler.players[playerIndex].is_upgrading_memory:
			input_handler.players[playerIndex].money -= input_handler.players[playerIndex].memory
			input_handler.players[playerIndex].memory += 1
	
	#captures phase
	for unit in units:
		if unit.orders.size() > 0:
			if unit.orders[0].length() == 2 and unit.unitType == "Worker":
				capture_space(unit)
				register_move(unit, unit.boardPosition)
				unit.has_registered_move = true
	#walls phase
	for unit in units:
		if unit.orders.size() > 0:
			if unit.orders[0].length() == 2 and unit.unitType == "Builder":
				if unit.orders[0] == "AN": 
					if not is_space_occupied(unit.boardPosition + Vector2(0,1)):
						spawn_unit(-1, "Wall", unit.boardPosition + Vector2(0,1), ["X", "X", "X"])
				if unit.orders[0] == "AE": 
					if not is_space_occupied(unit.boardPosition + Vector2(1,0)):
						spawn_unit(-1, "Wall", unit.boardPosition + Vector2(1,0), ["X", "X", "X"])
				if unit.orders[0] == "AS": 
						if not is_space_occupied(unit.boardPosition + Vector2(0,-1)):
							spawn_unit(-1, "Wall", unit.boardPosition + Vector2(0,-1), ["X", "X", "X"])
				if unit.orders[0] == "AW": 
					if not is_space_occupied(unit.boardPosition + Vector2(-1,0)):	
						spawn_unit(-1, "Wall", unit.boardPosition + Vector2(-1,0), ["X", "X", "X"])
				register_move(unit, unit.boardPosition)
				unit.has_registered_move = true
	# TODO:attacks phase (hard)
	for unit in units:
		if unit.orders.size() > 0:
			if unit.orders[0].length() == 2:
				if unit.unitType == "Soldier":
					var target_space = unit.boardPosition + unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					attack_space(target_space)
				if unit.unitType == "Archer":
					var arrow = true
					var arrowDirection = unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					var arrowPosition = unit.boardPosition + unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					while arrow == true:
						if is_space_occupied(arrowPosition):
							attack_space(arrowPosition)
							arrow = false
						if not unit.is_within_board(arrowPosition):
							arrow = false
						arrowPosition += arrowDirection
				if unit.unitType == "Mage":
					var magic = true
					var magicDirection = unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					var magicPosition = unit.boardPosition + unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					while magic == true:
						if is_space_occupied(magicPosition):
							attack_space(magicPosition)
							magic = false
						if not unit.is_within_board(magicPosition):
							magic = false
						magicPosition += magicDirection
					
				if unit.unitType == "Spy":
					destroy_terrain(unit.boardPosition)
				unit.orders.pop_front()
				register_move(unit, unit.boardPosition)
				unit.has_registered_move = true
	#process killed units
	process_killed_units()
	#move phase
	for unit in units:
		if unit.orders.size() > 0:
			if unit.orders[0].length() == 1:
				unit.execute_move_order()
	if all_units_registered():
		resolve_moves()
	spawn_unit(0, players[0].selectedUnit, SPAWN_POSITIONS[0], players[0].orders)
	spawn_unit(1, players[1].selectedUnit, SPAWN_POSITIONS[1], players[1].orders)
	#check victory condition phase
	var winner = 0
	for unit in units:
		if unit.boardPosition == Vector2(7,7) and unit.team == 0:
			winner += 1
		if unit.boardPosition == Vector2(0,0) and unit.team == 1:
			winner += 1
	#print(winner)
	winner = 0
	#clear units without orders phase
	for i in range(units.size() - 1, -1, -1):  # Iterate from last to first
		if units[i].orders.size() == 0:
			units[i].queue_free()
			units.remove_at(i)  # Remove from the array
	for playerIndex in range(players.size()):
		pass
		#print(terrain.get_resource_node_count(playerIndex))
		input_handler.players[playerIndex].money += 1 + terrain.get_resource_node_count(playerIndex)
		input_handler.players[playerIndex].income = 1 + terrain.get_resource_node_count(playerIndex)
		#print("ADDED MONEY TO PLAYER %d" % playerIndex)
	emit_signal("turn_completed")
