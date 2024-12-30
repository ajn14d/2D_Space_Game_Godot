extends Node

# Inventory dictionaries for station and player
@export var station_inventory: Dictionary = {"iron": 0, "credits": 0}
@export var player_inventory: Dictionary = {"iron": 0, "credits": 0}

# Function to get the current quantity of an item in the station inventory
func get_item_quantity(item: String) -> int:
	return station_inventory.get(item, 0)

# Function to set the quantity of an item in the station inventory
func set_item_quantity(item: String, quantity: int) -> void:
	if quantity < 0:
		print("Quantity cannot be negative.")
		return
	station_inventory[item] = quantity

# Function to print the station inventory (debugging)
func print_inventory() -> void:
	print("Station Inventory:")
	for item in station_inventory.keys():
		print(" - ", item, ": ", station_inventory[item])


# Function to get the current quantity of an item in the player inventory
func get_player_item_quantity(item: String) -> int:
	return player_inventory.get(item, 0)

# Function to set the quantity of an item in the player inventory
func set_player_item_quantity(item: String, quantity: int) -> void:
	if quantity < 0:
		print("Quantity cannot be negative.")
		return
	player_inventory[item] = quantity

# Function to print the player inventory (debugging)
func print_player_inventory() -> void:
	print("Player Inventory:")
	for item in player_inventory.keys():
		print(" - ", item, ": ", player_inventory[item])
