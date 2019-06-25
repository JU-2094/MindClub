extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_name =""
# Called when the node enters the scene tree for the first time.
func _ready():
	var addrs=IP.get_local_addresses()
	$Label2.text="YOUR IP:"+addrs[1]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if player_name == "":
		return
	Network.create_server(player_name)
	_load_game()
	pass # Replace with function body.


func _on_Button2_pressed():
	if player_name == "":
		return
	Network.connect_to_server(player_name)
	_load_game()
	pass # Replace with function body.


func _on_TextEdit2_text_changed():
	Network.custom_ip = $TextEdit2.text
	pass # Replace with function body.


func _on_TextEdit_text_changed():
	player_name=$TextEdit.text
	pass # Replace with function body.

func _load_game():
	get_tree().change_scene("res://scenes/Game.tscn")
	pass