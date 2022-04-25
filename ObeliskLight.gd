extends KinematicBody


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$CollisionShape.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
