extends Area2D

@export var gravity_strength = 100.0  # Adjust this for the desired gravity effect

@onready var player_ship : RigidBody2D = get_node("/root/SpaceGameplay/PlayerShip")  # Adjust path if needed

func _ready():
	# Connect the body_entered signal if needed, but we will also continuously check overlaps
	connect("body_entered", Callable(self, "_on_body_entered"))
	print("Signal connected!")

func _process(_delta):
	var bodies_in_area = get_overlapping_bodies()
	for body in bodies_in_area:
		if body.is_in_group("ship"):  # Ensure it's the ship
			apply_gravity(body)

func _on_body_entered(body):
	print("Body entered:", body.name)  # Debug message to confirm when a body enters

func apply_gravity(body):
	# Get the direction from the ship to the Sun (gravity source)
	var direction_to_sun = (global_position - body.global_position).normalized()

	# Calculate the gravitational force based on the distance and direction
	var gravity_force = direction_to_sun * gravity_strength

	# Apply the gravity force to the ship
	body.apply_force(gravity_force, Vector2())  # Apply force to pull towards the Sun
