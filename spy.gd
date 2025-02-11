extends Unit
class_name Spy

const UNIT_SPRITE = preload("res://Assets/Unit_Sprites/Spy.png")

var order_movement_map = {
	"N": Vector2(0, 2), "E": Vector2(2, 0), "S": Vector2(0, -2), "W": Vector2(-2, 0),
	"AN": Vector2(0, 2), "AE": Vector2(2, 0), "AS": Vector2(0, -2), "AW": Vector2(-2, 0),
}
var attack_map = {
	"AN": Vector2(0, 1), "AE": Vector2(1, 0), "AS": Vector2(0, -1), "AW": Vector2(-1, 0),
}

func execute_order() -> void:
	var current_order = orders.pop_front()
	var move_vector = order_movement_map.get(current_order, Vector2.ZERO)
	board.register_movement(self, board_position + move_vector)
	if current_order.length() == 2:
		print("SPY ABILITY")
		#destroy_terrain(self.board_position + attack_map[current_order])
	
