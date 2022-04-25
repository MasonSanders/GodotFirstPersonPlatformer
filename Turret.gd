extends RigidBody

var firing = false
var bullet_spawner
var fire_rate = 10
var rate_counter

# Called when the node enters the scene tree for the first time.
func _ready():
	rate_counter = 0
	bullet_spawner = preload("res://TurretBullet.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	rate_counter += 1
	if rate_counter > fire_rate:
		rate_counter = 0
	
	# delete this object if it goes below a certain point
	if global_transform.origin.y < 3:
		queue_free()
	
	# calculate the distane to the player
	var world_pos = $Gun.global_transform.origin
	var player = get_parent().get_node("Player").get_node("Head")
	var player_pos = player.global_transform.origin
	var player_dist = world_pos.distance_to(player_pos);
	var player_dir = world_pos.direction_to(player_pos);
	
	# decide whether or not the turret should be firing
	if player_dist < 25:
		firing = true
	else:
		firing = false
	
	if firing && rate_counter == fire_rate:
		var bullet = bullet_spawner.instance()
		owner.add_child(bullet)
		bullet.transform = $Gun.global_transform
		bullet.velocity = player_dir * bullet.bullet_speed
		
