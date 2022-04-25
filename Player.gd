extends KinematicBody

# player states 
var spawn_pos
var spawn_rot
var spawn_head_rot
var velocity = Vector3.ZERO
var speed = 10
var rotate_speed = 0.01
var gravity = -0.2
var jump_speed = 4
var double_jump = false
var wall_jump = false
var has_light = false
var can_deposit = false
var health = 100
var death = false
var bullet_spawner
# sounds
var deposit_sound
var collect_sound
var btn_press_sound
var shock_sound
# the index of the electric field the player can disable
var electric_field_index

# Called when the node enters the scene tree for the first time.
func _ready():
	# get the spawn position to relocate upon death
	spawn_pos = global_transform.origin
	electric_field_index = 0
	spawn_rot = rotation_degrees
	spawn_head_rot = $Head.rotation_degrees
	deposit_sound = get_parent().get_node("Deposit")
	collect_sound = get_parent().get_node("Collect")
	shock_sound = get_parent().get_node("Shock")
	btn_press_sound = get_parent().get_node("Press")
	bullet_spawner = preload("res://PlayerBullet.tscn")
	
# handle_input method
func handle_input():
	# input
	if Input.is_action_pressed("forward"):
		velocity += transform.basis.z
	if Input.is_action_pressed("back"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("left"):
		velocity += transform.basis.x
	if Input.is_action_pressed("right"):
		velocity -= transform.basis.x
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() || (is_on_wall() && !wall_jump) || (!double_jump && !wall_jump):
			velocity.y = jump_speed
			# wall and double jump
			if is_on_wall():
				double_jump = false
				wall_jump = true
				speed = 12
			if !is_on_floor() && !is_on_wall():
				wall_jump = false
				double_jump = true
	
	# handle shooting
	if Input.is_action_just_pressed("shoot"):
		var bullet = bullet_spawner.instance()
		owner.add_child(bullet)
		bullet.transform = $Head/Gun.global_transform
		bullet.velocity = bullet.transform.basis.z * bullet.bullet_speed
		
	# handle interacting with objects
	if Input.is_action_just_pressed("interact"):
		# handle depositing the light sphere
		var electric_fields = get_tree().get_nodes_in_group("ElectricFields")
		var btns = get_tree().get_nodes_in_group("Buttons") 
		if can_deposit:
			has_light = false
			var ob_light = get_parent().get_node("ObeliskLight")
			ob_light.visible = true
			var portal = get_parent().get_node("Portal")
			portal.visible = true
			portal.get_node("CollisionShape").disabled = false 
			deposit_sound.play()
		# handle button pressing
		if !(electric_field_index >= btns.size()):
			if btns[electric_field_index].player_can_press:
				btn_press_sound.play()
				electric_fields[electric_field_index].visible = false
				electric_fields[electric_field_index].get_node("CollisionShape").disabled = true
				btns[electric_field_index].pressing_enabled = false;
				electric_field_index += 1
			
# end handle_input

# handle_collisions
func handle_collisions():
	# handle collision with move and slide
	if get_slide_collision(0):
		var collision = get_slide_collision(0)
		if collision:
			var coll_body = collision.collider
			# check for collision with light sphere
			if coll_body.name == "LightSphere":
				coll_body.visible = false
				coll_body.get_node("CollisionShape").disabled = true
				has_light = true
				collect_sound.play()
			# check for collison with the death plane
			if coll_body.name == "DeathPlane":
				death = true
			# check for collision with an electric field
			if coll_body.is_in_group("ElectricFields"):
				shock_sound.play()
				death = true
			# check for collision with the portal
			if coll_body.name == "Portal":
				get_parent().change_level = true
# end handle_collisions

# handle_death
func handle_death():
	if health <= 0 || death:
		var current_scene_name = get_tree().get_current_scene().get_name()
		get_tree().change_scene("res://" + current_scene_name + ".tscn")
# end handle_death

func handle_interactivity():
	# calculate distance to obelisk
	var world_pos = global_transform.origin
	var obelisk = get_parent().get_node("obelisk")
	var ob_pos = obelisk.global_transform.origin
	var ob_dist = world_pos.distance_to(ob_pos)
	
	# can the player deposit the light sphere?
	if has_light:
		if (ob_dist <= 3):
			can_deposit = true
		else:
			can_deposit = false
	else:
		can_deposit = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# first check for death conditions
	handle_death()

	# reset necessary jumping variables
	if is_on_floor():
		double_jump = false
		wall_jump = false
		speed = 10
		velocity.y = 0
	if wall_jump && is_on_wall():
		wall_jump = true
	else:
		wall_jump = false
	
	# make the player fall from gravity
	velocity.y += gravity
	
	# reset x and z velocity
	velocity.x = 0
	velocity.z = 0
	
	# input
	handle_input()
	
	# movement
	move_and_slide(velocity * speed, Vector3.UP)
	
	# collisions
	handle_collisions()
	
	# handle the player's ability to interact with other objects
	handle_interactivity()

# handle mouse movement
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-rotate_speed * event.relative.x /10)
		$Head.rotate_x(rotate_speed * event.relative.y /10)
		
		# limit head rotation so you can't go upside down
		if $Head.rotation_degrees.x > 90:
			$Head.rotation_degrees.x = 90
		if $Head.rotation_degrees.x < -90:
			$Head.rotation_degrees.x = -90
