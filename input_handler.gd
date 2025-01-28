extends Node2D

@onready var board: Sprite2D = $"../Board"

const PLAYER = preload("res://player.tscn")
const P1_SPAWN_POSITION: Vector2 = Vector2(0,0)
const P2_SPAWN_POSITION: Vector2 = Vector2(7,7)
const PLAYERCOUNT: int = 2
const UPGRADE_COST = 1
const UNIT_COSTS = [0,1,2,3,4,5,6]

var players: Array = []

signal both_players_submitted(players: Array)  # Declare a signal

# "InputMapAction": ["ActionFunction","arg1", "arg2"]
#var action_mapping = {
	#"Test Action": ["test_action", "Do this"],
	#"Select Unit N": ["select_unit", units["N"]],
	#"Select Unit E": ["select_unit", units["E"]],
	#"Select Unit S": ["select_unit", units["S"]],
	#"Select Unit W": ["select_unit", units["W"]],
	#"Select Unit N2": ["select_unit", units["N2"]],
	#"Select Unit E2": ["select_unit", units["E2"]],
	#"Select Unit S2": ["select_unit", units["S2"]],
	#"Select Unit W2": ["select_unit", units["W2"]],
	#"Clear Orders": ["clear_orders"]
#}


func _input(event):
	var playerIndex = event.device
	if players[event.device].state == "INPUT_DISABLED":
		return
	if players[event.device].state == "SELECTING_UNIT":
		if event.is_action_pressed("Select Unit 1"):
			select_unit(event.device, 1)
		if event.is_action_pressed("Select Unit 2"):
			select_unit(event.device, 2)
		if event.is_action_pressed("Select Unit 3"):
			select_unit(event.device, 3)
		if event.is_action_pressed("Select Unit 4"):
			select_unit(event.device, 4)
		if event.is_action_pressed("Select Unit 5"):
			select_unit(event.device, 5)
		if event.is_action_pressed("Select Unit 6"):
			select_unit(event.device, 6)
	elif players[event.device].state == "ISSUING_ORDERS":
		if event.is_action_pressed("Add Order N"):
			add_order(event.device, "N")
		if event.is_action_pressed("Add Order E"):
			add_order(event.device, "E")
		if event.is_action_pressed("Add Order S"):
			add_order(event.device, "S")
		if event.is_action_pressed("Add Order W"):
			add_order(event.device, "W")
		if event.is_action_pressed("Add Order AN"):
			add_order(event.device, "AN")
		if event.is_action_pressed("Add Order AE"):
			add_order(event.device, "AE")
		if event.is_action_pressed("Add Order AS"):
			add_order(event.device, "AS")
		if event.is_action_pressed("Add Order AW"):
			add_order(event.device, "AW")
	
	if event.is_action_pressed("Upgrade Memory"):
		upgrade_memory(event.device)
	if event.is_action_pressed("Submit Move"):
		submit_move(event.device)
	if event.is_action_pressed("Back"):
		back(event.device)
	

func test_action(playerIndex, action):
	print(playerIndex)
	print(action)

#Actions
func select_unit(playerIndex, unit: int):
	var availableMoney = players[playerIndex].money - players[playerIndex].currentlySpending
	if availableMoney < UNIT_COSTS[unit]:
		print("insufficient funds")
		return
	if players[playerIndex].state != "SELECTING_UNIT":
		print("not in correct state")
		return
	players[playerIndex].selectedUnit = players[playerIndex].unitDeck[str(unit)]
	players[playerIndex].currentlySpending += UNIT_COSTS[unit]
	players[playerIndex].state = "ISSUING_ORDERS"

	
func upgrade_memory(playerIndex):
	var availableMoney = players[playerIndex].money - players[playerIndex].currentlySpending
	if players[playerIndex].state == "INPUT_DISABLED":
		return
	if players[playerIndex].is_upgrading_memory == true:
		players[playerIndex].currentlySpending -= UPGRADE_COST
		players[playerIndex].is_upgrading_memory = false
	elif availableMoney >= UPGRADE_COST and players[playerIndex].is_upgrading_memory == false:
		players[playerIndex].currentlySpending += UPGRADE_COST
		players[playerIndex].is_upgrading_memory = true
	elif availableMoney < UPGRADE_COST:
		print("Insufficient Funds to Upgrade")

func submit_move(playerIndex):
	if players[playerIndex].state == "SUBMITTED_STANDBY" or players[playerIndex].state == "INPUT_DISABLED":
		return
	players[playerIndex].submitted = true
	players[playerIndex].state = "SUBMITTED_STANDBY"
	check_submissions()


func check_submissions():
	# Check if both players have submitted their orders
	print("Checking Submissions")
	if players[0].submitted and players[1].submitted:
		# Emit signal to notify the board that both players have submitted their orders
		players[0].state = "INPUT_DISABLED"
		players[1].state = "INPUT_DISABLED"
		both_players_submitted.emit(players)
		
	return

func add_order(playerIndex, order: String):
	if players[playerIndex].state != "ISSUING_ORDERS":
		return
	if players[playerIndex].orders.size() >= players[playerIndex].memory:
		print("Memory Full")
		return
	else:
		players[playerIndex].orders.append(order)

func back(playerIndex):
	if players[playerIndex].state == "SELECTING_UNIT":
		players[playerIndex].selectedUnit = ""
		players[playerIndex].is_upgrading_memory = false
		players[playerIndex].currentlySpending = 0
	elif players[playerIndex].state == "ISSUING_ORDERS":
		if players[playerIndex].orders == []:
			players[playerIndex].selectedUnit = ""
			players[playerIndex].is_upgrading_memory = false
			players[playerIndex].currentlySpending = 0
			players[playerIndex].state = "SELECTING_UNIT"
			return
		else:
			players[playerIndex].orders.pop_back()
		players[playerIndex].orders = []
	elif players[playerIndex].state == "SUBMITTED_STANDBY":
		players[playerIndex].state = "ISSUING_ORDERS"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Connect the turn_completed signal to a function in another script
	board.connect("turn_completed", _on_turn_completed)
	start_game()
	
	#connect("both_players_submitted", get_node("$../Board"), "_on_both_players_submitted")
	#for player in range(PLAYERCOUNT): 
		#players.append(Player.new(units))

func start_game():
	var player1 = Player.new()
	var player2 = Player.new()
	players.append(player1)
	players.append(player2)

	
func new_turn():
	players[0].submitted = false
	players[1].submitted = false
	players[0].state = "SELECTING_UNIT"
	players[1].state = "SELECTING_UNIT"
	players[0].reset_values()
	players[1].reset_values()	

func _on_turn_completed():
	print("Turn completed!")
	new_turn()
	# Handle any additional logic for after the turn ends (e.g., updating UI)



func print_gamestate():
	pass
	#for playerIndex in range(2):
		#print(playerIndex)
		#print("submitted: %s" % players[playerIndex].submitted)
		#print("state: %s" % players[playerIndex].state)
		#print("selectedUnit: %s" % players[playerIndex].selectedUnit)
		#print("orders: %s" % str(players[playerIndex].orders))
		#print("income: %d" % players[playerIndex].income)
		#print("money: %d" % players[playerIndex].money)
		#print("memory: %d" % players[playerIndex].memory)
		#print("is_upgrading_memory: %s" % players[playerIndex].is_upgrading_memory)
		#print("currentlySpending:  %s" % players[playerIndex].currentlySpending)
		 #print("researchingUnit: %s" % players[playerIndex].researchingUnit)
