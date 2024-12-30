extends RigidBody2D

@onready var sun = get_node("/root/SpaceGameplay/Sun/SunGravity")  # Adjust the path to your SunGravity node
@onready var earth = get_node("/root/SpaceGameplay/Earth/EarthGravity")  # Adjust the path to your EarthGravity node
@onready var rope_area = get_node("/root/SpaceGameplay/PlayerShip/PinJoint2D/Rope/Area2D")  # Path to the Area2D on the rope

var gravity_strength = 3000.0
var planet_gravity = 500.0

# Custom velocity for asteroid
var custom_velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Asteroids")  # Add asteroid to the global group "Asteroids"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# Ensure rope_area is valid and monitoring before applying gravity
	if rope_area and rope_area.monitoring:
		if rope_area.get_overlapping_bodies().has(self):  # Check if the asteroid is within the gravity area
			apply_gravity_rope(state)
		#print("gravity applied")
	if earth and earth.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_earth(state)

func apply_gravity_rope(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the asteroid to the rope (gravity source)
	var direction_to_rope = (rope_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_rope * gravity_strength

	# Apply the gravity force directly to the asteroid's linear velocity
	linear_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

# Apply gravitational force
func apply_gravity_sun(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the asteroid to the Sun (gravity source)
	var direction_to_sun = (sun.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_sun * gravity_strength

	# Apply the gravity force to the asteroid
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_earth(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the asteroid to the earth (gravity source)
	var direction_to_earth = (earth.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_earth * planet_gravity

	# Apply the gravity force directly to the asteroid's linear velocity
	linear_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement
