extends State

class_name SpinningState

export var boost_power: float = 150
export var gravity_scale: float = 0.5
var old_gravity_scale = 1
var can_boost = true
var cooldown_timer = 0

func _ready():
	priority = 2
	disable_animation = true

func _start_check(delta):
	return character.is_action_pressed("spin") && (character.state == null or character.state != character.get_state_node("DiveState")) and character.jump_animation != 2 and !character.test_move(character.transform, Vector2(8, 0)) and !character.test_move(character.transform, Vector2(-8, 0))

func _start(delta):
	if can_boost == true && !character.is_grounded() && (character.state != character.get_state_node("Jump") or character.current_jump == 1):
		can_boost = false
		cooldown_timer = 0.5
		if character.velocity.y > -boost_power:
			if character.velocity.y > 100:
				character.velocity.y /= 1.5
			if character.velocity.y > 0:
				character.velocity.y -= boost_power
			else:
				character.velocity.y -= boost_power/2
	old_gravity_scale = character.gravity_scale
	character.gravity_scale = gravity_scale
	
func _update(delta):
	var sprite = character.animated_sprite
	if character.is_grounded():
		priority = 0
	else:
		priority = 2
	if sprite.animation != "spinning":
		sprite.animation = "spinning"
	if character.velocity.y < 0:
		character.gravity_scale = old_gravity_scale
	else:
		character.gravity_scale = gravity_scale
		
func _stop(delta):
	character.gravity_scale = old_gravity_scale
	priority = 2

func _stop_check(delta):
	return !character.is_action_pressed("spin") or character.test_move(character.transform, Vector2(8, 0)) or character.test_move(character.transform, Vector2(-8, 0))
	
func _general_update(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0
			can_boost = true
	if character.is_grounded():
		can_boost = true