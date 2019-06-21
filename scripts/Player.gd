extends KinematicBody2D

#onready var trail = $Trail
#onready var sectors = $Sectors
export var speed = 100
var velocity = Vector2()
var startpoint
var endpoint =  Vector2(0,0)
var updpoint=  Vector2(0,0)
func _ready():
		pass

func _process(delta):
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	move_and_slide(velocity, Vector2(0,0))
	pass

func _on_SwipeDetector_swipe_started( partial_gesture ):
	startpoint = partial_gesture.last_point()
	print("start",startpoint)
	self.position=startpoint
	pass
  #trail.set_position(point)
  #trail.set_emitting(true)

func _on_SwipeDetector_swipe_updated( partial_gesture ):
	updpoint = partial_gesture.last_point()
	pass
  #trail.set_position(point)

  
func _on_SwipeDetector_swipe_ended( gesture ):
	endpoint = gesture.last_point()
  #trail.set_emitting(false)
#	check_health()
#	check_powerups()
#	var state_input = get_input()

#	var state = 0
	var dir = gesture.get_direction()
	print("angle:",str(gesture.get_direction_angle()))
	print("indx",gesture.get_direction_index())
	if dir == "right":
		velocity.x += 1
	#	state += 1
	#	orientation = 1
		
		#if state_item:
			#anim_handler.travel("carry_right")
		#else:
			#anim_handler.travel("right")
	#if dir == "right_rls":
		#if state_item:
			#anim_handler.travel("idle_carry_right")
		#else:
			#anim_handler.travel("idle_right")
	if dir == "left":
		velocity.x -= 1
		#state += 2
		#orientation = 2
		#if state_item:
		#	anim_handler.travel("carry_left")
		#else:
		#	anim_handler.travel("left")
	#if dir == "left_rls":
		#if state_item:
		#	anim_handler.travel("idle_carry_left")
		#else:
		#	anim_handler.travel("idle_left")
		
	if dir == "up":
		velocity.y -= 1
		#state += 4
		#orientation = 3
		#if state_item:
		#	anim_handler.travel("carry_up")
		#else:
		#	anim_handler.travel("up")
	if dir == "up_right":
		velocity.y -= 1
		velocity.x += 1
	if dir == "up_left":
		velocity.y -= 1
		velocity.x -= 1
	#if dir == "up_rls":
		#if state_item:
		#	anim_handler.travel("idle_carry_up")
		#else:
		#	anim_handler.travel("idle_up")
		
	if dir == "down":
		velocity.y += 1
		#state += 8
		#orientation = 4
		#if state_item:
		#	anim_handler.travel("carry_down")
		#else:
		#	anim_handler.travel("down")
	if dir == "down_right":
		velocity.y += 1
		velocity.x += 1
	if dir == "down_left":
		velocity.y += 1
		velocity.x -= 1
	#if dir == "down_rls":
		#if state_item:
		#	anim_handler.travel("idle_carry_down")
		#else:
		#	anim_handler.travel("idle_down")
		
		
	# Shortcut $AnimatedSprite --> get_node("AnimatedSprite")
	#if state_item == 0 or state_item == 2:
	#move_and_slide(velocity, Vector2(0,0))
	#move_and_slide(velocity, Vector2(0,0))
	pass


func _on_SwipeDetector_swiped( gesture ):
	print('Duration: ', gesture.get_duration())
