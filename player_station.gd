extends StaticBody2D

@onready var ui_area = $UIarea  # Reference to the Area2D node
@onready var inventory_window = $InventoryWindow  # Reference to the window
@onready var inventory_content = $InventoryWindow/Content  # Placeholder for inventory display
@onready var ship_iron_button = $InventoryWindow/ShipIron  # Button for transferring iron to the ship
@onready var station_iron_button = $InventoryWindow/StationIron  # Button for transferring iron to the station

func _ready() -> void:
	# Correctly connect signals
	ui_area.connect("body_entered", Callable(self, "_on_body_entered"))
	ui_area.connect("body_exited", Callable(self, "_on_body_exited"))
	#ship_iron_button.connect("pressed", Callable(self, "_on_ship_iron_pressed"))
	#station_iron_button.connect("pressed", Callable(self, "_on_station_iron_pressed"))
	inventory_window.visible = false  # Ensure the window starts hidden

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ship"):  # Ensure it's the player's ship
		show_inventory()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("ship"):  # Ensure it's the player's ship
		inventory_window.visible = false

# Function to show station inventory, transfer column, and player inventory
func show_inventory() -> void:
	inventory_window.visible = true
	# Clear previous content by removing all children
	for child in inventory_content.get_children():
		child.queue_free()

	# Create a horizontal container for side-by-side display
	var main_hbox = HBoxContainer.new()
	inventory_content.add_child(main_hbox)

	# Create a VBox for Station Inventory
	var station_vbox = VBoxContainer.new()
	main_hbox.add_child(station_vbox)

	# Add a header label for "Station Inventory"
	var station_header_label = Label.new()
	station_header_label.text = "Station Inventory:"
	station_vbox.add_child(station_header_label)

	# Add the items for station inventory
	var station_inventory = Inventory.station_inventory
	for item in station_inventory.keys():
		var item_label = Label.new()
		item_label.text = "%s: %d" % [item, station_inventory[item]]
		station_vbox.add_child(item_label)

	# Create a VBox for the transfer column
	var transfer_vbox = VBoxContainer.new()
	main_hbox.add_child(transfer_vbox)

	# Add a header label for "<<transfer>>"
	var transfer_header_label = Label.new()
	transfer_header_label.text = "<<transfer>>"
	transfer_vbox.add_child(transfer_header_label)

	# Add placeholder labels/buttons for the transfer functionality
	for _i in range(max(station_inventory.size(), Inventory.player_inventory.size())):
		var transfer_label = Label.new()
		transfer_label.text = "          ⇄"  # Transfer symbol
		transfer_vbox.add_child(transfer_label)

	# Create a VBox for Player Inventory
	var player_vbox = VBoxContainer.new()
	main_hbox.add_child(player_vbox)

	# Add a header label for "Player Inventory"
	var player_header_label = Label.new()
	player_header_label.text = "Player Inventory:"
	player_vbox.add_child(player_header_label)

	# Add the items for player inventory
	var player_inventory = Inventory.player_inventory
	for item in player_inventory.keys():
		var item_label = Label.new()
		item_label.text = "%s: %d" % [item, player_inventory[item]]
		player_vbox.add_child(item_label)

# Callback for transferring credits to the station
func _on_station_credit_pressed() -> void:
	var credit_amount = 100
	if Inventory.player_inventory != null and Inventory.player_inventory.get("credits", 0) >= credit_amount:
		Inventory.player_inventory["credits"] -= credit_amount
		Inventory.station_inventory["credits"] += credit_amount
	else:
		print("Not enough credits on the ship.")
	show_inventory()

# Callback for transferring credits to the ship
func _on_ship_credit_pressed() -> void:
	var credit_amount = 100
	if Inventory.station_inventory.get("credits", 0) >= credit_amount:
		Inventory.station_inventory["credits"] -= credit_amount
		Inventory.player_inventory["credits"] += credit_amount
	else:
		print("Not enough credits at the station.")
	show_inventory()

# Callback for transferring iron to the station
func _on_station_iron_pressed() -> void:
	var iron_amount = 10
	if Inventory.player_inventory != null and Inventory.player_inventory.get("iron", 0) >= iron_amount:
		Inventory.player_inventory["iron"] -= iron_amount
		Inventory.station_inventory["iron"] += iron_amount
	else:
		print("Not enough iron on the ship.")
	show_inventory()

# Callback for transferring iron to the ship
func _on_ship_iron_pressed() -> void:
	var iron_amount = 10
	if Inventory.station_inventory.get("iron", 0) >= iron_amount:
		Inventory.station_inventory["iron"] -= iron_amount
		Inventory.player_inventory["iron"] += iron_amount
	else:
		print("Not enough iron at the station.")
	show_inventory()
