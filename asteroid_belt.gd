extends StaticBody2D

# Preload asteroid and enemy ship scenes
var asteroid_scene = preload("res://asteroid.tscn")
var enemy_ship_scene = preload("res://enemy_ship.tscn")

@export var spawn_rate: float = 0.5  # Time in seconds between spawns
@export var max_asteroids: int = 1000  # Maximum number of asteroids
@export var max_enemy_ships: int = 100  # Maximum number of enemy ships

# Lists to keep track of spawned objects
var spawned_asteroids: Array = []
var spawned_enemy_ships: Array = []

func _ready() -> void:
	pass

func start_spawning() -> void:
	# Continuously check the spawn conditions
	spawn_check()

func spawn_check() -> void:
	# Count asteroids and enemy ships within the donut area
	var active_asteroids = get_asteroids_in_area()
	var active_enemy_ships = get_enemy_ships_in_area()

	# Spawn new asteroids if needed
	if active_asteroids.size() < max_asteroids:
		call_deferred("spawn_asteroids", max_asteroids - active_asteroids.size())  # Deferring the spawn

	# Spawn new enemy ships if needed
	if active_enemy_ships.size() < max_enemy_ships:
		call_deferred("spawn_enemy_ships", max_enemy_ships - active_enemy_ships.size())  # Deferring the spawn

	# Schedule the next check
	await get_tree().create_timer(spawn_rate).timeout
	spawn_check()

func spawn_asteroids(count: int) -> void:
	for i in range(count):
		var asteroid = asteroid_scene.instantiate()
		asteroid.position = get_random_position_in_area()
		add_child(asteroid)
		spawned_asteroids.append(asteroid)

func spawn_enemy_ships(count: int) -> void:
	for i in range(count):
		var enemy_ship = enemy_ship_scene.instantiate()
		enemy_ship.position = get_random_position_in_area()
		add_child(enemy_ship)
		spawned_enemy_ships.append(enemy_ship)

func get_asteroids_in_area() -> Array:
	var inner_radius = 935
	var outer_radius = 1050
	var in_area_asteroids = []
	for asteroid in spawned_asteroids:
		if is_instance_valid(asteroid):
			var distance = asteroid.position.length()
			if distance >= inner_radius and distance <= outer_radius:
				in_area_asteroids.append(asteroid)
	return in_area_asteroids

func get_enemy_ships_in_area() -> Array:
	var inner_radius = 935
	var outer_radius = 1050
	var in_area_ships = []
	for ship in spawned_enemy_ships:
		if is_instance_valid(ship):
			var distance = ship.position.length()
			if distance >= inner_radius and distance <= outer_radius:
				in_area_ships.append(ship)
	return in_area_ships

func get_random_position_in_area() -> Vector2:
	var area_shape = $Area2D/DonutCollisionPolygon2D
	if area_shape and area_shape is CollisionPolygon2D:
		var inner_radius = 935
		var outer_radius = 1050
		var angle = randf() * TAU
		var radius = lerp(inner_radius, outer_radius, sqrt(randf()))
		return Vector2(cos(angle), sin(angle)) * radius
	else:
		return Vector2.ZERO

func _on_asteroid_left_area(asteroid: Node) -> void:
	spawned_asteroids.erase(asteroid)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ship"):
		# Start spawning process when the ship enters the area
		start_spawning()
