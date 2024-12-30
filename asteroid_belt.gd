extends StaticBody2D

var asteroid_scene = preload("res://asteroid.tscn")
@export var spawn_rate: float = 0.1  # Time in seconds between spawns
@export var max_asteroids: int = 5000  # Maximum number of asteroids in the area

# List to keep track of spawned asteroids
var spawned_asteroids: Array = []

func _ready() -> void:
	# Start the spawning process
	start_spawning()

func start_spawning() -> void:
	# Continuously check the spawn conditions
	spawn_check()

func spawn_check() -> void:
	# Count only asteroids within the donut area
	var active_asteroids = get_asteroids_in_area()

	# Spawn new asteroids if needed
	if active_asteroids.size() < max_asteroids:
		spawn_asteroids(max_asteroids - active_asteroids.size())

	# Schedule the next check
	await get_tree().create_timer(spawn_rate).timeout
	spawn_check()

func spawn_asteroids(count: int) -> void:
	for i in range(count):
		# Spawn an asteroid
		var asteroid = asteroid_scene.instantiate()

		# Generate a random position within the Area2D bounds
		var spawn_position = get_random_position_in_area()
		asteroid.position = spawn_position

		# Add the asteroid as a child of the StaticBody2D
		add_child(asteroid)

		# Keep track of the spawned asteroid
		spawned_asteroids.append(asteroid)

		# Print debug information
		#print("Asteroid spawned at ", spawn_position)

func get_asteroids_in_area() -> Array:
	# Define the donut radii
	var inner_radius = 935
	var outer_radius = 1050

	# Filter asteroids that are within the bounds
	var in_area_asteroids = []
	for asteroid in spawned_asteroids:
		if is_instance_valid(asteroid):
			var distance = asteroid.position.length()
			if distance >= inner_radius and distance <= outer_radius:
				in_area_asteroids.append(asteroid)
	return in_area_asteroids

func get_random_position_in_area() -> Vector2:
	var area_shape = $Area2D/DonutCollisionPolygon2D
	if area_shape and area_shape is CollisionPolygon2D:
		# Assuming the donut shape is approximated as a CollisionPolygon2D
		var inner_radius = 935  # Replace with the actual inner radius of your donut
		var outer_radius = 1050  # Replace with the actual outer radius of your donut

		# Generate a random point in the donut
		var angle = randf() * TAU
		var radius = lerp(inner_radius, outer_radius, sqrt(randf()))
		return Vector2(cos(angle), sin(angle)) * radius
	else:
		#push_error("Unsupported collision shape for spawning.")
		return Vector2.ZERO

# Called when an asteroid leaves the donut area
func _on_asteroid_left_area(asteroid: Node) -> void:
	# Remove it from the list of spawned asteroids
	spawned_asteroids.erase(asteroid)

	# Optionally, free the asteroid (if it's not needed anymore)
	#asteroid.queue_free()

	# Spawn a new asteroid in the area
	spawn_asteroids(1)
