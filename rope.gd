extends RigidBody2D

@onready var sun = get_node("/root/SpaceGameplay/Sun/SunGravity")  # Adjust the path to your SunGravity node
@onready var earth = get_node("/root/SpaceGameplay/Earth/EarthGravity")  # Adjust the path to your EarthGravity node
@onready var rope_area = get_node("/root/SpaceGameplay/PlayerShip/PinJoint2D/Rope/Area2D")  # Path to the Area2D on the rope
@onready var rope_collision_shape = get_node("/root/SpaceGameplay/PlayerShip/PinJoint2D/Rope/CollisionShape2D")  # Path to the CollisionShape2D

var gravity_strength = 2500.0
var is_monitoring = true  # Tracks whether the Area2D and CollisionShape2D are enabled 

func _ready():
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# Iterate over all bodies in the area and check if they belong to the "Asteroids" group
	if is_monitoring:
		for body in rope_area.get_overlapping_bodies():
			if body.is_in_group("Asteroids"):  # check group is hitchable
				apply_gravity_rope_asteroid(state, body)  # Apply gravity to the asteroid
				#print("working")

func apply_gravity_rope_asteroid(state: PhysicsDirectBodyState2D, asteroid):
	# Calculate the direction from the asteroid to the rope
	var direction_to_object = (global_position - asteroid.global_position).normalized()
	
	# Calculate the gravitational force based on direction
	var distance = global_position.distance_to(asteroid.global_position)
	if distance > 0.0:  # Prevent division by zero
		var gravity_force = direction_to_object * (gravity_strength / (distance * distance))  # Inverse-square law
		
		# Apply the force to the asteroid
		if asteroid is RigidBody2D:
			asteroid.apply_central_force(gravity_force)
			#print("Gravity applied to asteroid at: ", asteroid.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# For testing: Toggle monitoring every frame (for debug or testing purposes)
	if Input.is_action_just_pressed("shoot_rope"):
		toggle_monitoring()

# Function to toggle monitoring on and off
func toggle_monitoring():
	is_monitoring = !is_monitoring  # Toggle the monitoring state
	rope_area.monitoring = is_monitoring  # Enable or disable collision monitoring on the Area2D
	rope_collision_shape.disabled = !is_monitoring  # Disable or enable the CollisionShape2D's collision
	#print("Monitoring toggled: ", is_monitoring)  # Print current state for debugging
