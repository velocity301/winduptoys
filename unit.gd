# unit.gd
extends Node2D

class_name Unit
const TWEEN_TIME = 0.7
@onready var board = $"/root/Main/Board"
@onready var unit_sprite: Sprite2D = $UnitSprite
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
const UNIT_SPRITES = {
	"Worker": preload("res://Assets/Unit_Sprites/Worker.png"),
	"Soldier": preload("res://Assets/Unit_Sprites/Soldier.png"),
	"Archer": preload("res://Assets/Unit_Sprites/Archer.png"),
	"Mage": preload("res://Assets/Unit_Sprites/Mage.png"),
	"Spy": preload("res://Assets/Unit_Sprites/Spy.png"),
	"Builder": preload("res://Assets/Unit_Sprites/Builder.png"),
	"Wall":preload("res://Assets/Unit_Sprites/Wall.png")
}
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
		"AN": Vector2(0, 1), "AE": Vector2(1, 0), "AS": Vector2(0, -1), "AW": Vector2(-1, 0),
	},
	"Mage": {
		"N": Vector2(1, 1), "E": Vector2(1, -1), "S": Vector2(-1, -1), "W": Vector2(-1, 1),
		"AN": Vector2(1, 1), "AE": Vector2(1, -1), "AS": Vector2(-1, -1), "AW": Vector2(-1, 1),
	},
	"Spy": {
		"N": Vector2(0, 2), "E": Vector2(2, 0), "S": Vector2(0, -2), "W": Vector2(-2, 0),
		"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
	},
	"Builder": {
		"N": Vector2(0, 1), "E": Vector2(1, 0), "S": Vector2(0, -1), "W": Vector2(-1, 0),
		"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
	},
	"Wall": {
		"X": Vector2(0,0)
	}
}

func initialize(team: int, unitType: String, board_position: Vector2, orders: Array):
	self.state = "IDLE"
	self.team = team
	self.unitType = unitType
	self.boardPosition = board_position
	self.orders = orders
	self.is_alive = true
	self.has_registered_move = false
	set_team_color(team)
	

func _ready():
	board.connect("turn_completed", _on_all_moves_completed)
	self.unit_sprite.texture = UNIT_SPRITES[unitType]

func set_team_color(team):
	var sprite = $UnitSprite  # Get the child node
	sprite.flip_h = (team == 1)
	if not sprite:
		print("ERROR: unit_sprite not found!")
		return

	# If sprite already has a material, create a duplicate
	if sprite.material and sprite.material is ShaderMaterial:
		sprite.material = sprite.material.duplicate(true)  # Deep copy to ensure a unique material
	
	var shader_material = sprite.material as ShaderMaterial
	if not shader_material:
		print("ERROR: unit_sprite does not have a ShaderMaterial!")
		return

	# Set the team color
	var new_color = Color(0, 1, 0, 1) if team == 0 else Color(1, 0, 0, 1)
	shader_material.set_shader_parameter("team_color", new_color)
	
	sprite.queue_redraw()  # Ensure the material updates

	
	shader_material.set_shader_parameter("team_color", new_color)
	print("Team color set to:", new_color)




func execute_ability_order() -> void:
	var current_order = orders[0]
	board.register_ability(self, current_order)
	orders.pop_front()
	self.has_registered_move = true
	#if self.unitType == "Worker":
		#
		##if worker is on resource node, change it to the player's
		#if self.boardPosition:
			#pass

func execute_move_order() -> void:
	var current_order = orders[0]
	var move_vector = UNIT_ORDERS[unitType].get(current_order, Vector2.ZERO)
	var target_position = boardPosition + move_vector
	var local_target_position = board.boardPositionToLocalPosition(target_position)
	if not is_within_board(target_position):
		target_position = boardPosition
	if not self.has_registered_move:
		board.register_move(self, target_position)
		orders.pop_front()
		self.has_registered_move = true

func is_space_occupied_movement(space: Vector2) -> bool:
	return board.is_space_occupied_movement(space)

func is_within_board(board_position: Vector2) -> bool:
	return board_position.x >= 0 and board_position.x < board.BOARD_SIZE and board_position.y >= 0 and board_position.y < board.BOARD_SIZE



func _on_all_moves_completed():
	self.has_registered_move = false
	self.state = "IDLE"
