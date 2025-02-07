extends Unit
class_name Wall

const UNIT_SPRITE = preload("res://Assets/Unit_Sprites/Wall.png")

var order_movement_map = {
	"N": Vector2(0, 0), "E": Vector2(0, 0), "S": Vector2(0, 0), "W": Vector2(0, 0),
	"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
}
var attack_map = {
	"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0), 
	"X": Vector2.ZERO
}

func execute_order() -> void:
	var move_vector = Vector2.ZERO
	board.register_movement(self, board_position + move_vector)
	

	
