extends Control

@onready var title_label = $TitleLabel
@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var ip_input = $IPInput
@onready var terrain: Node2D = $"../Board/Terrain"
@onready var ui_container: Control = $"../UIContainer"
@onready var input_handler: Node2D = $"../InputHandler"


var ip_address = "127.0.0.1"

func _ready():
	# Connect button signals
	host_button.connect("pressed", _on_host_pressed)
	join_button.connect("pressed", _on_join_pressed)

func _on_host_pressed():
	# Create an ENetMultiplayerPeer as a server
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(8910, 2)  # Port 8910, max 2 players
	if err != OK:
		print("Failed to create server!")
		return
	
	# Set the multiplayer peer
	multiplayer.multiplayer_peer = peer
	print("HOST started")

	# Connect signal to detect when a client joins
	multiplayer.peer_connected.connect(_on_client_connected)

	# Generate the map (but do not send it yet)
	terrain.generate_map()
	terrain.create_terrain(terrain.resource_map)
	# Hide player 2 UI Elements besides Submitted, State, Memory, Money
	$"../UIContainer/SelectedUnitLabel2".hide()
	$"../UIContainer/OrdersLabel2".hide()
	$"../UIContainer/IsUpgradingMemoryLabel2".hide()
	$"../UIContainer/CurrentlySpendingLabel2".hide()
	self.hide()

func _on_client_connected(client_id):
	print("Client connected:", client_id)
	# Send the map only to the newly connected client
	rpc_id(client_id, "receive_map", terrain.resource_map)
	input_handler.turn_timer.start()

func _on_join_pressed():
	ip_address = ip_input.text.strip_edges()
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip_address, 8910)  # Port 8910
	if err != OK:
		print("Failed to join server!")
		return
	
	multiplayer.multiplayer_peer = peer
	print("Joined ", ip_address)
	
	$"../UIContainer/SelectedUnitLabel".hide()
	$"../UIContainer/OrdersLabel".hide()
	$"../UIContainer/IsUpgradingMemoryLabel".hide()
	$"../UIContainer/CurrentlySpendingLabel".hide()
	
	
	self.hide()

@rpc("authority", "reliable")
func receive_map(received_map: Array):
	# Update the terrain with the received map from the host
	print("Received resource map from host:", received_map)
	terrain.resource_map = received_map
	terrain.create_terrain(terrain.resource_map)
