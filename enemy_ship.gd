extends RigidBody2D

var player_ship: Node  # Reference to the player ship node
var player_ship_detection = null
var enemy_health: int = 100
var player_damage: int = 5
var target_angle: float = 0.0  # The angle the ship should rotate towards
var rotation_speed: float = 2.0  # Speed at which the ship rotates (radians per second)
var alignment_threshold: float = 0.1  # Angle threshold to consider crosshair aligned with the player
var shoot_cooldown: float = 0.5  # Cooldown between shots in seconds

var cooldown_timer: Timer  # Declare a reference to the Timer node

func _ready() -> void:
	# Connect the area signals for detecting collisions
	$BulletDetection.connect("body_entered", Callable(self, "_on_body_entered"))
	$PlayerDetection.connect("body_entered", Callable(self, "_on_body_entered"))
	$PlayerDetection.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Get the PlayerShip node
	player_ship = get_node("/root/SpaceGameplay/PlayerShip")  # Adjust path as necessary
	
	# Set up and start the cooldown timer
	cooldown_timer = $CooldownTimer  # Assuming a Timer node called 'CooldownTimer' is present in the scene
	cooldown_timer.wait_time = shoot_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.start()

# Called when a body enters the Area2D
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Bullet"):  # Check if the body is a Bullet
		print("Hit!")
		enemy_health -= player_damage
		print(enemy_health)
		if enemy_health <= 0:
			queue_free()
	elif body.is_in_group("ship"):  # Check if the body is Player Ship
		print("Player detected")
		player_ship_detection = body  # Assign the detected player ship

# Called when a body exits the Area2D
func _on_body_exited(body: Node) -> void:
	if body.is_in_group("ship"):  # Check if the body is Player Ship
		print("Player left")
		player_ship_detection = null  # Clear the player ship reference

# Smoothly rotate the enemy ship towards the player
func _physics_process(delta: float) -> void:
	if player_ship_detection:
		# Calculate direction to the player
		var direction_to_player = (player_ship.global_position - global_position).normalized().rotated(deg_to_rad(90))
		target_angle = direction_to_player.angle()

		# Smoothly rotate the ship towards the player
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

		# Ensure the Crosshair is aligned with the ship's forward direction
		$Crosshair.rotation = 0  # Reset Crosshair rotation to always point forward relative to the ship

		# Check if the ship is aligned with the player ship (crosshair in line)
		var angle_diff = abs(rotation - target_angle)  # Calculate angle difference
		if angle_diff < alignment_threshold and cooldown_timer.is_stopped():
			# Fire the bullet if cooldown has passed
			shoot_bullet()
			# Restart the cooldown timer after firing
			cooldown_timer.start()

func shoot_bullet():
	# Instance the bullet
	var bullet_scene = preload("res://EnemyPDCbullet.tscn")  # Preload the bullet scene
	var bullet = bullet_scene.instantiate()  # Instantiate the bullet

	# Add bullet to group "EnemyBullet"
	bullet.add_to_group("EnemyBullet")

	# Set the bullet's position using global position
	bullet.global_position = $Front.global_position  # Use the global position of the ship's Front node

	# Set the bullet's direction
	var direction = ($Crosshair.global_position - $Front.global_position).normalized()
	bullet.direction = direction

	# Set the bullet's velocity relative to the ship's velocity
	bullet.ship_velocity = linear_velocity

	# Add the bullet to the scene
	get_tree().root.add_child(bullet)  # Add to the scene root to keep bullet position unaffected by rotation
