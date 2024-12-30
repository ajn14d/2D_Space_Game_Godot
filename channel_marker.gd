extends StaticBody2D

@export var speed_boost: int = 3000

# Track whether the ChannelMarker is active
var is_active: bool = true
# Track whether the ship is in the area
var ship_in_area: bool = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("planet"):
		disable_channel_marker()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("planet"):
		enable_channel_marker()

func _on_area_2d_body_entered(body: Node) -> void:
	if is_active and body.is_in_group("ship"):
		if not ship_in_area:  # Only apply speed boost if it hasn't already been applied
			body.MAX_SPEED += speed_boost
			ship_in_area = true
			#print("Entered ChannelMarker: Speed boosted!")

func _on_area_2d_body_exited(body: Node) -> void:
	if is_active and body.is_in_group("ship"):
		if ship_in_area:  # Only reduce speed if it was boosted
			body.MAX_SPEED -= speed_boost
			ship_in_area = false
			#print("Exited ChannelMarker: Speed returned to normal.")

# Function to disable the ChannelMarker
func disable_channel_marker() -> void:
	is_active = false
	visible = false  # Make the ChannelMarker invisible
	#print("Channel Marker disabled")

# Function to re-enable the ChannelMarker
func enable_channel_marker() -> void:
	is_active = true
	visible = true  # Make the ChannelMarker visible
	#print("Channel Marker enabled")
	# Check if the ship is already in the area when re-enabling
	if ship_in_area:
		pass
		#print("Ship already in ChannelMarker, applying speed boost again")
