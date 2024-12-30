extends RigidBody2D

var player_ship: Node  # Reference to the player ship node
var enemy_health: int = 100
var player_damage: int = 10

func _ready() -> void:
	# Connect the area signal for detecting collisions
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Get the PlayerShip node
	player_ship = get_node("/root/SpaceGameplay/PlayerShip")  # Adjust path as necessary

	# Ensure the player ship exists before accessing the damage value
	if player_ship:
		# Connect the signal to update the damage when it changes in PlayerShip
		player_ship.connect("player_damage_changed", Callable(self, "_on_damage_changed"))
		player_damage = player_ship.PDC_Damage  # Access the PDC_Damage directly from PlayerShip
		#print("Damage initialized to: ", player_damage)

# Callback when damage changes in PlayerShip
func _on_damage_changed(new_damage: int):
	player_damage = new_damage
	print("Updated enemy ship damage: ", player_damage)

# Called when a body enters the Area2D
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Bullet"):  # Check if the body is a Bullet
		print("Hit!")
		enemy_health -= player_damage
		print(enemy_health)
		if enemy_health <= 0:
			queue_free()
