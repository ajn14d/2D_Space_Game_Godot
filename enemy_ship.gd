extends RigidBody2D

var player_ship: Node  # Reference to the player ship node
var player_ship_detection = null
var enemy_health: int = 100
var player_damage: int = 10
var target_angle: float = 0.0  # The angle the ship should rotate towards
var rotation_speed: float = 2.0  # Speed at which the ship rotates (radians per second)

func _ready() -> void:
	# Connect the area signals for detecting collisions
	$BulletDetection.connect("body_entered", Callable(self, "_on_body_entered"))
	$PlayerDetection.connect("body_entered", Callable(self, "_on_body_entered"))
	$PlayerDetection.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Get the PlayerShip node
	player_ship = get_node("/root/SpaceGameplay/PlayerShip")  # Adjust path as necessary

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
