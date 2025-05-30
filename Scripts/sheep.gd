extends RigidBody2D
class_name Sheep

signal should_respawn(Sheep)

# Sheep gluing logic variable

# Export a variable for radius so it's easily accessible and can be set if not using CircleShape2D
@export var sphere_radius: float = 25.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D # Adjust path if named differently
@onready var sphere_detection: Area2D = $spheredetection

# Sheep animation
@onready var sprite_2d: Sprite2D = $Mouton
@onready var animation_player_sprite: AnimationPlayer = $Mouton/AnimationSpriteMouton
@onready var animation_effect_mouton: AnimationPlayer = $Mouton/AnimationEffectMouton


# Dictionary to keep track of bodies we've already created a joint with
# Key: the other Sheep, Value: the PinJoint2D created by this sphere
var jointed_bodies: Dictionary = {}
var can_be_glued = false
var have_collided = false

# Sheep throwing logic

signal behh

var mouse_hovering : bool = false
var is_hold : bool = false
var time_sickness : float = 5.0
var max_time_sickness : float = 5



func _ready():
	animation_player_sprite.play("Idle")

	# If we have a CollisionShape2D with a CircleShape, use its radius
	if collision_shape and collision_shape.shape is CircleShape2D:
		sphere_radius = collision_shape.shape.radius

	#freeze after 5 seconds
	#await get_tree().create_timer(5.0).timeout
	#freeze = true

# Calculate the intersection point between two circles
func calculate_intersection_point(other_sphere: Sheep) -> Vector2:
	var d = global_position.distance_to(other_sphere.global_position)
	
	# If circles are too far apart or one is inside the other, return midpoint
	if d >= sphere_radius + other_sphere.sphere_radius or d <= abs(sphere_radius - other_sphere.sphere_radius):
		return (global_position + other_sphere.global_position) / 2
	
	# Calculate the intersection point
	var a = (sphere_radius * sphere_radius - other_sphere.sphere_radius * other_sphere.sphere_radius + d * d) / (2 * d)
	var h = sqrt(sphere_radius * sphere_radius - a * a)
	
	# Calculate the point P2
	var P2 = global_position + a * (other_sphere.global_position - global_position) / d
	
	# Calculate the intersection point
	var x3 = P2.x + h * (other_sphere.global_position.y - global_position.y) / d
	var y3 = P2.y - h * (other_sphere.global_position.x - global_position.x) / d
	
	return Vector2(x3, y3)



func _process(delta: float) -> void:
	if is_hold:
		# Animation
		time_sickness += delta
		time_sickness = clamp(time_sickness, 0, max_time_sickness)
		var color_sheep = lerp(Color(1,1,1), Color(0,1,0), time_sickness/max_time_sickness)
		sprite_2d.modulate = color_sheep
		if abs(time_sickness - max_time_sickness) < 0.01:
			animation_player_sprite.play("Dead")
			
		
		# Reset Force
		self.linear_velocity = Vector2.ZERO
		self.angular_velocity = 0.0
		

func launch(direction: Vector2):
	self.apply_impulse(direction)
	end_player_holding()

func is_under_mouse():
	return mouse_hovering

func _on_mouse_entered() -> void:
	mouse_hovering = true

func _on_mouse_exited() -> void:
	mouse_hovering = false

func start_player_holding() -> void:
	time_sickness = 0
	animation_player_sprite.play("Dragged")
	animation_effect_mouton.play("Sickness")
	is_hold = true
	
func end_player_holding() -> void :
	animation_player_sprite.play("Idle")
	animation_effect_mouton.stop()
	is_hold = false

func _on_spheredetection_area_entered(area: Area2D) -> void:
	if not can_be_glued:
		return

	var other_sphere = area.get_parent()
	
	# Check if the detected body is another sphere and is a RigidBody2D
	if not other_sphere is Sheep:
		return

	have_collided = true


	# Check if we've already created a joint with this other_sphere
	if other_sphere in jointed_bodies:
		return

	# Calculate the intersection point between the sheep
	var intersection_point = calculate_intersection_point(other_sphere)
	
	# Convert the intersection point to local coordinates for this sphere
	var anchor_on_self_local = to_local(intersection_point)
	
	# Create and configure the joint that this sphere owns
	var my_joint = PinJoint2D.new()
	my_joint.name = "JointTo" + other_sphere.name
	
	add_child(my_joint)
	
	my_joint.position = anchor_on_self_local
	my_joint.node_a = ".."
	my_joint.node_b = "../"+str(get_path_to(other_sphere))
	my_joint.softness = 16.0
	my_joint.bias = 0.6

	#disable collision false
	my_joint.disable_collision = false
	
	# Record that this sphere has jointed to other_sphere
	jointed_bodies[other_sphere] = my_joint

	# Tell the other_sphere to create its joint pointing back to this sphere
	if other_sphere.has_method("create_reciprocal_joint"):
		# Convert the intersection point to local coordinates for the other sphere
		var anchor_on_other_local = other_sphere.to_local(intersection_point)
		other_sphere.create_reciprocal_joint(self, anchor_on_other_local)
	else:
		push_warning(other_sphere.name + " does not have create_reciprocal_joint method.")

# This function is called by another sphere that has initiated a joint connection
func create_reciprocal_joint(initiator_body: Sheep, anchor_local_pos_on_me: Vector2):
	if initiator_body in jointed_bodies:
		return

	var reciprocal_joint = PinJoint2D.new()
	reciprocal_joint.name = "JointTo" + initiator_body.name
	
	add_child(reciprocal_joint)

	reciprocal_joint.position = anchor_local_pos_on_me
	reciprocal_joint.node_a = ".."
	reciprocal_joint.node_b = "../"+str(get_path_to(initiator_body))
	reciprocal_joint.softness = 16.0
	reciprocal_joint.bias = 0.6
	reciprocal_joint.disable_collision = false

	jointed_bodies[initiator_body] = reciprocal_joint

# Optional: A getter for external checks
func get_jointed_bodies() -> Dictionary:
	return jointed_bodies

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if !have_collided:
		should_respawn.emit(self)

func force_position(pos: Vector2):
	PhysicsServer2D.body_set_state(
		self.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(pos)
	)
	# Reset Force
	self.linear_velocity = Vector2.ZERO
	self.angular_velocity = 0.0
	
