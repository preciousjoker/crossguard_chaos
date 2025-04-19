class_name Car extends Area2D

enum ETurnDirection {NONE = 0, RIGHT = 1, LEFT = 2}
enum EDriveMode {STOP = 0, TURNING = 1, DRIVE = 2}
@onready var turn_signal_timer: Timer = %TurnSignalTimer
@onready var car_sprite: Sprite2D = %CarSprite
@onready var ray_cast_2d: RayCast2D = %RayCast2D
@onready var left_turn_light: Sprite2D = %LeftTurnLight
@onready var right_turn_light: Sprite2D = %RightTurnLight
@onready var rage_meter: ProgressBar = %RageMeter

@export var stop_distance = 100.0
@export var max_speed: float = 600.0
@export var turn_signal_interval: float = 0.15
@export var possible_colors: Array[Color] = []
@export_category("Rage")
@export var max_time: float = 20.0
@export var rage_increase: float = 0.25
@export var queue_multiplier: float = 1.25
@export var top_queue_multiplier: float = 1.75
var can_build_rage: bool = true

var valid_waypoints: Array[Waypoint] = []
var _waypoint: Waypoint = null
var _previous_waypoint: Waypoint = null
var should_brake: bool = true	
var requires_signal_to_go = false
var will_turn: bool = false
var turn_direction: ETurnDirection = ETurnDirection.NONE
var drive_mode: EDriveMode = EDriveMode.DRIVE
var game_manager: GameManager = null


func set_valid_waypoints(waypoints: Array[Waypoint]) -> void:
	valid_waypoints = waypoints


func assign_random_color() -> void:
	var index = randi_range(0, len(possible_colors)-1)
	car_sprite.modulate = possible_colors[index]


func prepare_rage_meter() -> void:
	rage_meter.max_value = max_time / rage_increase
	print("Max Value: %f" % rage_meter.max_value)
	rage_meter.value = 0.0


func _ready() -> void:
	prepare_rage_meter()
	assign_random_color()
	determine_turn_direction()
	ray_cast_2d.exclude_parent = true
	ray_cast_2d.set_target_position(to_local(position + (transform.x * stop_distance)))
	
	# handle when car enters RemovalArea
	self.connect("area_entered", func(area: Area2D) -> void:
		if area is RemovalArea:
			GameEvents.car_processed.emit()
			queue_free()	
		
		if area is Waypoint and turn_direction != ETurnDirection.NONE:
			#Change mode to turn and set waypoint so that process can work correctly
			#print("Attempting to turn %s" % ([str(turn_direction)]))
			update_waypoint(area)
	)
	
	# turn signal logic
	turn_signal_timer.wait_time = turn_signal_interval
	turn_signal_timer.connect("timeout", func() -> void:
		toggle_turn_light(turn_direction)
	)
	turn_signal_timer.start(0.0)


func toggle_turn_light(turn_direction: ETurnDirection) -> void:
	if turn_direction == ETurnDirection.RIGHT:
		right_turn_light.visible = !right_turn_light.visible
	
	if turn_direction == ETurnDirection.LEFT:
		left_turn_light.visible = !left_turn_light.visible

func update_waypoint(waypoint: Waypoint) -> void:
	# make sure this waypoint is part of our valid waypoints
	if !waypoint in valid_waypoints:
		return
	
	if turn_direction == ETurnDirection.RIGHT and waypoint.right_waypoint != null:
		_waypoint = waypoint.right_waypoint
		_previous_waypoint = waypoint
		drive_mode = EDriveMode.TURNING
	elif turn_direction == ETurnDirection.LEFT and waypoint.left_waypoint != null:
		_waypoint = waypoint.left_waypoint
		_previous_waypoint = waypoint
		drive_mode = EDriveMode.TURNING
	else:
		_waypoint = null
		_previous_waypoint = null
		drive_mode = EDriveMode.DRIVE
	

func update_rage_meter(delta: float) -> void:
	# do nothing if we can't get angry (rage)
	if !can_build_rage:
		return
	
	var additional_increase := 0.0
	var top_of_queue := false
	#check if top of queue
	if game_manager:
		top_of_queue = len(game_manager.car_queue) > 0 and game_manager.car_queue[0] == self
		if top_of_queue:
			#print("Car at top of queue: %s" % self.name)
			additional_increase += top_queue_multiplier
	
	# check if in queue
	if !top_of_queue and len(game_manager.car_queue) > 0 and game_manager.car_queue.has(self):
		#print("Car in queue but not at the top: %s" % self.name)
		additional_increase += queue_multiplier

		
	var amount_increase: float = (rage_increase + additional_increase) * delta
	rage_meter.value += amount_increase


func _process(delta: float) -> void:
	update_rage_meter(delta)


func _physics_process(delta: float) -> void:
	match drive_mode:
		EDriveMode.DRIVE:
			update_drive_mode_straight(delta)
		EDriveMode.TURNING:
			update_drive_mode_turn(delta)
		EDriveMode.STOP:
			update_drive_mode_stop(delta)


func update_drive_mode_turn(delta: float) -> void:
	var velocity := transform.x * max_speed
	var desired_velocity := global_position.direction_to(_waypoint.global_position).normalized() * max_speed
	var steering_velocity := desired_velocity - velocity
	
	velocity += steering_velocity
	
	global_position += velocity * delta
	global_rotation = _previous_waypoint.global_position.direction_to(_waypoint.global_position).angle()
	
	if ray_cast_2d.is_colliding():
		var object = ray_cast_2d.get_collider()
		if object is Car and !should_brake:
			print("Car crashed")
			GameEvents.car_crash.emit()
	

func update_drive_mode_stop(delta: float) -> void:
	if not ray_cast_2d.is_colliding() and !requires_signal_to_go:
		drive_mode = EDriveMode.DRIVE


func update_drive_mode_straight(delta: float) -> void:
	# if we collide with another car then stop
	if ray_cast_2d.is_colliding():
		var object = ray_cast_2d.get_collider()
		if object is Car and should_brake:
			drive_mode = EDriveMode.STOP
		
		if object is Car and !should_brake:
			print("Car crashed")
			GameEvents.car_crash.emit()
			
			
	var direction := transform.x
	var velocity := direction * max_speed * delta
	
	global_position += velocity
	
	

func determine_turn_direction():
	# determine if this car will turn. Need to determine right or left?
	var rand_range = randf_range(0.0, 1.0)
	will_turn = rand_range > 0.50
	
	# determine turn direction if we're turning, otherwise keep default value of no turn
	if will_turn:
		var turn_direction_value = randf_range(0.0, 1.0)
		turn_direction = ETurnDirection.LEFT if turn_direction_value > 0.5 else ETurnDirection.RIGHT
		#print("Turn direction value: %f - Turn Direction: %s" % ([turn_direction_value, str(turn_direction)]))


func stop(in_stop_area: bool) -> void:
	drive_mode = EDriveMode.STOP
	
	if in_stop_area:
		requires_signal_to_go = true
	
func drive() -> void:
	drive_mode = EDriveMode.DRIVE
	
func disable_brake_check() -> void:
	should_brake = false
