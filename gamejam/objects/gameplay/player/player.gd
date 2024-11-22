extends CharacterBody2D

enum ColorState {NONE, BLUE, RED, GREEN, YELLOW, PURPLE}
var current_color: ColorState = ColorState.NONE

@onready var sprite: AnimatedSprite2D = $sprite
@onready var movement = $movement
@onready var color_particles = $color_particles

# Color-specific ability cooldowns
var color_cooldowns = {
	ColorState.BLUE: 0.0,
	ColorState.RED: 0.0,
	ColorState.GREEN: 0.0,
	ColorState.YELLOW: 0.0,
	ColorState.PURPLE: 0.0
}
const COOLDOWN_TIME = 2.0

func _ready():
	# Verify particle system exists
	if !color_particles:
		push_warning("Color particles node not found - visual effects disabled")
	else:
		color_particles.emitting = false

func _process(delta):
	# Update cooldowns
	for color in color_cooldowns.keys():
		if color_cooldowns[color] > 0:
			color_cooldowns[color] = max(0, color_cooldowns[color] - delta)
	
	# Update visual effects based on current color
	update_color_effects()

func _physics_process(_delta):
	# Color-specific movement modifications
	match current_color:
		ColorState.BLUE:
			movement.sticky_distance = 32  # Better ice grip
		ColorState.GREEN:
			movement.jump_height = 300  # Higher jumps
		ColorState.PURPLE:
			movement.air_strafe_multiplier = 1.5  # Better air control
		_:
			# Reset to default values
			movement.reset_config()

func _input(event):
	# Color switching inputs
	if event.is_action_pressed("switch_blue"):
		switch_color(ColorState.BLUE)
	elif event.is_action_pressed("switch_red"):
		switch_color(ColorState.RED)
	elif event.is_action_pressed("switch_green"):
		switch_color(ColorState.GREEN)
	elif event.is_action_pressed("switch_yellow"):
		switch_color(ColorState.YELLOW)
	elif event.is_action_pressed("switch_purple"):
		switch_color(ColorState.PURPLE)
	
	# Color ability activation
	if event.is_action_pressed("activate_ability"):
		activate_color_ability()

func switch_color(new_color: ColorState):
	if current_color == new_color:
		return
	
	current_color = new_color
	update_color_effects()
	
	# Emit signal for color change
	emit_signal("color_changed", current_color)

func activate_color_ability():
	if color_cooldowns[current_color] > 0:
		return
		
	match current_color:
		ColorState.BLUE:
			freeze_nearby()
		ColorState.RED:
			burn_nearby()
		ColorState.GREEN:
			grow_platform()
		ColorState.YELLOW:
			emit_light()
		ColorState.PURPLE:
			teleport_forward()
	
	color_cooldowns[current_color] = COOLDOWN_TIME

func update_color_effects():
	match current_color:
		ColorState.NONE:
			sprite.modulate = Color.WHITE
		ColorState.BLUE:
			sprite.modulate = Color(0.5, 0.5, 1.0)
		ColorState.RED:
			sprite.modulate = Color(1.0, 0.5, 0.5)
		ColorState.GREEN:
			sprite.modulate = Color(0.5, 1.0, 0.5)
		ColorState.YELLOW:
			sprite.modulate = Color(1.0, 1.0, 0.5)
		ColorState.PURPLE:
			sprite.modulate = Color(1.0, 0.5, 1.0)

# Color ability implementations
func freeze_nearby():
	# Implement freezing mechanic
	pass

func burn_nearby():
	# Implement burning mechanic
	pass

func grow_platform():
	# Implement platform growing mechanic
	pass

func emit_light():
	# Implement light emission mechanic
	pass

func teleport_forward():
	var teleport_distance = 100
	var direction = Vector2.RIGHT if sprite.flip_h else Vector2.LEFT
	position += direction * teleport_distance

func set_particles_emitting(value: bool) -> void:
	if color_particles:
		color_particles.emitting = value

func update_particle_color(color: Color) -> void:
	if color_particles:
		# Assuming particles have a "color" property
		color_particles.process_material.color = color
