extends CanvasLayer




# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthLabel.text = "Health: 100"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HealthLabel.text = "Health: " + str(get_parent().get_node("Player").health)
