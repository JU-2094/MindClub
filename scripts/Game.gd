extends Node2D

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload('res://Players/Player.tscn').instance()
	
	# If I'm peer do the preconfigure and send done, coud pause until is done. Server is always 1
	# JOSUE there are many masters..? with networkdata
	
	#if get_tree().is_network_server():
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	print("--------------- Game.gd  ::  _ready() -------------")
	print("---- add_child( new_player ) ----")
	add_child(new_player)
	new_player.init(Network.self_data)
	# var info = Network.self_data
	# new_player.init(info)

# JOSUE check this,.. should be deleting the node, not the Id..?
func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

# This scene dont exists
func _on_server_disconnected():
	get_tree().change_scene('res://scenes/Multmenu.tscn')
	
	