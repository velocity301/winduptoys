# menu.gd

extends Control

@onready var title_label = $TitleLabel
@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var ip_input = $IPInput

func _ready():
	# Connect button signals
	#host_button.connect("pressed", _on_host_pressed)
	#join_button.connect("pressed", _on_join_pressed)
	pass

func _on_host_pressed():
	# Create an ENetMultiplayerPeer as a server
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(12345, 8)  # Port 12345, max 8 players
	if err != OK:
		print("Failed to create server!")
		return
	
	# Set the multiplayer peer
	get_tree().multiplayer.multiplayer_peer = peer
	
	# Transition to the main game scene
func _on_join_pressed():
	pass
	

	# Change scene to the game (make sure "game.tscn" is the correct path)
	#get_tree().change_scene_to_file("res://game.tscn")
