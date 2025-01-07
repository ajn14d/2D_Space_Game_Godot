extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	# Change to the SpaceGameplay scene
	get_tree().change_scene_to_file("res://space_gameplay.tscn")


func _on_quit_button_pressed() -> void:
	# Terminate the game
	get_tree().quit()
