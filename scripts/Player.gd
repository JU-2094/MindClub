extends KinematicBody2D

#onready var trail = $Trail
#onready var sectors = $Sectors
export var speed = 100
var velocity = Vector2()
var startpoint =  Vector2(0,0)
var endpoint =  Vector2(0,0)
var updpoint=  Vector2(0,0)
var dir
func _ready():
	print(self.global_position)
	pass

func _process(delta):
	#var dir = dir1
	if dir == "right":
		velocity.x += 1
	if dir == "left":
		velocity.x -= 1
	if dir == "up":
		velocity.y -= 1
	if dir == "up_right":
		velocity.y -= 1
		velocity.x += 1
	if dir == "up_left":
		velocity.y -= 1
		velocity.x -= 1
	if dir == "down":
		velocity.y += 1
	if dir == "down_right":
		velocity.y += 1
		velocity.x += 1
	if dir == "down_left":
		velocity.y += 1
		velocity.x -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	move_and_slide(velocity, Vector2(0,0))
	pass

func _on_SwipeDetector_swipe_started( partial_gesture ):
	startpoint = partial_gesture.last_point()
	print("start",startpoint)
	#self.position=startpoint
	pass
  #trail.set_position(point)
  #trail.set_emitting(true)

func _on_SwipeDetector_swipe_updated( partial_gesture ):
	updpoint = partial_gesture.last_point()
	print(updpoint)
	pass
  #trail.set_position(point)

  
func _on_SwipeDetector_swipe_ended( gesture ):
	endpoint = gesture.last_point()
	print(endpoint)
	dir = gesture.get_direction()
	print("angle:",str(gesture.get_direction_angle()))
	print("indx",gesture.get_direction_index())
	pass


func _on_SwipeDetector_swiped( gesture ):
	#dir = gesture.get_direction()
	print('last ', gesture.last_point())
	if gesture.last_point()==startpoint:
		print("papu")
	pass


func _on_SwipeDetector_swipe_failed():
	print("curr_position",self.position)
	playerdirection()
	pass # Replace with function body.
func playerdirection():
	#Modificar esto!!!!!!!!!!!!!!!!!!!
	velocity = startpoint - self.get_transform().origin
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	if self.get_transform().origin == startpoint:
		print("here")