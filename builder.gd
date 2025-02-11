extends Unit
class_name Builder

const UNIT_SPRITE = preload("res://Assets/Unit_Sprites/Builder.png")

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
		var target_space = self.board_position + attack_map[current_order]
		if not board.is_space_occupied_ability(target_space):
			board.spawn_unit(self.team, "Wall", target_space, ["X"])

	
