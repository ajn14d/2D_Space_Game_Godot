extends RigidBody2D

# Define constants
var ACCELERATION = 200.0  # Forward/reverse acceleration
var MAX_SPEED = 500.0
var BRAKE_FORCE = 200.0
var ROTATION_SPEED = 3.0  # Rotation speed in radians per second
var MAX_ROTATION_SPEED = deg_to_rad(180)  # 180 degrees per second, adjust as needed
var gravity_strength = 100.0  # Adjust for desired gravity effect

# Zoom constants
var ZOOM_SPEED = 0.005
var MIN_ZOOM = 0.0001  # Minimum zoom level
var MAX_ZOOM = 3.0  # Maximum zoom level

# Rope variables and properties
@onready var rope_scene: PackedScene = preload("res://rope.tscn")
@onready var pin_joint = $PinJoint2D
var is_pin_joint_visible: bool = true
var rope_instance: Node = null

# Bullet shooting variables
@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 0.1  # Cooldown between shots
@export var PDC_Damage: int = 3 # damage per bullet for PDC gun
var can_shoot: bool = true
var shoot_timer: float = 0.001  # Timer for continuous shooting
var crosshair_rotation_speed = 0.2  # Rotation speed for the crosshair in radians per second
var crosshair_angle_offset = 0.0 # Initial angle offset of the crosshair (relative to the front of the ship)
var original_crosshair_position = Vector2.ZERO # Store the initial position of the crosshair

signal player_damage_changed(new_damage)  # Signal to notify when the damage changes

# Maximum rotation limits in radians (e.g., ±45 degrees)
var max_rotation_angle = deg_to_rad(8.0)  # Convert 365 degrees to radians

# References to collision shapes
@onready var crosshair = $Crosshair
@onready var front = $Front
@onready var back = $Back

# Path to planet gravity bodies
@onready var sun = get_node("/root/SpaceGameplay/Sun/SunGravity")  
@onready var mercury = get_node("/root/SpaceGameplay/Mercury/MercuryGravity")
@onready var venus = get_node("/root/SpaceGameplay/Venus/VenusGravity")
@onready var earth = get_node("/root/SpaceGameplay/Earth/EarthGravity")
@onready var mars = get_node("/root/SpaceGameplay/Mars/MarsGravity")  
@onready var jupiter = get_node("/root/SpaceGameplay/Jupiter/JupiterGravity")
@onready var saturn = get_node("/root/SpaceGameplay/Saturn/SaturnGravity")
@onready var uranus = get_node("/root/SpaceGameplay/Uranus/UranusGravity")
@onready var neptune = get_node("/root/SpaceGameplay/Neptune/NeptuneGravity")
@onready var pluto = get_node("/root/SpaceGameplay/Pluto/PlutoGravity")



@onready var camera = $Camera2D  # Assuming you have a Camera2D node attached to the PlayerShip
@onready var engine_plume = $ShipArt/EnginePlume # variable for engine plume art

# Custom velocity for ship
var custom_velocity = Vector2.ZERO

func _ready():
	# Initialize the camera zoom if needed
	camera.zoom = Vector2(1, 1)
	# Store the original position of the crosshair (relative to the ship's front)
	original_crosshair_position = crosshair.position
	
	emit_signal("player_damage_changed", PDC_Damage)
	
	add_to_group("ship")  # Add ship to the global group "ship"

func _process(delta):
	# Zoom in with the period key (".") and zoom out with the comma key (",")
	if Input.is_action_pressed("ui_period"):  # Period (".") key
		camera.zoom *= (1 - ZOOM_SPEED)
		# Clamp zoom to min/max limits
		camera.zoom.x = clamp(camera.zoom.x, MIN_ZOOM, MAX_ZOOM)
		camera.zoom.y = clamp(camera.zoom.y, MIN_ZOOM, MAX_ZOOM)

	if Input.is_action_pressed("ui_comma"):  # Comma (",") key
		camera.zoom *= (1 + ZOOM_SPEED)
		# Clamp zoom to min/max limits
		camera.zoom.x = clamp(camera.zoom.x, MIN_ZOOM, MAX_ZOOM)
		camera.zoom.y = clamp(camera.zoom.y, MIN_ZOOM, MAX_ZOOM)
	
	# Handle crosshair rotation input
	if Input.is_action_pressed("ui_left"):
		crosshair_angle_offset -= crosshair_rotation_speed * delta  # Rotate counterclockwise
	elif Input.is_action_pressed("ui_right"):
		crosshair_angle_offset += crosshair_rotation_speed * delta  # Rotate clockwise

	# Clamp the rotation angle to the maximum limit
	crosshair_angle_offset = clamp(crosshair_angle_offset, -max_rotation_angle, max_rotation_angle)

	# Reset crosshair position when no input is held
	if not (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
		crosshair_angle_offset = 0.0  # Reset rotation to original position

	# Update the crosshair's position based on the angle
	update_crosshair_position()

	# Handle continuous shooting when the shoot button is held
	if Input.is_action_pressed("shoot"):
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:  # Check if enough time has passed to shoot
			shoot_bullet()  # Shoot a bullet
			shoot_timer = 0.1  # Reset the timer

func update_crosshair_position():
	# Calculate the new position based on the angle offset (relative to the ship)
	var rotated_offset = original_crosshair_position.rotated(crosshair_angle_offset)

	# Set the crosshair's position relative to the front node (ship's center)
	crosshair.position = front.position + rotated_offset

func _input(event: InputEvent):
	# Check if the shoot action (space key) is pressed
	if event.is_action_pressed("shoot"):
		shoot_bullet()
	if Input.is_action_pressed("ui_up"):
		engine_plume.visible = true  # show the EnginePlume when no thrust is applied
	elif event.is_action_released("ui_up"):
		engine_plume.visible = false  # Hide the plume when the key is released
	if event.is_action_pressed("shoot_rope"):  # The key to shoot the rope, e.g., 'n'
		# Toggle visibility based on the current state
		is_pin_joint_visible = !is_pin_joint_visible
		toggle_pin_joint_visibility(is_pin_joint_visible)
		


func _integrate_forces(state: PhysicsDirectBodyState2D):
	# Access delta time from state
	var delta = state.get_step()

	# Handle rotation: Apply rotation only when input is held
	if Input.is_action_pressed("rotate_counterclockwise"):
		angular_velocity -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("rotate_clockwise"):
		angular_velocity += ROTATION_SPEED * delta
	else:
		# Smoothly decelerate the angular velocity when no input is given
		angular_velocity = lerp(angular_velocity, 0.0, 0.04)  # Adjust 0.04 for smoothness

	# Optional: Clamp angular velocity to prevent it from going too fast
	angular_velocity = clamp(angular_velocity, -MAX_ROTATION_SPEED, MAX_ROTATION_SPEED)

	# Calculate the axis vector from Back to Front and normalize it
	var movement_axis = (front.global_position - back.global_position).normalized()

	# Calculate the left/right (perpendicular) axis
	var perpendicular_axis = movement_axis.rotated(deg_to_rad(90))  # Perpendicular to the forward direction

	# Apply thrust along the axis defined by Front and Back (forward and backward)
	if Input.is_action_pressed("move_up"):
		custom_velocity += movement_axis * ACCELERATION * delta
		
	elif Input.is_action_pressed("move_down"):
		custom_velocity -= movement_axis * ACCELERATION * delta

	# Apply strafing along the perpendicular axis (left and right)
	if Input.is_action_pressed("move_right"):
		custom_velocity += perpendicular_axis * ACCELERATION * delta
		
	elif Input.is_action_pressed("move_left"):
		custom_velocity -= perpendicular_axis * ACCELERATION * delta

	# Limit velocity to max speed
	if custom_velocity.length() > MAX_SPEED:
		custom_velocity = custom_velocity.normalized() * MAX_SPEED

	# Apply braking if the space key is held
	if Input.is_action_pressed("brake"):
		custom_velocity = custom_velocity.move_toward(Vector2.ZERO, BRAKE_FORCE * delta)

	# Apply gravity force if inside Bodies gravity area
	if sun and sun.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_sun(state)
	
	if mercury and mercury.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_mercury(state)

	if venus and venus.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_venus(state)
	
	if earth and earth.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_earth(state)

	if mars and mars.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_mars(state)

	if jupiter and jupiter.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_jupiter(state)

	if saturn and saturn.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_saturn(state)

	if uranus and uranus.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_uranus(state)

	if neptune and neptune.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_neptune(state)

	if pluto and pluto.get_overlapping_bodies().has(self):  # Check if the ship is within the gravity area
		apply_gravity_pluto(state)

	# Set the velocity after applying forces
	linear_velocity = custom_velocity

# Handles shooting bullets
func shoot_bullet():
	if can_shoot and bullet_scene:
		can_shoot = false

		# Instance the bullet
		var bullet = bullet_scene.instantiate()
		
		# add bullet's to group "Bullet"
		bullet.add_to_group("Bullet")
		#print("Bullet in groups: ", bullet.get_groups())

		# Set the position of the bullet relative to PlayerShip
		bullet.position = front.position

		# Set the bullet's direction
		var direction = (crosshair.global_position - front.global_position).normalized()
		bullet.direction = direction

		# Set the bullet's velocity relative to the ship's velocity
		bullet.ship_velocity = linear_velocity

		# Add the bullet to the PlayerShip node (since it's the current parent)
		add_child(bullet)

		# Reset shooting ability after cooldown
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

# Function to toggle visibility of PinJoint2D and its children
func toggle_pin_joint_visibility(it_is_visible: bool):
	pin_joint.visible = it_is_visible
	
	# Iterate through all children of the PinJoint2D and set their visibility
	for child in pin_joint.get_children():
		child.visible = visible

# Apply gravitational force
func apply_gravity_sun(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to the Sun (gravity source)
	var direction_to_sun = (sun.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_sun * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_mercury(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Mercury's (gravity source)
	var direction_to_mercury = (mercury.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_mercury * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_venus(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Venus' (gravity source)
	var direction_to_venus = (venus.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_venus * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_earth(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to the Sun (gravity source)
	var direction_to_earth = (earth.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_earth * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_mars(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Mars' (gravity source)
	var direction_to_mars = (mars.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_mars * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_jupiter(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Jupiter's (gravity source)
	var direction_to_jupiter = (jupiter.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_jupiter * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_saturn(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Saturn's (gravity source)
	var direction_to_saturn = (saturn.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_saturn * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_uranus(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Uranus' (gravity source)
	var direction_to_uranus = (uranus.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_uranus * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_neptune(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Mercury's (gravity source)
	var direction_to_neptune = (neptune.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_neptune * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement

func apply_gravity_pluto(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the ship to Pluto's (gravity source)
	var direction_to_pluto = (pluto.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_pluto * gravity_strength

	# Apply the gravity force to the ship
	custom_velocity += gravity_force * state.get_step()  # Use delta time for consistency in movement
