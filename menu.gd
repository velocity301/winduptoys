# menu.gd

extends Control

@onready var title_label = $TitleLabel
@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var ip_input = $IPInput
const IP_ADDRESS = "127.0.0.1"

func _ready():
	# Connect button signals
	host_button.connect("pressed", _on_host_pressed)
	join_button.connect("pressed", _on_join_pressed)

func _on_host_pressed():
	# Create an ENetMultiplayerPeer as a server
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(8910, 2)  # Port 12345, max 8 players
	if err != OK:
		print("Failed to create server!")
		return
	
	# Set the multiplayer peer
	multiplayer.multiplayer_peer = peer
	print("HOST")
	self.hide()
	# Transition to the main game scene
func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(IP_ADDRESS, 8910)  # Port 12345, max 8 players
	if err != OK:
		print("Failed to join server!")
	multiplayer.multiplayer_peer = peer
	print("Joined ", IP_ADDRESS)
	self.hide()
	# Change scene to the game (make sure "game.tscn" is the correct path)
	#get_tree().change_scene_to_file("res://game.tscn")
