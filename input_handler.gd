extends Node2D
#signal p1 and p2 ready (unit(args), unit(args))
var players = {}
var P1_submitted: bool
var P1_unit: String
const P1_POSITION: Vector2 = Vector2(0,0)
var P1_moves: Array

var P2_submitted: bool
var P2_unit: String
const P2_POSITION: Vector2 = Vector2(7,7)
var P2_moves: Array

func _input(event):
	var deviceId = event.device

	## Check to see that that event id on an action
	if not players.get(deviceId) and event.is_action_pressed("start"):
		print("player added")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(typeof(players))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
