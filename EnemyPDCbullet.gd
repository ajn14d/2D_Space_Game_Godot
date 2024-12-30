extends RigidBody2D

@export var speed: float = 1000.0 # Speed of the bullet

var gravity_strength = 400.0  # Adjust for desired gravity effect

# Path to planet gravity bodies
@onready var sun_area = get_node("/root/SpaceGameplay/Sun/SunGravity")  
@onready var mercury_area = get_node("/root/SpaceGameplay/Mercury/MercuryGravity")
@onready var venus_area = get_node("/root/SpaceGameplay/Venus/VenusGravity")
@onready var earth_area = get_node("/root/SpaceGameplay/Earth/EarthGravity")
@onready var mars_area = get_node("/root/SpaceGameplay/Mars/MarsGravity")  
@onready var jupiter_area = get_node("/root/SpaceGameplay/Jupiter/JupiterGravity")
@onready var saturn_area = get_node("/root/SpaceGameplay/Saturn/SaturnGravity")
@onready var uranus_area = get_node("/root/SpaceGameplay/Uranus/UranusGravity")
@onready var neptune_area = get_node("/root/SpaceGameplay/Neptune/NeptuneGravity")
@onready var pluto_area = get_node("/root/SpaceGameplay/Pluto/PlutoGravity")

var direction = Vector2.ZERO  # Direction for the bullet to move
var ship_velocity = Vector2.ZERO  # Ship's velocity at the time of firing

# Called when the bullet is instantiated
func _ready() -> void:
	
	add_to_group("EnemyBullet")
	
	# Set the bullet's velocity to move towards the crosshair direction
	linear_velocity = ship_velocity + direction * speed

	# Automatically remove the bullet after 5 seconds (for now, increase for testing)
	await get_tree().create_timer(10.0).timeout
	queue_free()

# Called every frame to apply forces
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Debugging: Print out the overlapping bodies to check if the bullet is inside the gravity well
	#var _sun_overlap = sun_area.get_overlapping_bodies()
	#var _earth_overlap = earth_area.get_overlapping_bodies()
	#print("Sun Overlapping Bodies: ", sun_overlap)
	#print("Earth Overlapping Bodies: ", earth_overlap)

	# Check if the bullet is inside the Sun's gravity well
	if sun_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the Sun's gravity well
		#print("Bullet is inside Sun gravity well")
		apply_gravity_sun(state)

		# Check if the bullet is inside the planets gravity well
	if mercury_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_mercury(state)
	
		# Check if the bullet is inside the planets gravity well
	if venus_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_venus(state)

	# Check if the bullet is inside the planets gravity well
	if earth_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_earth(state)
	
		# Check if the bullet is inside the planets gravity well
	if mars_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_mars(state)
	
		# Check if the bullet is inside the planets gravity well
	if jupiter_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_jupiter(state)
	
		# Check if the bullet is inside the planets gravity well
	if saturn_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_saturn(state)
	
		# Check if the bullet is inside the planets gravity well
	if uranus_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_uranus(state)
	
		# Check if the bullet is inside the planets gravity well
	if neptune_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_neptune(state)
	
		# Check if the bullet is inside the planets gravity well
	if pluto_area.get_overlapping_bodies().has(self):  # Check if the bullet is inside the planets gravity well
		#print("Bullet is inside planet gravity well")
		apply_gravity_pluto(state)

	# Debugging: Print current velocity to check if it's updating
	#print("Bullet Velocity: ", linear_velocity)

# Apply gravity from the Sun
func apply_gravity_sun(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the Sun (gravity source)
	var direction_to_sun = (sun_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_sun * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from Mercury
func apply_gravity_mercury(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_mercury = (mercury_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_mercury * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from Venus
func apply_gravity_venus(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_venus = (venus_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_venus * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from the Earth
func apply_gravity_earth(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_earth = (earth_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_earth * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from Mars
func apply_gravity_mars(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_mars = (mars_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_mars * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from Jupiter
func apply_gravity_jupiter(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_jupiter = (jupiter_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_jupiter * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from Saturn
func apply_gravity_saturn(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_saturn = (saturn_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_saturn * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from Uranus
func apply_gravity_uranus(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_uranus = (uranus_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_uranus * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from neptune
func apply_gravity_neptune(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_neptune = (neptune_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_neptune * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity

# Apply gravity from Uranus
func apply_gravity_pluto(state: PhysicsDirectBodyState2D):
	# Calculate the direction from the bullet to the planet (gravity source)
	var direction_to_pluto = (pluto_area.global_position - global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_pluto * gravity_strength

	# Apply the gravity force to the bullet's velocity
	linear_velocity += gravity_force * state.get_step()  # Apply gravity directly to the linear velocity
