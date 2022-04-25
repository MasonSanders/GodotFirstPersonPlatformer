extends KinematicBody


# Called when the node enters the scene tree for the first time.
func _ready():
	$Particles.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !$Particles.emitting:
		queue_free()
