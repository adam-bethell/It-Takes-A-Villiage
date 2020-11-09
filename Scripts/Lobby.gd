extends Node

func _on_HostButton_pressed():
	# Only host to get player connection calls
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(Network.DEFAULT_PORT, Network.DEFAULT_NUM_PLAYERS)
	get_tree().network_peer = peer
	# Server needs to populate itself
	Network.player_data[1] = $PlayerName.text
	$PlayerList.text = PoolStringArray(Network.player_data.values()).join("\n")
	# Hide buttons
	$HostButton.hide()
	$JoinButton.hide()
	$PlayerName.hide()
	# Show Start button
	$StartButton.show()

func _on_JoinButton_pressed():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(Network.DEFAULT_IP, Network.DEFAULT_PORT)
	get_tree().network_peer = peer
	# Hide buttons
	$HostButton.hide()
	$JoinButton.hide()
	$PlayerName.hide()
	
func _on_StartButton_pressed():
	rpc("rpc_start_game")

func _player_connected(id):
	# Add connected player to player_data
	Network.player_data[id] = {}
	rpc("rpc_update_player_data", Network.player_data)
	
func _player_disconnected(id):
	# Remove the connected player from my player data
	Network.player_data.erase(id)
	rpc("rpc_update_player_data", Network.player_data)
	
func _connected_ok():
	# Only called on clients
	# Report player data
	rpc_id(1, "rpc_register_player_data", $PlayerName.text)

remote func rpc_register_player_data(player_name):
	var id = get_tree().get_rpc_sender_id()
	# Update player's data
	Network.player_data[id] = player_name
	rpc("rpc_update_player_data", Network.player_data)

remotesync func rpc_update_player_data(new_player_data):
	Network.player_data = new_player_data
	$PlayerList.text = PoolStringArray(Network.player_data.values()).join("\n")

remotesync func rpc_start_game():
	get_tree().change_scene("res://Scenes/MainScene.tscn")
