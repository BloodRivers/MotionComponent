class_name MotionAnimationComponent extends Node

## A component that animates the position, rotation, and scale of a target node using sinusoidal motion.
##
## Supports enabling/disabling animations, adjusting amplitude and frequency, and pausing/resuming animations.

# Default values for animation parameters
const DEFAULT_POSITION_AMPLITUDE: Vector2 = Vector2(20.0, 20.0) # Maximum distance for position animation in pixels
const DEFAULT_ROTATION_AMPLITUDE: float = 10.0 # Maximum rotation angle in degrees
const DEFAULT_SCALE_AMPLITUDE: Vector2 = Vector2(0.1, 0.1) # Maximum scale factor
const DEFAULT_FREQUENCY: float = 1.0 # Animation speed in cycles per second

# The target node to animate. By default, this is the parent node.
@onready var target: Node = get_parent()

## Animation settings grouped by type
@export_category("Position Animation")
@export var animate_position: bool = true ## If [code]true[/code], enables position animation
@export var position_amplitude: Vector2 = DEFAULT_POSITION_AMPLITUDE ## Maximum distance the node will move from its initial position
@export var position_frequency: float = DEFAULT_FREQUENCY ## Speed of position animation in cycles per second

@export_category("Rotation Animation")
@export var animate_rotation: bool = true ## If [code]true[/code], enables rotation animation
@export var rotation_amplitude: float = DEFAULT_ROTATION_AMPLITUDE ## Maximum angle the node will rotate from its initial rotation
@export var rotation_frequency: float = DEFAULT_FREQUENCY ## Speed of rotation animation in cycles per second
@export var force_center_pivot: bool = true ## If [code]true[/code], forces the pivot to the center of the node

@export_category("Scale Animation")
@export var animate_scale: bool = false ## If [code]true[/code], enables scale animation
@export var scale_amplitude: Vector2 = DEFAULT_SCALE_AMPLITUDE ## Maximum scaling factor applied to the node's initial scale
@export var scale_frequency: float = DEFAULT_FREQUENCY ## Speed of scale animation in cycles per second

@export_category("Animation Control")
@export var paused: bool = false ## If [code]true[/code], pauses all animations

# Internal state tracking
var _time_elapsed: float = 0.0
var _initial_state: Dictionary = {
	"position": Vector2.ZERO,
	"rotation": 0.0,
	"scale": Vector2.ONE,
}


# Sets up processing and initializes the target node's state.
func _ready() -> void:
	# Enables or disables the _process function based on whether any animations are active.
	set_process(animate_position or animate_rotation or animate_scale)
	
	# Initializes the target node's initial state in a deferred call to ensure the node is ready.
	call_deferred("_init_target")


# Initializes the target node's state
func _init_target() -> void:
	_initial_state["position"] = target.position
	_initial_state["rotation"] = target.rotation_degrees
	_initial_state["scale"] = target.scale
	
	if force_center_pivot:
		target.pivot_offset = target.size / 2


# Resets the target node's transform properties to their initial values.
func _reset() -> void:
	if target:
		target.position = _initial_state["position"]
		target.rotation_degrees = _initial_state["rotation"]
		target.scale = _initial_state["scale"]


func _process(delta: float) -> void:
	if paused:
		return
	
	_time_elapsed += delta
	
	_apply_animations()


# Applies all enabled animations to the target node.
func _apply_animations() -> void:
	if animate_position:
		_animate_position_sinusoidal()
	if animate_rotation:
		_animate_rotation_sinusoidal()
	if animate_scale:
		_animate_scale_sinusoidal()


# Applies sinusoidal motion to the target node's position.
func _animate_position_sinusoidal() -> void:
	var offset: Vector2 = Vector2(
		_calculate_sinusoidal_offset(position_amplitude.x, position_frequency),
		_calculate_sinusoidal_offset(position_amplitude.y, position_frequency)
	)
	target.position = _initial_state["position"] + offset


# Applies sinusoidal motion to the target node's rotation.
func _animate_rotation_sinusoidal() -> void:
	var rotation_angle: float = _calculate_sinusoidal_offset(rotation_amplitude, rotation_frequency)
	target.rotation_degrees = _initial_state["rotation"] + rotation_angle


# Applies sinusoidal motion to the target node's scale.
func _animate_scale_sinusoidal() -> void:
	var scale_offset: Vector2 = Vector2(
		_calculate_sinusoidal_offset(scale_amplitude.x, scale_frequency),
		_calculate_sinusoidal_offset(scale_amplitude.y, scale_frequency)
	)
	target.scale = _initial_state["scale"] + scale_offset


# Calculates a sinusoidal offset based on amplitude and frequency.
func _calculate_sinusoidal_offset(amplitude: float, frequency: float) -> float:
	return amplitude * sin(_time_elapsed * frequency * TAU)
