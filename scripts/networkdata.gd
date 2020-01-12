extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400 
const MAX_PLAYERS = 5
var custom_ip = ''

# this is a hashmap for the network id and player data
var players = { }

# Josue, this is wrong, only the master has control over this 
var self_data = { id = 0, name = '', position = Vector2(360, 180) }

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
	
	
# ------------------------------   create_server ------------------------------------
# TODO the function new returns an error, verify the connection and retry. 
# Check NetworkedMultiplayerEnet for the errors codes
func create_server(player_nickname):
	self_data.name = player_nickname
	self_data.id = 1
	# Master is always 1 in this NETWORK API
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

# ------------------------------   connect_to_server --------------------------------
func connect_to_server(player_nickname):
	self_data.name = player_nickname
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	if custom_ip!="":
		peer.create_client(custom_ip, DEFAULT_PORT)
	else:
		peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
func _connected_to_server():
	var local_player_id = get_tree().get_network_unique_id()
	self_data.id = local_player_id
	# players[local_player_id] = self_data  # ---Request this to master
	# Do a remote call to this function in all the others peers
	rpc('_register_player', local_player_id, self_data)


# ---------------------------- callback network_peer_disconnected ------------------
# when my process is disconnected
# THIS FUNCTION IS REPEATED in GAME...? JOSUE
func _on_player_disconnected(id):
		players.erase(id)

# ---------------------------- callback network_peer_connected ---------------------
func _on_player_connected(connected_player_id):
	var local_player_id = get_tree().get_network_unique_id()
	if not(get_tree().is_network_server()):
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id)

# ----------------------------------------------------------------------------------
# ------------------------- rpc section  (Remote Process Call) ---------------------

remote func _request_player_info(request_from_id, player_id):
	if get_tree().is_network_server():
		rpc_id(request_from_id, '_register_player', player_id, players[player_id])

# A function to be used if needed. The purpose is to request all players in the current session.
remote func _request_players(request_from_id):
	if get_tree().is_network_server():
		for peer_id in players:
			if( peer_id != request_from_id):
				rpc_id(request_from_id, '_register_player', peer_id, players[peer_id])

# JOSUE this function seems incorrect in the network_master stuff .. ?
remote func _register_player(id, info):
	players[id] = info
	var new_player = load('res://Players/Player.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	$'/root/Game/'.add_child(new_player)
	new_player.remove_nodes()
	new_player.init(info)
	print("-------------------- networkdata.gd :: _register_player   (RPC) ----------- ")
	print("adding new_player with id::", id)
	print("the network id for this process is::", get_tree().get_network_unique_id())
	
	
	# new_player.init(info)

func update_position(id, position):
	players[id].position = position
