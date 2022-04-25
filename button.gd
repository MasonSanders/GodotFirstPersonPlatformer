extends KinematicBody

# determines whether or not this button has been pressed
var pressing_enabled
var player_can_press

# Called when the node enters the scene tree for the first time.
func _ready():
	pressing_enabled = true
	player_can_press = false

func _physics_process(delta):
	# calcualte the distance from the player
	# determine if the player can press the button
	if pressing_enabled:
		var player = get_parent().get_node("Player")
		var world_pos = global_transform.origin
		var player_pos = player.global_transform.origin
		var player_dist = world_pos.distance_to(player_pos)
		if player_dist <= 3:
			player_can_press = true
		else:
			player_can_press = false
