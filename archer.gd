extends Unit
class_name Archer

const UNIT_SPRITE = preload("res://Assets/Unit_Sprites/Archer.png")

var order_movement_map = {
	"N": Vector2(0, 1), "E": Vector2(1, 0), "S": Vector2(0, -1), "W": Vector2(-1, 0),
	"AN": Vector2(0, 0), "AE": Vector2(0, 0), "AS": Vector2(0, 0), "AW": Vector2(0, 0),
}
var attack_map = {
	"AN": Vector2(0, 1), "AE": Vector2(1, 0), "AS": Vector2(0, -1), "AW": Vector2(-1, 0),
}

func execute_order() -> void:
	var current_order = orders.pop_front()
	var move_vector = order_movement_map.get(current_order, Vector2.ZERO)
	board.register_movement(self, board_position + move_vector)
	if current_order.length() == 2:
		var projectile_position = self.board_position + attack_map[current_order]
		while board.is_within_board(projectile_position):
			if board.is_space_occupied(projectile_position):
				board.attack_space(projectile_position)
				#animate projectile
				break
			else:
				projectile_position += attack_map[current_order]
