extends RigidBody2D

# General variables
var is_active: bool = false  # Whether the enemy is in an active state
var is_patrolling: bool = false  # Whether the ship is patrolling
var player_ship: Node = null  # Reference to the player ship node
var enemy_health: int = 100
var player_damage: int = 5

# Shooting variables
var target_angle: float = 0.0  # The angle the ship should rotate towards
var rotation_speed: float = 3.0  # Speed at which the ship rotates (radians per second)
var alignment_threshold: float = 0.1  # Angle threshold to consider aligned with the player
var shoot_cooldown: float = 0.5  # Cooldown between shots in seconds

# Timer for shooting cooldown
var cooldown_timer: Timer

# Patrol variables
var patrol_radius: float = 4000.0  # Max radius to patrol within
var patrol_point: Vector2  # The patrol point to move to
var max_speed: float = 150.0  # Max speed while patrolling
var acceleration: float = 30.0  # Acceleration rate of the ship
var braking_force: float = 10000.0  # Braking force to slow down the ship
var spawn_position: Vector2  # Enemy's spawn position

func _ready() -> void:
	# Connect the signals for detecting the player
	$StandbyDetection.connect("body_entered", Callable(self, "_on_player_entered"))
	$StandbyDetection.connect("body_exited", Callable(self, "_on_player_exited"))
	
	# Get the cooldown timer and configure it
	cooldown_timer = $CooldownTimer
	cooldown_timer.wait_time = shoot_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.start()
	
	# Store the spawn position
	spawn_position = global_position
	
	# Initialize in passive state
	set_to_passive()

func _physics_process(delta: float) -> void:
	if is_active:
		handle_active_state(delta)
	elif is_patrolling:
		handle_patrol_state(delta)
	else:
		set_to_passive()

# Handles logic when the enemy is active (player nearby)
func handle_active_state(delta: float) -> void:
	if player_ship:
		# Stop patrolling
		is_patrolling = false
		linear_velocity = Vector2.ZERO

		# Calculate direction to the player
		var direction_to_player = (player_ship.global_position - global_position).normalized().rotated(deg_to_rad(90))
		target_angle = direction_to_player.angle()

		# Smoothly rotate towards the player
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

		# Shoot bullets when aligned with the player
		if abs(rotation - target_angle) < alignment_threshold and cooldown_timer.is_stopped():
			shoot_bullet()
			cooldown_timer.start()

# Handles logic when the enemy is patrolling
func handle_patrol_state(delta: float) -> void:
	patrol_towards(patrol_point, delta)

# Move the enemy towards the patrol point
func patrol_towards(patrol_target: Vector2, delta: float) -> void:
	var direction_to_patrol = (patrol_target - global_position).normalized()
	
	# Stop if close to the patrol point
	if global_position.distance_to(patrol_target) < 20.0:
		linear_velocity = Vector2.ZERO
		rotation = lerp_angle(rotation, (patrol_target - global_position).angle() + deg_to_rad(90), rotation_speed * delta)
		return

	# Accelerate if not close enough
	if linear_velocity.length() < max_speed:
		linear_velocity += direction_to_patrol * acceleration * delta

	# Apply braking force near the patrol point
	if global_position.distance_to(patrol_target) < 40.0:
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO, braking_force * delta)

	# Rotate towards the patrol point
	var target_angle = (patrol_target - global_position).angle()
	rotation = lerp_angle(rotation, target_angle + deg_to_rad(90), rotation_speed * delta)

	# Set a new patrol point if close enough
	if global_position.distance_to(patrol_target) < 40.0:
		set_random_patrol_point()

# Generate a random patrol point within the patrol radius
func set_random_patrol_point() -> void:
	var random_offset = Vector2(randf_range(-patrol_radius, patrol_radius), randf_range(-patrol_radius, patrol_radius))
	patrol_point = spawn_position + random_offset

# Called when the player enters the detection area
func _on_player_entered(body: Node) -> void:
	if body.is_in_group("ship"):
		is_patrolling = true
		player_ship = body

# Called when the player exits the detection area
func _on_player_exited(body: Node) -> void:
	if body.is_in_group("ship"):
		player_ship = null
		is_patrolling = false  # Start patrolling after the player leaves
		set_random_patrol_point()

# Sets the ship to a passive state
func set_to_passive() -> void:
	is_patrolling = false
	linear_velocity = Vector2.ZERO

# Shoot a bullet
func shoot_bullet() -> void:
	var bullet_scene = preload("res://EnemyPDCbullet.tscn")
	var bullet = bullet_scene.instantiate()

	bullet.add_to_group("EnemyBullet")
	bullet.global_position = $Front.global_position

	var direction = ($Crosshair.global_position - $Front.global_position).normalized()
	bullet.direction = direction
	bullet.ship_velocity = linear_velocity

	get_tree().root.add_child(bullet)


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("ship"):
		is_active = true


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("ship"):
		is_active = false
