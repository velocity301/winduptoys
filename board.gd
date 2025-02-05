# board.gd
extends Sprite2D

const BOARD_SIZE = 5
const CELL_WIDTH = 36
const SPAWN_POSITIONS: Array = [Vector2(0, 0), Vector2(4, 4)]
const TWEEN_TIME = 0.7
const UNIT = preload("res://unit.tscn")
const RESOURCE_NODE = preload("res://resource_node.gd")
const TEXTURE_HOLDER = preload("res://texture_holder.tscn")

signal turn_completed

@onready var terrain: Node2D = $Terrain
@onready var input_handler: Node2D = $"../InputHandler"

var state: bool = true
var units: Array
var P1_submitted: bool
var P2_submitted: bool
var planned_moves: Dictionary = {}
var vacated_spaces: Array = []

func _ready() -> void:
	input_handler.connect("both_players_submitted", perform_turn)

func board_to_local_pos(board_position: Vector2) -> Vector2:
	var local_position = Vector2.ZERO
	local_position.x = (board_position.x - 2) * CELL_WIDTH
	local_position.y = -(board_position.y - 2) * CELL_WIDTH
	return local_position

func local_to_board_pos(local_position: Vector2) -> Vector2:
	var board_position = Vector2.ZERO
	board_position.x = (local_position.x / CELL_WIDTH) + 2
	board_position.y = (-local_position.y / CELL_WIDTH) + 2
	return board_position




func spawn_unit(team: int, unit_type: String, board_position: Vector2, orders: Array) -> void:
	if unit_type == "":
		return
	destroy_unit(SPAWN_POSITIONS[team])
	
	var unit_class = load("res://" + unit_type.to_lower() + ".tscn")
	if unit_class == null:
		print("Unit class not found for type: ", unit_type)
		return
	var unit_instance = unit_class.instantiate()
	unit_instance.initialize(team, unit_type, board_position, orders)
	unit_instance.position = board_to_local_pos(board_position)
	units.append(unit_instance)
	$Units.add_child(unit_instance)

func register_movement(unit: Unit, target_position: Vector2) -> void:
	if !planned_moves.has(target_position):
		planned_moves[target_position] = []
	planned_moves[target_position].append(unit)

	if unit.board_position not in vacated_spaces:
		vacated_spaces.append(unit.board_position)

	if all_units_registered():
		resolve_moves()

func resolve_moves() -> void:
	for target_position in planned_moves.keys():
		@warning_ignore("shadowed_variable")
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
	tween.tween_property(unit, "position", board_to_local_pos(target_position), Unit.TWEEN_TIME)
	unit.board_position = target_position
	unit.emit_signal("move_completed")

func capture_space(unit: Unit) -> void:
	var space = unit.board_position
	if terrain.is_resource_node(unit.board_position):
		for instance in terrain.terrain:
			if unit.team == 0 and instance.board_position == space:
				instance.set_state(RESOURCE_NODE.State.PLAYER_0)
			elif unit.team == 1 and instance.board_position == space:
				instance.set_state(RESOURCE_NODE.State.PLAYER_1)

func attack_space(target_space: Vector2) -> void:
	for unit in units:
		if unit.board_position == target_space:
			unit.is_alive = false
			print(target_space)
			#units.remove_at(i)  # Remove from the array

func destroy_unit(target_space: Vector2) -> void:
	for i in range(units.size()):
		var unit = units[i]
		if unit.board_position == target_space:
			unit.queue_free() 
			units.remove_at(i) 
			break

func draw_arrow_line(start_pos, end_pos, team):
	var line = Line2D.new()
	line.width = 3
	if team == 0:
		line.default_color = Color(0, 1, 0)
	elif team == 1: 
		line.default_color = Color(1, 0, 0)
	line.add_point(board_to_local_pos(start_pos))
	line.add_point(board_to_local_pos(end_pos))
	self.add_child(line)
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	self.add_child(timer)
	timer.start()
	timer.timeout.connect(
		func():
		line.queue_free()
		timer.queue_free()
		)
		
func process_killed_units() -> void:
	for i in range(units.size() - 1, -1, -1):  # Iterate from last to first
		if units[i].is_alive == false:
			units[i].queue_free()
			units.remove_at(i)  # Remove from the array


func destroy_terrain(target_space: Vector2) -> void:
	for i in range(terrain.terrain.size() - 1, -1, -1):
		if terrain.terrain[i].board_position == target_space:
			terrain.terrain[i].queue_free()
			terrain.terrain.remove_at(i)

func is_space_occupied_movement(space: Vector2) -> bool:
	if space in vacated_spaces:
		return false
	for unit in units:
		if unit.board_position == space:
			return true
	return false

func is_space_occupied_ability(space: Vector2) -> bool:
	for unit in units:
		if unit.board_position == space:
			return true
	return false

func is_space_occupied_resource(space: Vector2): # -> bool:
	pass # TODO

func all_units_registered() -> bool:
	for unit in units:
		if not unit.has_registered_order:
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
		if unit.unit_type == "Worker":
			unit.execute_order()
		
		#if unit.orders.size() > 0:
			#if unit.orders[0].length() == 2 and unit.unitType == "Worker":
				#capture_space(unit)
				#register_move(unit, unit.board_position)
				#unit.has_registered_order = true
	#walls phase
	for unit in units:
		if unit.orders.size() > 0:
			if unit.orders[0].length() == 2 and unit.unitType == "Builder":
				if unit.orders[0] == "AN": 
					if not is_space_occupied_movement(unit.board_position + Vector2(0,1)):
						spawn_unit(-1, "Wall", unit.board_position + Vector2(0,1), ["X", "X", "X"])
				if unit.orders[0] == "AE": 
					if not is_space_occupied_movement(unit.board_position + Vector2(1,0)):
						spawn_unit(-1, "Wall", unit.board_position + Vector2(1,0), ["X", "X", "X"])
				if unit.orders[0] == "AS": 
						if not is_space_occupied_movement(unit.board_position + Vector2(0,-1)):
							spawn_unit(-1, "Wall", unit.board_position + Vector2(0,-1), ["X", "X", "X"])
				if unit.orders[0] == "AW": 
					if not is_space_occupied_movement(unit.board_position + Vector2(-1,0)):	
						spawn_unit(-1, "Wall", unit.board_position + Vector2(-1,0), ["X", "X", "X"])
				register_movement(unit, unit.board_position)
				unit.has_registered_order = true
	# TODO:attacks phase (hard)
	for unit in units:
		if unit.orders.size() > 0:
			if unit.orders[0].length() == 2:
				if unit.unitType == "Soldier":
					var target_space = unit.board_position + unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					attack_space(target_space)
					
				if unit.unitType == "Archer":
					var arrow = true
					var arrowDirection = unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					var arrowPosition = unit.board_position + unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					while arrow == true:
						if is_space_occupied_ability(arrowPosition):
							attack_space(arrowPosition)
							arrow = false
						if not unit.is_within_board(arrowPosition):
							arrow = false
						arrowPosition += arrowDirection
					draw_arrow_line(unit.board_position, arrowPosition, unit.team)
				if unit.unitType == "Mage":
					var magic = true
					var magicDirection = unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					var magicPosition = unit.board_position + unit.UNIT_ORDERS[unit.unitType][unit.orders[0]]
					while magic == true:
						print(magicPosition)
						if is_space_occupied_ability(magicPosition):
							attack_space(magicPosition)
							magic = false
						if not unit.is_within_board(magicPosition):
							magic = false
						magicPosition += magicDirection
					print(magicPosition)
					draw_arrow_line(unit.board_position, magicPosition, unit.team)
				if unit.unitType == "Spy":
					destroy_terrain(unit.board_position)
				unit.orders.pop_front()
				register_movement(unit, unit.board_position)
				unit.has_registered_order = true
	#process killed units
	process_killed_units()
	#move phase
	for unit in units:
		if unit.orders.size() > 0:
			if unit.orders[0].length() == 1:
				unit.execute_move_order()
	if all_units_registered():
		resolve_moves()
	#spawn units
	spawn_unit(0, players[0].selectedUnit, SPAWN_POSITIONS[0], players[0].orders)
	spawn_unit(1, players[1].selectedUnit, SPAWN_POSITIONS[1], players[1].orders)
	#check victory condition phase
	@warning_ignore("unused_variable")
	var winner = 0
	for unit in units:
		if unit.board_position == Vector2(7,7) and unit.team == 0:
			winner += 1
		if unit.board_position == Vector2(0,0) and unit.team == 1:
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
