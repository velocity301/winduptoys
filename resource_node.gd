extends Sprite2D

var boardPosition: Vector2
enum State {UNCAPTURED, PLAYER_0, PLAYER_1}
var current_state = State.UNCAPTURED
# Called when the node enters the scene tree for the first time.

func initialize(boardPosition) -> void:
	self.boardPosition = boardPosition
	set_state(State.UNCAPTURED)
	
func set_state(new_state):
	current_state = new_state
	match current_state:
		State.UNCAPTURED:
			modulate = Color(1, 1, 1)  # White
		State.PLAYER_0:
			modulate = Color(0, 0, 1)  # Blue
		State.PLAYER_1:
			modulate = Color(1, 0, 0)  # Red
