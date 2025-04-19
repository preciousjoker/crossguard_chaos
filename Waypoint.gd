@tool
class_name Waypoint extends Area2D

# Use a different way to access nodes in tool script
var collision_shape_2d: CollisionShape2D

# Store the color value separately
var _waypoint_color: Color = Color.WHITE
@onready var lane_label: Label = %LaneLabel
@export var owning_lane: int = 0:
	set(value):
		owning_lane = value
		if Engine.is_editor_hint():
			lane_label.text = "Lane: %s" % ([owning_lane])
			# Force redraw when this property is toggled in editor
			queue_redraw()
@export var left_waypoint: Waypoint = null
@export var right_waypoint: Waypoint = null
@export var waypoint_color: Color:
	get:
		return _waypoint_color
	set(value):
		_waypoint_color = value
		_update_debug_color()
		
# If you need to update the line when a property changes
@export var update_line: bool = false:
	set(value):
		update_line = value
		if Engine.is_editor_hint():
			lane_label.text = "Lane: %s" % ([owning_lane])
			# Force redraw when this property is toggled in editor
			queue_redraw()

func _ready():
	# Get the reference when the node is ready
	collision_shape_2d = %CollisionShape2D
	if Engine.is_editor_hint():
		_update_debug_color()
		queue_redraw()
	else:
		lane_label.hide()
	

func _draw() -> void:
	if Engine.is_editor_hint():
		if left_waypoint == null and right_waypoint == null:
			return
		
		#draw left waypoint line
		if left_waypoint:
			var end = to_local(left_waypoint.global_position)
			draw_line(Vector2.ZERO, end, Color.LIME, 2.0)
		
		if right_waypoint:
			var end = to_local(right_waypoint.global_position)
			draw_line(Vector2.ZERO, end, Color.RED, 2.0)
		
		
func _update_debug_color():
	if collision_shape_2d != null:
		collision_shape_2d.debug_color = _waypoint_color
