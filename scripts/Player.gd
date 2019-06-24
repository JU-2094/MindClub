extends KinematicBody2D

#onready var trail = $Trail
#onready var sectors = $Sectors
export var speed = 100
var velocity = Vector2()
var startpoint =  Vector2(0,0)
var endpoint =  Vector2(0,0)
var updpoint=  Vector2(0,0)
var max_x_dash
var max_y_dash
var dir
var direction
var dir_vector
var swipe_handler
var init_time
var elapsed_time 
var DO_DASH = 40
var DISTANCE_DASH =  5000

# ToDo List:
# - Implement dash on the fly:
#	-- Detect while updating the points, if the dash is the required action instead of waiting for end swipe
# - Improve swipe_end for the dash
#   -- Do the animation for sliding, for the moment its teleporting

func _ready():
	print(self.global_position)
	swipe_handler = $SwipeDetector
	init_time = 0
	elapsed_time = 0
	pass

func _process(delta):
	
	if init_time > 0:
		elapsed_time += OS.get_ticks_msec() - init_time
		if elapsed_time > 350:
			# Check if the position should be modified
			if updpoint.length() == 0:
				direction = self.get_global_transform_with_canvas().origin - startpoint
				direction = - direction.normalized() * speed
				move_and_slide(direction, Vector2(0,0))
			elif elapsed_time > 1200:
				direction = self.get_global_transform_with_canvas().origin - updpoint
				direction = - direction.normalized() * speed
				move_and_slide(direction, Vector2(0,0))
		
		# print('TIME (debug)', elapsed_time)
		pass

	# move_and_slide(velocity, Vector2(0,0))
	pass

func _on_SwipeDetector_swipe_started( partial_gesture ):
	startpoint = partial_gesture.last_point()
	# print("start",startpoint)
	init_time = OS.get_ticks_msec()
	updpoint = Vector2(0,0)
	endpoint = Vector2(0,0)
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
	print('--Swipe ended--')
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
	
	
	print("angle:",str(gesture.get_direction_angle()))
	print("direction vector:", gesture.get_direction_vector().round())
	print("indx:",gesture.get_direction_index())
	print("speed:", gesture.get_speed())
	print("duration:,", gesture.get_duration())

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
	print('Swipe_failed')
	
	# playerdirection()
	pass # Replace with function body.
	
func playerdirection():
	# Modificar esto!!!!!!!!!!!!!!!!!!!
	velocity = startpoint - self.get_transform().origin
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	if self.get_transform().origin == startpoint:
		print("here")
