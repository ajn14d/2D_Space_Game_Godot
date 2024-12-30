extends StaticBody2D

@onready var ui_area = $UIarea  # Reference to the Area2D node
@onready var shop_window = $ShopWindow  # Reference to the window
@onready var shop_content = $ShopWindow/Content  # Placeholder for inventory display

func _ready() -> void:
	# Correctly connect signals
	ui_area.connect("body_entered", Callable(self, "_on_body_entered"))
	ui_area.connect("body_exited", Callable(self, "_on_body_exited"))
	shop_window.visible = false  # Ensure the window starts hidden

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ship"):  # Ensure it's the player's ship
		show_inventory()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("ship"):  # Ensure it's the player's ship
		shop_window.visible = false

func show_inventory() -> void:
	shop_window.visible = true
	# Clear previous content by removing all children
	for child in shop_content.get_children():
		child.queue_free()

	# Add a header label for "Station Inventory"
	var header_label = Label.new()
	header_label.text = "Player Inventory :"
	shop_content.add_child(header_label)

	# Add the items below the header
	var player_inventory = Inventory.player_inventory
	for item in player_inventory.keys():
		var item_label = Label.new()
		item_label.text = "%s: %d" % [item, player_inventory[item]]
		shop_content.add_child(item_label)


func _on_sell_cargo_pressed() -> void:
	var iron_value = 10  # Each unit of iron is worth 10 credits
	var iron_quantity = Inventory.player_inventory.get("iron", 0)  # Get the amount of iron in the inventory
	
	if iron_quantity > 0:
		var total_credits = iron_quantity * iron_value  # Calculate total credits for the iron
		Inventory.player_inventory["credits"] += total_credits  # Add credits to the player's inventory
		Inventory.player_inventory["iron"] = 0  # Subtract all iron (set quantity to 0)
		print("Sold %d iron for %d credits!" % [iron_quantity, total_credits])
	else:
		print("No iron to sell!")

	# Update the inventory display
	show_inventory()
