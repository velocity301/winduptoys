extends Node2D


#signal p1 and p2 ready (unit(args), unit(args))
const PLAYER = preload("res://player.tscn")
const P1_SPAWN_POSITION: Vector2 = Vector2(0,0)
const P2_SPAWN_POSITION: Vector2 = Vector2(7,7)
const PLAYERCOUNT: int = 2
const UPGRADE_COST = 1
const UNIT_COSTS = [0,1,2,3,4,5,6]

var players: Array = []

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
	if event.is_action_pressed("Test Action"):
		test_action(playerIndex, "testing 123")
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
	if event.is_action_pressed("Upgrade Memory"):
		upgrade_memory(event.device)
	if event.is_action_pressed("Submit Move"):
		submit_move(event.device)
		
	
		#select_unit(playerIndex, units)
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
func select_unit(playerIndex, unit: int):
	var availableMoney = players[playerIndex].money - players[playerIndex].currentlySpending
	if availableMoney < UNIT_COSTS[unit]:
		print("insufficient funds")
		return
	if players[playerIndex].state == "SELECTING_UNIT":
		players[playerIndex].selectedUnit = players[playerIndex].unitDeck[str(unit)]
		players[playerIndex].currentlySpending += UNIT_COSTS[unit]
		players[playerIndex].state = "ISSUING_ORDERS"
	else: 
		print("not in correct state")

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
	if players[playerIndex].state == "INPUT_DISABLED":
		return
	players[playerIndex].submitted = true
	players[playerIndex].state = "INPUT_DISABLED"
	# signal saying player is submitted

func add_order(playerIndex, order: String):
	if players[playerIndex].orders > players[playerIndex].memory:
		print("Memory Full")
	else:
		players[playerIndex].orders.append(order)

func clear_orders(playerIndex):
	players[playerIndex].orders = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player1 = Player.new()
	var player2 = Player.new()
	players.append(player1)
	players.append(player2)
	#for player in range(PLAYERCOUNT): 
		#players.append(Player.new(units))

func print_gamestate():
	for playerIndex in range(2):
		print(playerIndex)
		#print("submitted: %s" % players[playerIndex].submitted)
		#print("state: %s" % players[playerIndex].state)
		#print("selectedUnit: %s" % players[playerIndex].selectedUnit)
		#print("orders: %s" % str(players[playerIndex].orders))
		#print("income: %d" % players[playerIndex].income)
		#print("money: %d" % players[playerIndex].money)
		#print("memory: %d" % players[playerIndex].memory)
		print("is_upgrading_memory: %s" % players[playerIndex].is_upgrading_memory)
		#print("currentlySpending:  %s" % players[playerIndex].currentlySpending)
		 #print("researchingUnit: %s" % players[playerIndex].researchingUnit)
