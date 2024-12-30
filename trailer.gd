extends RigidBody2D

@onready var rope_area = get_node("/root/SpaceGameplay/PlayerShip/PinJoint2D/Rope/Area2D")  # Path to the Area2D on the rope
@onready var body_entered_area = get_node("BodyEnteredArea")  # The BodyEnteredArea node
@onready var rope = get_node("/root/SpaceGameplay/PlayerShip/PinJoint2D/Rope")  # The actual rope node to attach to
@onready var pin_joint : PinJoint2D = get_node("PinJoint2D")  # Ensure that PinJoint2D is properly referenced in the script
@onready var trailer_door = get_node("TrailerDoor")  # Assuming TrailerDoor is a direct child of this node

var trailer_attached = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Trailers")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# Ensure rope_area is valid and monitoring before applying gravity
	if rope_area and rope_area.monitoring:
		# Check if this trailer's body is within the rope_area
		var bodies_in_area = rope_area.get_overlapping_bodies()
		if bodies_in_area.has(self):  # Check if the trailer (itself) is in the rope area
			# Attach the trailer to the rope via PinJoint2D
			attach_trailer_to_rope()
	else:
		detach_trailer_to_rope()

func _input(event) -> void:
	if trailer_attached and event.is_action_pressed("Trailer_Door"):  # Replace with the correct key action if desired
		toggle_trailer_door()

# Function to attach the trailer to the rope
func attach_trailer_to_rope() -> void:
	pin_joint.node_b = rope.get_path()
	trailer_attached = true
	
func detach_trailer_to_rope() -> void:
	pin_joint.node_b = NodePath()
	trailer_attached = false

func toggle_trailer_door() -> void:
	# Disable the CollisionShape2D
	trailer_door.disabled = !trailer_door.disabled

	# Disable visibility of the CollisionShape2D (the shape is still there but not visible)
	trailer_door.visible = !trailer_door.visible
