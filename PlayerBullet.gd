extends KinematicBody

var velocity = Vector3.ZERO
var bullet_speed = 15
var push = 20
var explosion_spawner

# Called when the node enters the scene tree for the first time.
func _ready():
	explosion_spawner = preload("res://Explosion.tscn")
	
func _physics_process(delta):
	var collision = move_and_collide(velocity * delta, false)
	
	# calculate distace to player
	var world_pos = global_transform.origin
	var player = get_parent().get_node("Player")
	var player_pos = player.global_transform.origin
	var player_dist = world_pos.distance_to(player_pos)
	
	if collision:
		# create an explosion on collision
		var explosion = explosion_spawner.instance()
		get_parent().add_child(explosion)
		explosion.transform = global_transform
		
		if collision.collider.is_in_group("Turrets"):
			collision.collider.apply_central_impulse(-collision.normal * push)
		queue_free()
	# free from queue if the bullet is far enough away from the player
	if player_dist >= 20:
		queue_free()

