extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18

const TEXTURE_HOLDER = preload("res://texture_holder.tscn")

const BLACK_BISHOP = preload("res://Chess/black_bishop.png")
const BLACK_KING = preload("res://Chess/black_king.png")
const BLACK_KNIGHT = preload("res://Chess/black_knight.png")
const BLACK_PAWN = preload("res://Chess/black_pawn.png")
const BLACK_QUEEN = preload("res://Chess/black_queen.png")
const BLACK_ROOK = preload("res://Chess/black_rook.png")
const TURN_BLACK = preload("res://Chess/turn-black.png")
const TURN_WHITE = preload("res://Chess/turn-white.png")
const WHITE_BISHOP = preload("res://Chess/white_bishop.png")
const WHITE_KING = preload("res://Chess/white_king.png")
const WHITE_KNIGHT = preload("res://Chess/white_knight.png")
const WHITE_PAWN = preload("res://Chess/white_pawn.png")
const WHITE_QUEEN = preload("res://Chess/white_queen.png")
const WHITE_ROOK = preload("res://Chess/white_rook.png")

#Variables
#negative numbers are black pieces 
# 6 = King
# 5 = Queen
# 4 = Rook
# 3 = Bishop
# 2 = Knight
# 1 = Pawn 
# 0 = Empty Square

var board: Array
var is_white_turn: bool
var state: bool
var moves = []
var selected_piece: Vector2
var is_mouse_over: bool


@onready var pieces: Node2D = $Pieces
@onready var dots: Node2D = $Dots
@onready var turn: Sprite2D = $Turn
@onready var board_edge: Area2D = $BoardEdge


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_edge.connect("mouse_entered", mouse_is_over)
	board_edge.connect("mouse_exited", mouse_is_not_over)
	board.append([4,2,3,5,6,3,2,4])
	board.append([1,1,1,1,1,1,1,1])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([-1,-1,-1,-1,-1,-1,-1,-1])
	board.append([-4,-2,-3,-5,-6,-3,-2,-4])
	display_board()

func mouse_is_over():
	is_mouse_over = true
	
func mouse_is_not_over():
	is_mouse_over = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_over:
				var var1 = $BoardEdge.get_local_mouse_position()
				print(var1)
			else:
				return


func display_board() -> void:
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			#holder.global_position = Vector2(j * CELL_WIDTH + CELL_WIDTH/2, i * CELL_WIDTH - CELL_WIDTH/2)
			holder.position = Vector2(j * CELL_WIDTH + CELL_WIDTH/2, -i * CELL_WIDTH - CELL_WIDTH/2)
			match board[i][j]:
				-6: holder.texture = BLACK_KING
				-5: holder.texture = BLACK_QUEEN
				-4: holder.texture = BLACK_ROOK
				-3: holder.texture = BLACK_BISHOP
				-2: holder.texture = BLACK_KNIGHT
				-1: holder.texture = BLACK_PAWN
				0: holder.texture = null
				1: holder.texture = WHITE_PAWN
				2: holder.texture = WHITE_KNIGHT
				3: holder.texture = WHITE_BISHOP
				4: holder.texture = WHITE_ROOK
				5: holder.texture = WHITE_QUEEN
				6: holder.texture = WHITE_KING
				

	
