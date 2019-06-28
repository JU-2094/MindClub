extends KinematicBody2D

#onready var trail = $Trail
#onready var sectors = $Sectors
export var speed = 100
var velocity   = Vector2()
var startpoint = Vector2(0,0)
var endpoint   = Vector2(0,0)
var updpoint   = Vector2(0,0)
var prev_dir 
var max_x_dash
var max_y_dash
var dir
var direction
var dir_vector
var anim_handler
var init_time
var elapsed_time
var DO_DASH = 40
var DISTANCE_DASH =  5000
var prev_area
#Network
slave var slave_position = Vector2()
# ToDo List:
# - Implement dash on the fly:
#	-- Detect while updating the points, if the dash is the required action instead of waiting for end swipe
# - Improve swipe_end for the dash
#   -- Do the animation for sliding, for the moment its teleporting
# CHECK OTHERS TODO IN THE CODE

func map_dir(vec_d):
	var str_dir = ""
	if vec_d.y == 1:
		str_dir = "up"
	elif vec_d.y == -1:
		str_dir = "down"
	
	if vec_d.x !=0 and vec_d.y != 0:
		str_dir += "_"
	
	if vec_d.x == 1:
		str_dir += "left"
	elif vec_d.x == -1:
		str_dir += "right"
	
	return str_dir
	
func _ready():
	# print(self.global_position)
	init_time = 0
	elapsed_time = 0
	anim_handler = get_node("Sprite/AnimationPlayer/AnimationTree").get("parameters/playback")
	anim_handler.start("idle_down")
	prev_dir = ""
	prev_area = ""
	pass

func _physics_process(delta):
	var dir_norm
	var flag_move = 0
	
	
	if init_time > 0:
		elapsed_time += OS.get_ticks_msec() - init_time
		if elapsed_time > 350:
			# Check if the position should be modified
			if updpoint.length() == 0:
				direction = self.get_global_transform_with_canvas().origin - startpoint
				flag_move = 1
			elif elapsed_time > 1200:
				direction = self.get_global_transform_with_canvas().origin - updpoint
				flag_move = 1
	else:
		if prev_dir in ["down", "up", "left", "right"]:
			anim_handler.travel("idle_"+prev_dir)
			prev_dir = ""
	# Todo Add anims for combined directions and remove ifs
	if flag_move:
		dir_norm = direction.normalized().round()
		direction = - direction.normalized() * speed
		prev_dir = map_dir(dir_norm)
		
		# BUG fix this, requires all animations..
		if prev_dir.find("up") != -1 :
			prev_dir = "up"
		elif prev_dir.find("down") != -1:
			prev_dir = "down"
		if prev_dir in ["down", "up", "left", "right"]:
			anim_handler.travel("walk_"+prev_dir)
		# ---------------
		
		move_and_slide(direction, Vector2(0,0))
	
	if is_network_master():
		rset_unreliable('slave_position', position)
	else:
		position = slave_position
	if get_tree().is_network_server():
		Network.update_position(int(name), position)

func _on_SwipeDetector_swipe_started( partial_gesture ):
	startpoint = partial_gesture.last_point()
	# print("start",startpoint)
	init_time = OS.get_ticks_msec()
	updpoint = Vector2(0,0)
	endpoint = Vector2(0,0)
	
	prev_area = partial_gesture.get_area().get_name()
	print('\n--Area detected::',partial_gesture.get_area().get_name())
	#self.position=startpoint
	pass
  #trail.set_position(point)
  #trail.set_emitting(true)

func _on_SwipeDetector_swipe_updated( partial_gesture ):
	updpoint = partial_gesture.last_point()
	# print(updpoint)
	pass
  #trail.set_position(point)

  
func _on_SwipeDetector_swipe_ended( gesture ):
	print('--Swipe ended--\n')
	print('--Final area::', gesture.get_area().get_name())
	
	endpoint = gesture.last_point()
	init_time  = 0
	elapsed_time = 0
	# print(endpoint)
	dir = gesture.get_direction()
	dir_vector = gesture.get_direction_vector().round()
	
	var delta_x = startpoint.x - endpoint.x
	var delta_y = startpoint.y - endpoint.y
	
	# ToDo Add code for attack gestures. Only dash is considered 
	# The threshold for doing the dash is 40
	# This only supports 4 directions (up, down, left, right)
	if dir_vector.y != 0 and delta_x > DO_DASH:
		return
	elif dir_vector.x != 0 and delta_y > DO_DASH:
		return
	
	if gesture.get_speed() > 1000 and gesture.get_duration() < 0.2:
		move_and_slide(dir_vector * DISTANCE_DASH , Vector2(0,0))
		pass
	
	if prev_area != gesture.get_area().get_name():
		# gesture.swipe_stop(prev_area, true)
		print('here')
		pass
	
	"""
	print("angle:",str(gesture.get_direction_angle()))
	print("direction vector:", gesture.get_direction_vector().round())
	print("indx:",gesture.get_direction_index())
	print("speed:", gesture.get_speed())
	print("duration:,", gesture.get_duration())
	"""
	pass


func _on_SwipeDetector_swiped( gesture ):
	#dir = gesture.get_direction()7
	var curve =gesture.get_curve()
	
	# print('last ', gesture.last_point())
	pass


func _on_SwipeDetector_swipe_failed():
	# print("curr_position",self.position)
	# print("gesture last point")
	init_time = 0
	elapsed_time = 0
	# print('Swipe_failed')
	
func init(nickname, start_position, is_slave):
	$name.text = nickname
	global_position = start_position
	if is_slave:
		print("slave!!",nickname)

func _on_SwipeDetector_pattern_detected(pattern_name, actual_gesture):
	print('Pattern detected::', pattern_name)
	pass # Replace with function body.
