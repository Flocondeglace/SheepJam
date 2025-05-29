extends CharacterBody2D
class_name Sheep

@onready var sheep_collider: CollisionShape2D = $sheep_collider

@export var speed = 100.0
var speed_modifier = 1.0
@export var jump_velocity = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# print("move")
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Move right
	velocity.x = speed * speed_modifier
	
	move_and_slide()

func jump():
	if is_on_floor():
		velocity.y = jump_velocity

func die():
	#make it fall
	speed_modifier = 0.0
	velocity.y = gravity 
	# sheep_collider.disabled = true
	#wait 1 second
	await get_tree().create_timer(1.0).timeout
	#remove the sheep
	queue_free()
