#board.gd
extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18

const UNIT = preload("res://unit.tscn")
const TANK = preload("res://Assets/P1Tank.png")
const TEXTURE_HOLDER = preload("res://texture_holder.tscn")
@onready var input_handler: Node2D = $"../InputHandler"

#Variables
#negative numbers are black pieces 
# 
var state: bool = true

var board: Array
var units: Array
#Signal to these
var P1_submitted: bool
var P2_submitted: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spawn_unit(1,"Tank", Vector2(0,0),["N","W","S"])
	#board_edge.connect("mouse_entered", mouse_is_over)
	#board_edge.connect("mouse_exited", mouse_is_not_over)
	for i in BOARD_SIZE:
		board.append([null,null,null,null,null,null,null,null])

	#input_handler.connect("both_players_submitted", self, "_on_both_players_submitted")
	spawn_unit(1,"TANK", Vector2(2,2), ["N","W","S"])
	spawn_unit(1,"MAN", Vector2(1,2), ["N","W","S"])
	spawn_unit(2,"PENIS", Vector2(7,6), ["N","W","S"])
	spawn_unit(1,"ASDF", Vector2(7,7), ["N","W","S"])
	execute_orders(board, units)
	
	display_board()
	

func _on_both_players_submitted():
	print("Both players have submitted their orders!")
	# Now you can handle the next steps, like starting the next phase of the game
	# For example, you could transition to the next round, update the board, etc.
	# Here, we will just print and call a function to process orders.
	process_orders()
	
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
	var unit_instance = Unit.new(team, unitType, boardPosition, orders)
	board[boardPosition.x][boardPosition.y] = unit_instance
	units.append(unit_instance)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		pass
		
func validate_move(unit, board, move):
	if unit.boardPosition.x + move.x>=BOARD_SIZE or unit.boardPosition.y + move.y>=BOARD_SIZE or unit.boardPosition.x + move.x<0 or unit.boardPosition.x + move.x<0:
		print("Out of Bounds")
		return false
	if board[unit.boardPosition.x + move.x][unit.boardPosition.y + move.y]:
		print("Occupied Space")
		return false
	print("Unit Moved Successfully")
	return true

func execute_order(unit, board):
	#print("from: " + str(unit.boardPosition))
	match unit.orders[0]:
		"Move_N":
			if validate_move(unit, board, Vector2(0,1)):
				unit.boardPosition += Vector2(0,1)
		"Move_S":
			if validate_move(unit, board, Vector2(0,-1)):
				unit.boardPosition += Vector2(0,-1)
		"Move_E":
			if validate_move(unit, board, Vector2(1,0)):
				unit.boardPosition += Vector2(1,0)
		"Move_W":
			if validate_move(unit, board, Vector2(-1,0)):
				unit.boardPosition += Vector2(-1,0)
				
	unit.orders.pop_front()
	#print("to: " + str(unit.boardPosition))
	return [unit, board]
	
			
func execute_orders(board: Array, units: Array):
	for unit in units:
		execute_order(unit, board)
	
	
func display_board() -> void:
	
	for unit in units:
		var textureHolder = TEXTURE_HOLDER.instantiate()
		$UnitSprites.add_child(textureHolder)
		textureHolder.position = boardPositionToLocalPosition(unit.boardPosition)
		textureHolder.texture = TANK 
			#match board[i][j].unitType:
				#"Tank": holder.texture = TANK
				#-5: holder.texture = BLACK_QUEEN
				#-4: holder.texture = BLACK_ROOK
				#-3: holder.texture = BLACK_BISHOP
				#-2: holder.texture = BLACK_KNIGHT
				#-1: holder.texture = BLACK_PAWN
				#0: holder.texture = null
				#1: holder.texture = WHITE_PAWN
				#2: holder.texture = WHITE_KNIGHT
				#3: holder.texture = WHITE_BISHOP
				#4: holder.texture = WHITE_ROOK
				#5: holder.texture = WHITE_QUEEN
				#6: holder.texture = WHITE_KING
