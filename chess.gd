extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18

const UNIT = preload("res://unit.tscn")
const TANK = preload("res://Assets/P1Tank.png")
const TEXTURE_HOLDER = preload("res://texture_holder.tscn")
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

	spawn_unit(1,"TANK", Vector2(2,2), ["Move_N","Move_W","Move_S"])
	spawn_unit(1,"MAN", Vector2(1,2), ["Move_N","Move_W","Move_S"])
	spawn_unit(2,"PENIS", Vector2(7,6), ["Move_N","Move_W","Move_S"])
	spawn_unit(1,"ASDF", Vector2(7,7), ["Move_N","Move_W","Move_S"])
	execute_orders(board, units)
	
	display_board()
	
		
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
