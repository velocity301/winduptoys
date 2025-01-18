extends Node2D


#signal p1 and p2 ready (unit(args), unit(args))
const PLAYER = preload("res://player.tscn")
const P1_SPAWN_POSITION: Vector2 = Vector2(0,0)
const P2_SPAWN_POSITION: Vector2 = Vector2(7,7)
const PLAYERCOUNT: int = 2
var players: Array = []
var units = {
	"N": "Unit 1",
	"E": "Unit 2",
	"S": "Unit 3",
	"W": "Unit 4",
	"N2": "Unit 5",
	"E2": "Unit 6",
	"S2": "Unit 7",
	"W2": "Unit 8"
}

# "InputMapAction": ["ActionFunction","arg1", "arg2"]
var action_mapping = {
	"Test Action": ["test_action", "Do this"],
	"Select Unit N": ["select_unit", units["N"]],
	"Select Unit E": ["select_unit", units["E"]],
	"Select Unit S": ["select_unit", units["S"]],
	"Select Unit W": ["select_unit", units["W"]],
	"Select Unit N2": ["select_unit", units["N2"]],
	"Select Unit E2": ["select_unit", units["E2"]],
	"Select Unit S2": ["select_unit", units["S2"]],
	"Select Unit W2": ["select_unit", units["W2"]],
	"Clear Orders": ["clear_orders"]
}



func _input(event):
	var playerIndex = event.device
	if event.is_action_pressed("Test Action"):
		test_action(playerIndex, "testing 123")
	if event.is_action_pressed("Select Unit N"):
		select_unit(playerIndex, units)
	#for action in action_mapping.keys():
		#if event.is_action_pressed(action):
			#var func_name = action_mapping[action][0]
			#var args = [action_mapping[action]]
			#call(func_name, playerIndex, args) #arg for arg in args)
	#for action in action_mapping.keys():
		#if event.is_action_pressed(action):  
			#var playerIndex = event.device
			#var func_name = action_mapping[action][0]
			#var arg = action_mapping[action][1]
			## Use call() to dynamically call the function
			#call(func_name, playerIndex, arg)
			#print_gamestate(players, playerIndex)
			#break

func test_action(playerIndex, action):
	print(playerIndex)
	print(action)

#Actions
func select_unit(playerIndex, unit: String):
	players[playerIndex] = unit

func upgrade(playerIndex):
	if players[playerIndex].money > players[playerIndex].upgradeTier + 1:
		players[playerIndex].upgradeTier += 1
	else:
		print("Insufficient Funds to Upgrade")

func add_order(playerIndex, order: String):
	if players[playerIndex].orders > players[playerIndex].memory:
		print("Memory Full")
	else:
		players[playerIndex].orders.append(order)

func clear_orders(playerIndex):
	players[playerIndex].orders = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	for player in range(PLAYERCOUNT): 
		players.append(Player.new(units))

func print_gamestate(players, playerIndex):
	for player in players:
		var outputString = ""
		outputString+=str("Submitted: ")
		outputString+=str(players[playerIndex].submitted)+"\n"
		outputString+=str("Unit Type: ")
		outputString+=str(players[playerIndex].unitType)+"\n"
		outputString+=str("Orders: ")
		outputString+=str(players[playerIndex].orders)+"\n"
		outputString+=str("Income: ")
		outputString+=str(players[playerIndex].income)+"\n"
		outputString+=str("Money: ")
		outputString+=str(players[playerIndex].money)+"\n"
		outputString+=str("Memory: ")
		outputString+=str(players[playerIndex].memory)+"\n"
		outputString+=str("Upgrade Tier: ")
		outputString+=str(players[playerIndex].upgradeTier)+"\n"
		outputString+=str("is Upgrading: ")
		outputString+=str(players[playerIndex].is_upgrading)+"\n"
		print(outputString)
