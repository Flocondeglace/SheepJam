extends CharacterBody2D
class_name Sheep

@onready var sheep_collider: CollisionShape2D = $sheep_collider

var last_trap : Trap = null
var last_trap_floor : Trap = null

@export var speed = 100.0
var speed_modifier = 1.0
@export var jump_velocity = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
		# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor() and last_trap != null:
		last_trap_floor = last_trap
		last_trap = null

	# Move right
	velocity.x = speed * speed_modifier
	
	move_and_slide()

func jump():
	if is_on_floor():
		velocity.y = jump_velocity

func die():
	#make it fall
	speed_modifier = 0.0
	last_trap_floor.change_sheep_action_next_round()
	await get_tree().create_timer(1.0).timeout
	#remove the sheep
	queue_free()

func set_trap(trap: Trap):
	print("Trap set")
	last_trap = trap
