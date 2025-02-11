extends Node2D

@onready var board: Sprite2D = $"../Board"
@onready var menu = $"../Menu"

const PLAYER = preload("res://player.tscn")
const P1_SPAWN_POSITION: Vector2 = Vector2(0,0)
const P2_SPAWN_POSITION: Vector2 = Vector2(7,7)
const PLAYERCOUNT: int = 2
const UPGRADE_COST = 1
const UNIT_COSTS = { 
	"Worker": 3, "Soldier": 5, "Archer": 8, "Mage": 13, "Spy": 13, "Builder": 8
	}

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

func get_player_index():
	var playerIndex
	if multiplayer.get_unique_id() == 1:
		playerIndex = 0 
	elif multiplayer.get_unique_id() != 1:
		playerIndex = 1
	return playerIndex
		
func _input(event):
	var playerIndex = get_player_index()
		
	#if event.is_action_pressed("PLAYER 2 FORCE END"):
		#submit_move(1)
	#if event.is_action_pressed("Test Action"):
		#test_action(playerIndex, "TEST")
		
	if players[playerIndex].state == "INPUT_DISABLED":
		return
	if players[playerIndex].state == "SELECTING_UNIT":
		if event.is_action_pressed("Select Unit 1"):
			select_unit(playerIndex, 1)
		if event.is_action_pressed("Select Unit 2"):
			select_unit(playerIndex, 2)
		if event.is_action_pressed("Select Unit 3"):
			select_unit(playerIndex, 3)
		if event.is_action_pressed("Select Unit 4"):
			select_unit(playerIndex, 4)
		if event.is_action_pressed("Select Unit 5"):
			select_unit(playerIndex, 5)
		if event.is_action_pressed("Select Unit 6"):
			select_unit(playerIndex, 6)
	elif players[playerIndex].state == "ISSUING_ORDERS":
		if event.is_action_pressed("Add Order N"):
			add_order(playerIndex, "N")
		if event.is_action_pressed("Add Order E"):
			add_order(playerIndex, "E")
		if event.is_action_pressed("Add Order S"):
			add_order(playerIndex, "S")
		if event.is_action_pressed("Add Order W"):
			add_order(playerIndex, "W")
		if event.is_action_pressed("Add Order AN"):
			add_order(playerIndex, "AN")
		if event.is_action_pressed("Add Order AE"):
			add_order(playerIndex, "AE")
		if event.is_action_pressed("Add Order AS"):
			add_order(playerIndex, "AS")
		if event.is_action_pressed("Add Order AW"):
			add_order(playerIndex, "AW")
	
	if event.is_action_pressed("Upgrade Memory"):
		upgrade_memory(playerIndex)
	if event.is_action_pressed("Submit Move"):
		submit_move(playerIndex)
	if event.is_action_pressed("Back"):
		back(playerIndex)
	
func test_action(playerIndex, action):
	print(playerIndex)
	print(action)

func serialize_players():
	var serialized_players = []
	for player in players:
		serialized_players.append({
			"submitted": player.submitted,
			"state": player.state,
			"selectedUnit": player.selectedUnit,
			"orders": player.orders,
			"income": player.income,
			"money": player.money,
			"memory": player.memory,
			"is_upgrading_memory": player.is_upgrading_memory,
			"currentlySpending": player.currentlySpending,
			"unitDeck": player.unitDeck
		})
	return serialized_players

func deserialize_players(serialized_players):
	# Ensure the players array has the correct size
	if players.size() != serialized_players.size():
		print("Error: Mismatch in player count during deserialization")
		return

	# Update existing Player objects
	for i in range(serialized_players.size()):
		var player_data = serialized_players[i]
		var player = players[i]
		player.submitted = player_data["submitted"]
		player.state = player_data["state"]
		player.selectedUnit = player_data["selectedUnit"]
		player.orders = player_data["orders"]
		player.income = player_data["income"]
		player.money = player_data["money"]
		player.memory = player_data["memory"]
		player.is_upgrading_memory = player_data["is_upgrading_memory"]
		player.currentlySpending = player_data["currentlySpending"]
		player.unitDeck = player_data["unitDeck"]
		
@rpc("authority", "reliable")
func update_players(serialized_players):
	# Deserialize the players data
	deserialize_players(serialized_players)

	# Optionally, update the UI or game state based on the new player data
	#print("Players data updated:", players)

#Actions
@rpc("any_peer", "reliable")
func select_unit(playerIndex, unit: int):
	if not multiplayer.is_server():
		select_unit.rpc_id(1, playerIndex, unit)  # Forward request to host
		return

	# Ensure valid selection conditions
	var availableMoney = players[playerIndex].money - players[playerIndex].currentlySpending
	if availableMoney < UNIT_COSTS[players[playerIndex].unitDeck[unit]]:
		print("insufficient funds")
		return
	if players[playerIndex].state != "SELECTING_UNIT":
		print("not in correct state")
		return

	# Apply selection logic on the host
	players[playerIndex].selectedUnit = players[playerIndex].unitDeck[unit]
	players[playerIndex].currentlySpending += UNIT_COSTS[players[playerIndex].unitDeck[unit]]
	players[playerIndex].state = "ISSUING_ORDERS"

	# Serialize players data and synchronize with all clients
	var serialized_players = serialize_players()
	update_players.rpc(serialized_players)
	
@rpc("any_peer", "reliable")
func upgrade_memory(playerIndex):
	if not multiplayer.is_server():
		upgrade_memory.rpc_id(1, playerIndex)  # Forward request to host
		return
	var availableMoney = players[playerIndex].money - players[playerIndex].currentlySpending
	if players[playerIndex].state == "INPUT_DISABLED":
		return
	if players[playerIndex].is_upgrading_memory == true:
		players[playerIndex].currentlySpending -= players[playerIndex].memory
		players[playerIndex].is_upgrading_memory = false
	elif availableMoney >= players[playerIndex].memory and players[playerIndex].is_upgrading_memory == false:
		players[playerIndex].currentlySpending += players[playerIndex].memory
		players[playerIndex].is_upgrading_memory = true
	elif availableMoney < players[playerIndex].memory:
		print("Insufficient Funds to Upgrade")
	var serialized_players = serialize_players()
	update_players.rpc(serialized_players)

@rpc("any_peer", "reliable")
func submit_move(playerIndex):
	if not multiplayer.is_server():
		submit_move.rpc_id(1, playerIndex)  # Forward request to host
		return
	if players[playerIndex].state == "SUBMITTED_STANDBY" or players[playerIndex].state == "INPUT_DISABLED":
		return
	players[playerIndex].submitted = true
	players[playerIndex].state = "SUBMITTED_STANDBY"
	var serialized_players = serialize_players()
	update_players.rpc(serialized_players)
	check_submissions()

@rpc("any_peer", "reliable")
func check_submissions():
	if not multiplayer.is_server():
		return  # Only the host should handle this

	# Check if both players have submitted their orders
	if players[0].submitted and players[1].submitted:
		# Emit signal to notify the board that both players have submitted their orders
		players[0].state = "INPUT_DISABLED"
		players[1].state = "INPUT_DISABLED"
		var serialized_players = serialize_players()
		update_players.rpc(serialized_players)

		# Call perform_turn on the host and all clients
		board.perform_turn.rpc(players)




@rpc("any_peer", "reliable")
func add_order(playerIndex, order: String):
	if not multiplayer.is_server():
		add_order.rpc_id(1, playerIndex, order)  # Forward request to host
		return
	if players[playerIndex].state != "ISSUING_ORDERS":
		return
	if players[playerIndex].orders.size() >= players[playerIndex].memory:
		print("Memory Full")
		return
	else:
		players[playerIndex].orders.append(order)
	var serialized_players = serialize_players()
	update_players.rpc(serialized_players)

@rpc("any_peer", "reliable")
func back(playerIndex):
	if not multiplayer.is_server():
		back.rpc_id(1, playerIndex)  # Forward request to host
		return
	players[playerIndex].submitted = false
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
	var serialized_players = serialize_players()
	update_players.rpc(serialized_players)

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

@rpc("any_peer", "reliable")
func _on_turn_completed():
	#print("Turn completed!")
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
