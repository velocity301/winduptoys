extends Unit
class_name Worker

const UNIT_SPRITE = preload("res://Assets/Unit_Sprites/Soldier.png")

var order_movement_map = {
	"N": Vector2(0, 1), "E": Vector2(1, 0), "S": Vector2(0, -1), "W": Vector2(-1, 0),
	"AN": Vector2(0, 1), "AE": Vector2(1, 0), "AS": Vector2(0, -1), "AW": Vector2(-1, 0),
}

func execute_order() -> void:
	var current_order = orders.pop_front()
	var move_vector = order_movement_map.get(current_order, Vector2.ZERO)
	board.register_movement(self, order_movement_map[current_order])
	if current_order.size() == "AN":
		board.attack_space(self.board_position + Vector2(0,1))
	elif current_order.size() == "AE":
		board.attack_space(self.board_position + Vector2(1,0))
	elif current_order.size() == "AS":
		board.attack_space(self.board_position + Vector2(0,-1))
	elif current_order.size() == "AW":
		board.attack_space(self.board_position + Vector2(-1,0))
