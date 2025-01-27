#board.gd
extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18
const SPAWN_POSITIONS: Array = [Vector2(0,0), Vector2(7,7)]
const TWEEN_TIME = 0.7
signal turn_completed

const UNIT = preload("res://unit.tscn")
const TANK = preload("res://Assets/P1Tank.png")
const TEXTURE_HOLDER = preload("res://texture_holder.tscn")
@onready var input_handler: Node2D = $"../InputHandler"

#Variables
#negative numbers are black pieces 
# 
var state: bool = true

#var board: Array
var units: Array
#Signal to these
var P1_submitted: bool
var P2_submitted: bool


var planned_moves: Dictionary = {}  # { target_space: [units_attempting_to_move] }
var vacated_spaces: Array = []  # Spaces that will be vacated this turn


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#input_handler.connect("both_players_submitted", _process_turn)

	spawn_unit(0,"Worker", Vector2(0,0), ["N", "W","S"])
	spawn_unit(0,"Soldier", Vector2(1,1), ["E","W","S"])
	spawn_unit(0,"Archer", Vector2(2,2), ["S","W","S"])
	spawn_unit(0,"Mage", Vector2(5,5), ["N","W","S"])
	perform_turn()
	
	
func _process(delta: float) -> void:
	pass

#func _process_turn(players):
	#print("Both players have submitted their orders!")
	#perform_turn()
	##for unit in units:
		##unit.execute_move_order()
	#for playerIndex in range(players.size()):
		#print(playerIndex)
		##spawn_unit(1,"Worker", Vector2(0,0), ["N"])
		#spawn_unit(playerIndex, players[playerIndex].selectedUnit, SPAWN_POSITIONS[playerIndex], players[playerIndex].orders)

func process_orders():
	# Implement the logic for processing orders after both players have submitted
	# This could involve updating the game state, processing actions, etc.
	pass
	
func boardPositionToLocalPosition(boardPosition: Vector2):
	var localPosition = Vector2(0,0)
	@warning_ignore("integer_division")
	localPosition.x = boardPosition.x * CELL_WIDTH + CELL_WIDTH/2 - 4 * CELL_WIDTH
	@warning_ignore("integer_division")
	localPosition.y = -boardPosition.y * CELL_WIDTH - CELL_WIDTH/2 + 4 * CELL_WIDTH
	return localPosition

func localPositionToBoardPosition(localPosition: Vector2):
	var boardPosition = Vector2(0,0)
	boardPosition.x = localPosition.x / CELL_WIDTH + 3.5
	boardPosition.y = -localPosition.y / CELL_WIDTH + 3.5
	return boardPosition


func spawn_unit(team: int, unitType: String, boardPosition: Vector2, orders: Array):
	#check if space unoccupied
	#var unit_instance = Unit.new(team, unitType, boardPosition, orders)
	var unit_instance = UNIT.instantiate()
	unit_instance.initialize(team, unitType, boardPosition, orders)
	unit_instance.position = boardPositionToLocalPosition(boardPosition)
	units.append(unit_instance)
	$Units.add_child(unit_instance)
	#print(unit_instance.state)
	

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		pass

# Registers a move attempt for a unit
func register_move(unit: Unit, target_position: Vector2) -> void:
	if !planned_moves.has(target_position):
		planned_moves[target_position] = []
	planned_moves[target_position].append(unit)

	# Add the unit's current position to vacated spaces if not already present
	if unit.boardPosition not in vacated_spaces:
		vacated_spaces.append(unit.boardPosition)

	# Check if all units have registered their moves, then resolve conflicts
	if all_units_registered():
		print("All units reg")
		resolve_moves()

# Resolves planned moves, handles conflicts, and updates unit positions
func resolve_moves() -> void:
	for target_position in planned_moves.keys():
		var units = planned_moves[target_position]

		if units.size() == 1:
			# No conflict: perform the move
			perform_move(units[0], target_position)
		else:
			# Conflict: no units move
			for unit in units:
				unit.emit_signal("move_completed")

	# Clear tracking data for the next turn
	planned_moves.clear()
	vacated_spaces.clear()


# Moves a unit to the target position
func perform_move(unit: Unit, target_position: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(unit, "position", boardPositionToLocalPosition(target_position), Unit.TWEEN_TIME)
	unit.boardPosition = target_position
	unit.emit_signal("move_completed")

# Checks if a space is occupied, considering vacated spaces
func is_space_occupied(space: Vector2) -> bool:
	if space in vacated_spaces:
		return false
	for unit in units:
		if unit.boardPosition == space:
			return true
	return false

# Determines if all units have registered their moves
func all_units_registered() -> bool:
	for unit in units:
		print("Unit " + str(unit) + " has " + str(unit.has_registered_move) + " registered first move.")  # Debug
		if not unit.has_registered_move:
			return false
	return true



# Executes one turn
# Executes one turn
func perform_turn() -> void:
	# Each unit executes only its first move order
	for unit in units:
		if unit.orders.size() > 0:
			unit.execute_move_order()
	
	## After resolving moves, handle abilities or additional actions
	#for unit in units:
		#unit.execute_ability_order()
	
	# After all units register their moves, resolve them
	# This will resolve conflicts (e.g., two units moving to the same space)
	if all_units_registered():
		resolve_moves()
	# Emit a signal when all moves and abilities are completed
	emit_signal("turn_completed")


#func display_board() -> void:
	#
	#for unit in units:
		#var textureHolder = TEXTURE_HOLDER.instantiate()
		#$UnitSprites.add_child(textureHolder)
		#textureHolder.position = boardPositionToLocalPosition(unit.boardPosition)
		#textureHolder.texture = TANK
