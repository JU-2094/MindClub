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
var SWIPE_TOLERANCE = 10
var DO_SWIPE_01_X = 95
var DO_SWIPE_01_Y = 100
var prev_area
var ini_area
var lock_area
var lock_swipe
var count_tolerance 
var flag_swipe
export var nslots = 15

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
	# dognut()
	init_time = 0
	elapsed_time = 0
	anim_handler = get_node("Sprite/AnimationPlayer/AnimationTree").get("parameters/playback")
	anim_handler.start("idle_down")
	prev_dir = ""
	prev_area = ""
	lock_swipe = 0
	flag_swipe = 0
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
	count_tolerance = 0
	
	ini_area = partial_gesture.get_area().get_name()
	flag_swipe = 1
	if partial_gesture.get_area().get_name() != "SwipeArea" and !lock_swipe:
		lock_swipe = 1
		lock_area = partial_gesture.get_area().get_name()
	elif partial_gesture.get_area().get_name() != "SwipeArea":
		init_time = 0
		flag_swipe = 0

	#self.position=startpoint
	pass
  #trail.set_position(point)
  #trail.set_emitting(true)

# This callback is called by all Areas affected
func _on_SwipeDetector_swipe_updated( partial_gesture ):
	
	if prev_area != partial_gesture.get_area().get_name():
		count_tolerance = 0
	else:
		count_tolerance += 1
	
	prev_area = partial_gesture.get_area().get_name()
	updpoint = partial_gesture.last_point()
	
	if count_tolerance > SWIPE_TOLERANCE:
		flag_swipe = 0
	
	pass
# trail.set_position(point)

  
func _on_SwipeDetector_swipe_ended( gesture ):
	var check_dash = 0
	var dir_str
	
	if prev_area == lock_area:
		lock_swipe = 0	
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
	
	print('----')
	print('flag_swipe::', flag_swipe)
	print('delta_x::', delta_x, ' , delta_y::', delta_y)
	print('speed::', gesture.get_speed())
	print('duration::', gesture.get_duration())
	
	
	if flag_swipe:
		if  (abs(delta_x) >= DO_SWIPE_01_X) and (abs(delta_y) >= DO_SWIPE_01_Y) and \
			gesture.get_speed() > 500:
			dir_str = map_dir(dir_vector)
			if dir_str.find("up") != -1 :
				dir_str = "down"
			elif dir_str.find("down") != -1:
				dir_str = "up"
			print('attack for dir::', dir_str)
			if dir_str in ["down", "up", "left", "right"]:
				print('execute attack')
				anim_handler.travel("idle_"+dir_str)
				anim_handler.travel("attack_"+dir_str)
				
		else:
			check_dash = 1
	
	if !flag_swipe or check_dash:
		if dir_vector.y != 0 and delta_x > DO_DASH:
			return
		elif dir_vector.x != 0 and delta_y > DO_DASH:
			return	
		if gesture.get_speed() > 1000 and gesture.get_duration() < 0.2:
			move_and_slide(dir_vector * DISTANCE_DASH , Vector2(0,0))
	
	
	
	"""
	print("angle:",str(gesture.get_direction_angle()))
	print("direction vector:", gesture.get_direction_vector().round())
	print("indx:",gesture.get_direction_index())
	print("speed:", gesture.get_speed())
	print("duration:,", gesture.get_duration())
	"""
	flag_swipe = 0
	pass

func _on_SwipeDetector_swiped( gesture ):
	# dir = gesture.get_direction()
	var curve =gesture.get_curve()
	# print('last ', gesture.last_point())
	pass

func _on_SwipeDetector_swipe_failed():
	# print("curr_position",self.position)
	# print("gesture last point")
	init_time = 0
	elapsed_time = 0
	if ini_area == lock_area:
		lock_swipe = 0
	# print('Swipe_failed')

func init(nickname, start_position, is_slave):
	$name.text = nickname
	global_position = start_position
	if is_slave:
		print("slave!!",nickname)

func _on_SwipeDetector_pattern_detected(pattern_name, actual_gesture):
	print('Pattern detected::', pattern_name)
	pass # Replace with function body.


"""
nslots - amount of points
number multiplying the angle is the anchor

"""
func dognut():
	var cnt =1
	var temppoint = Vector2()
	print("inner circle:")
	for i in range(0,nslots):
		var angle = cnt *(360/nslots)
		temppoint.x=self.position.x+ 10* cos(deg2rad(angle))
		temppoint.y=self.position.y+ 15 * sin(deg2rad(angle))
		print(temppoint)
		cnt = cnt +1
	print("outer circle:")
	cnt =1
	for i in range(0,nslots):
		var angle = cnt *(360/nslots)
		temppoint.x=self.position.x+ 45 * cos(deg2rad(angle))
		temppoint.y=self.position.y+ 55 * sin(deg2rad(angle))
		print(temppoint)
		cnt = cnt +1
	pass