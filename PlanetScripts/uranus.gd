extends StaticBody2D

var orbit_radius : float = 700000.0
var orbit_speed : float = 0.000005
var angle : float = 0.0

func _ready():
	add_to_group("planet")  # Add planet to the global group "planet"

func _process(delta):
	angle += orbit_speed * delta
	var x = orbit_radius * cos(angle)
	var y = orbit_radius * sin(angle)
	position = Vector2(x, y)  # This moves the Node2D (planet) around (0,0)
