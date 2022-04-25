extends Spatial

var change_level = false
var current_scene_name

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_scene_name = get_tree().get_current_scene().get_name()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# change scenes
	if change_level:
		if current_scene_name == "Level":
			get_tree().change_scene("res://Level2.tscn")
		elif current_scene_name == "Level2":
			get_tree().change_scene("res://Level3.tscn")
		elif current_scene_name == "Level3":
			get_tree().change_scene("res://Level4.tscn")
		elif current_scene_name == "Level4":
			get_tree().change_scene("res://EndScreen.tscn")
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
