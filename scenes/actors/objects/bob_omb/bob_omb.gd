extends GameObject

onready var sprite_container = $KinematicBody2D/Sprites
onready var sprite = $KinematicBody2D/Sprites/Sprite
onready var fuse = $KinematicBody2D/Sprites/Fuse
onready var fuse_sound = $KinematicBody2D/FuseSound
onready var fuse_sound_2 = $KinematicBody2D/FuseSound2
onready var explosion_sound = $KinematicBody2D/ExplosionSound
onready var body = $KinematicBody2D
onready var player_detector = $KinematicBody2D/PlayerDetector
onready var particles = $KinematicBody2D/Particles2D
onready var damage_area = $KinematicBody2D/DamageArea
onready var attack_area = $KinematicBody2D/AttackArea
onready var grounded_check = $KinematicBody2D/RayCast2D
onready var platform_detector = $KinematicBody2D/PlatformDetector
onready var raycasts = [grounded_check]
var dead = false
var character
var character_damage
var character_attack

var gravity : float
var velocity := Vector2()

var walk_timer = 0.0
var walk_wait = 3.0
var explode_timer = 0.0
var damage_timer = 0.0
var delete_timer = 0.0
var passive_speed = 30
var run_speed = 180
var accel = 5

var facing_direction := -1
var time_alive = 0.0

var hit = false
var loaded = true
var snap := Vector2(0, 12)

func _set_properties():
	savable_properties = []
	editable_properties = []
	
func _set_property_values():
	pass

func player_entered(body):
	if enabled and body.name.begins_with("Character") and !dead and character == null:
		character = body
		explode_timer = 4
		fuse_sound.play()
		
func create_coin():
	var object = LevelObject.new()
	object.type_id = 1
	object.properties = []
	object.properties.append(body.global_position)
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	object.properties.append(true)
	var velocity_x = -80 if int(time_alive * 10) % 2 == 0 else 80
	object.properties.append(Vector2(velocity_x, -300))
	get_parent().create_object(object, false)

func _ready():
	player_detector.connect("body_entered", self, "player_entered")
	CurrentLevelData.enemies_instanced += 1
	time_alive += float(CurrentLevelData.enemies_instanced) / 2.0
	gravity = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.gravity
	
func _process(delta):
	fuse.frame = sprite.frame
	if mode == 1:
		sprite.frame = wrapi(OS.get_ticks_msec() / 166, 0, 8)
		
func exploded(explosion_pos : Vector2):
	hit = true
	snap = Vector2(0, 0)
	velocity.x = (body.global_position - explosion_pos).normalized().x * 275
	velocity.y = -275
	position.y -= 4
	explode_timer = 4
	character = 0 # hacks are fun
	
func shell_hit(shell_pos : Vector2):
	hit = true
	snap = Vector2(0, 0)
	body.set_collision_layer_bit(2, false)
	explode_timer = 4
	velocity.x = (body.global_position - shell_pos).normalized().x * 275
	velocity.y = -275
	position.y -= 4
	character = 0 # hacker chungus

func _physics_process(delta):
	var is_in_platform = false
	var platform_collision_enabled = false
	for platform_body in platform_detector.get_overlapping_areas():
		if platform_body.has_method("is_platform_area"):
			if platform_body.is_platform_area():
				is_in_platform = true
			if platform_body.get_parent().can_collide_with(body):
				platform_collision_enabled = true
	body.set_collision_mask_bit(4, platform_collision_enabled)
	for raycast in raycasts:
		raycast.set_collision_mask_bit(4, platform_collision_enabled)
	
	time_alive += delta
	if delete_timer > 0 and dead:
		delete_timer -= delta
		if delete_timer <= 0:
			delete_timer = 0
			queue_free()
			
	var level_size = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.size
	if body.global_position.y > (level_size.y * 32) + 128:
		queue_free()
			
	if damage_timer > 0:
		damage_timer -= delta
		fuse_sound_2.playing = false
		for hit_body in damage_area.get_overlapping_bodies():
			if hit_body.has_method("exploded"):
				hit_body.exploded(body.global_position)
			elif hit_body.get_parent().has_method("exploded"):
				hit_body.get_parent().exploded(body.global_position)
		if damage_timer < 0:
			damage_timer = 0
	
	if mode != 1 and enabled and !dead and loaded:
		if hit:
			sprite_container.rotation_degrees += -facing_direction * 5
			if grounded_check.is_colliding():
				explode_timer = 0.001
				hit = false
				
		if !hit:
			snap = Vector2(0, 12) if !is_in_platform else Vector2(0, 0)
			for hit_body in attack_area.get_overlapping_bodies():
				if hit_body.name.begins_with("Character"):
					var character_attack = hit_body
					if character_attack.attacking:
						hit = true
						body.set_collision_layer_bit(2, false)
						snap = Vector2(0, 0)
						velocity.x = (body.global_position - character_attack.global_position).normalized().x * 275
						velocity.y = -275
						position.y -= 4
					else:
						var distance_normal = (body.global_position - character_attack.global_position).normalized().x
						if character_attack.state != character_attack.get_state_node("KnockbackState"):
							if distance_normal == 0:
								distance_normal = -1
							
							velocity.x = 50 * distance_normal
							character_attack.velocity.x = 50 * -distance_normal
				
		sprite.flip_h = true if facing_direction == 1 else false
		velocity.y += gravity
		velocity = body.move_and_slide_with_snap(velocity, snap, Vector2.UP.normalized(), true, 4, deg2rad(46))
		if character == null:
			if walk_wait > 0:
				sprite.animation = "default"
				velocity.x = lerp(velocity.x, 0, delta * accel)
				walk_wait -= delta
				if walk_wait <= 0:
					walk_wait = 0
					walk_timer = float(int(time_alive * 10) % 3) + 1.0
					facing_direction = -facing_direction if int(time_alive * 10) % 2 == 0 else facing_direction
			if walk_timer > 0:
				sprite.animation = "walking"
				velocity.x = lerp(velocity.x, facing_direction * passive_speed, delta * accel)
				walk_timer -= delta
				if walk_timer <= 0:
					walk_timer = 0
					walk_wait = 3.0
			if (
				body.global_position.x < -64 or 
				body.global_position.x > (level_size.x * 32) + 64
			):
				queue_free()
		else:
			if explode_timer > 0:
				explode_timer -= delta
				if explode_timer <= 3.68 and !dead:
					if !fuse_sound_2.playing:
						fuse_sound_2.play()
					sprite.modulate = lerp(sprite.modulate, Color(1, 0, 0), delta / 4.5)
				if explode_timer <= 0:
					fuse_sound.stop()
					fuse_sound_2.stop()
					explosion_sound.play()
					particles.emitting = true
					sprite.visible = false
					fuse.visible = false
					dead = true
					damage_timer = 0.35
					delete_timer = 3.0
					create_coin()
			if !dead and !hit:
				facing_direction = 1 if (character.global_position.x > body.global_position.x) else -1
				velocity.x = lerp(velocity.x, facing_direction * run_speed, delta * accel)
				fuse.visible = true
				sprite.animation = "walking"
				sprite.speed_scale = lerp(sprite.speed_scale, run_speed / passive_speed, delta * accel)
				fuse.speed_scale = lerp(fuse.speed_scale, run_speed / passive_speed, delta * accel)