extends Node2D


const RESOURCE_CHANCE = 0.25
const MINIMUM_RESOURCE_NODES = 6
const RESOURCE_NODE = preload("res://resource_node.tscn")
const resource_node_script = preload("res://resource_node.gd")
@onready var board = $"/root/Main/Board"
var resource_map: Array = []
var terrain: Array

func _ready() -> void:
	generate_map()
	create_terrain(resource_map)


#func _process(delta: float) -> void:
	#pass

func generate_map():
	resource_map = []
	var resource_count = 0
	for i in range(board.BOARD_SIZE):  # Use `i` for rows
		var row = []
		for j in range(board.BOARD_SIZE):  # Use `j` for columns
			row.append(false)  # Initialize with `false`
		resource_map.append(row)  # Add row to the resource map
	
	while resource_count < MINIMUM_RESOURCE_NODES / 2:
		resource_count = 0
		# Populate the board with resources
		for x in range(board.BOARD_SIZE):
			for y in range(board.BOARD_SIZE/2):
				if randf() < RESOURCE_CHANCE:
					resource_map[x][y] = true
					resource_count += 1
	# Apply rotational symmetry: for each (x, y), mirror it to (BOARD_SIZE - 1 - x, BOARD_SIZE - 1 - y)
	for x in range(board.BOARD_SIZE):
		for y in range(board.BOARD_SIZE):
			if resource_map[x][y]:
				resource_map[board.BOARD_SIZE - 1 - x][board.BOARD_SIZE - 1 - y] = true

func create_terrain(resource_map):
	for i in range(board.BOARD_SIZE):
		for j in range(board.BOARD_SIZE):
			var board_position = Vector2(i,j)
			if resource_map[i][j] == true:
				var resource_instance = RESOURCE_NODE.instantiate()
				resource_instance.initialize(board_position)
				resource_instance.position = board.board_to_local_pos(board_position)
				terrain.append(resource_instance) 
				self.add_child(resource_instance)
			else:
				pass

func is_resource_node(space: Vector2):
	for node in terrain:
		if node.board_position == space:
			return true
	return false
	
func get_resource_node_count(playerIndex):
	if playerIndex == 0:
		var count = 0
		for node in terrain: 
			if node.current_state == resource_node_script.State.PLAYER_0:
				count += 1
		return count
	elif playerIndex == 1:
		var count = 0 
		for node in terrain:
			if node.current_state == resource_node_script.State.PLAYER_1:
				count += 1
		return count
func print_resource_map():
	for row in resource_map:
		print(row)
	
