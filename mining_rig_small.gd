extends StaticBody2D

@onready var asteroid_area = get_node("/root/SpaceGameplay/Asteroid/BodyEnteredArea")  # Adjust the path to your Asteroid Area2D node

# Dictionary to track mining progress for each asteroid
var mining_timers = {}
# Set to track asteroids that were successfully mined
var mined_asteroids = {}

func _ready() -> void:
	# Connect the signals for entering and exiting the area
	asteroid_area.body_entered.connect(_on_area_2d_body_entered)
	asteroid_area.body_exited.connect(_on_area_2d_body_exited)

func _on_area_2d_body_entered(body: PhysicsBody2D):
	if body.is_in_group("Asteroids"):  # Ensure it's an asteroid
		#print("Asteroid entered the area:", body.name)
		mine_asteroid(body)

func _on_area_2d_body_exited(body: PhysicsBody2D):
	if body.is_in_group("Asteroids"):  # Ensure it's an asteroid
			# Check if the asteroid was mined; if so, ignore the exit
			if mined_asteroids.has(body):
				mined_asteroids.erase(body)
				#print("Asteroid mining completed; ignoring exit for:", body.name)
				return
			
			#print("Asteroid left the area:", body.name)
			# Stop mining and remove the timer if it exists
			if body in mining_timers:
				var timer = mining_timers[body]
				timer.stop()
				timer.queue_free()
				mining_timers.erase(body)

func mine_asteroid(asteroid: RigidBody2D) -> void:
	# Example mining logic
	#print("Mining asteroid:", asteroid.name)

	# Create a new Timer instance
	var timer = Timer.new()

	# Configure the Timer
	timer.wait_time = 10.0  # Set to your desired duration
	timer.one_shot = true  # Make it a one-shot timer (it will only run once)

	# Add the timer to the mining rig or parent node
	add_child(timer)

	# Connect the timer's timeout signal to a function
	timer.connect("timeout", Callable(self, "_on_timer_timeout").bind(asteroid))

	# Start the timer
	timer.start()

	# Store the timer reference for this asteroid
	mining_timers[asteroid] = timer

# This function will be called when the timer times out
func _on_timer_timeout(asteroid: RigidBody2D) -> void:
	if asteroid in mining_timers:
		#print("Asteroid mining complete:", asteroid.name)
		# Mark the asteroid as successfully mined
		mined_asteroids[asteroid] = true
		# Remove the asteroid from the tracking dictionary
		mining_timers.erase(asteroid)
		asteroid.queue_free()  # Destroy the asteroid
		
		# Retrieve the current iron quantity from the inventory
		var iron_quantity = Inventory.get_item_quantity("iron")
		
		# Update the iron quantity
		Inventory.set_item_quantity("iron", iron_quantity + 10)
		
		# Print updated Inventory
		Inventory.print_inventory()
		
