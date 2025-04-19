class_name StopArea extends Area2D
@onready var car_sprite: Sprite2D = %CarSprite

@export var signal_key: Key = KEY_J
@export var list_of_waypoints: Array[Waypoint] = []

var car: Car = null
var was_signal_key_pressed = false
var game_manager: GameManager = null

func _ready() -> void:
	game_manager = find_game_manager()
	connect("area_entered", func(area: Area2D) -> void:
		if area is Car:
			area.stop(true)
			car = area
			car.set_valid_waypoints(list_of_waypoints)
			if game_manager:
				game_manager.car_queue.push_back(car)
	)
	
	car_sprite.hide()


func _process(delta: float) -> void:
	if Input.is_key_pressed(signal_key) and !was_signal_key_pressed:
		was_signal_key_pressed = true
	
	if !Input.is_key_pressed(signal_key) and was_signal_key_pressed:
		was_signal_key_pressed = false
		if car != null:
			car.can_build_rage = false
			car.disable_brake_check()
			car.requires_signal_to_go = false
			car.drive()
			
	# Update tracking variable for next frame
	was_signal_key_pressed = Input.is_key_pressed(signal_key)


func find_game_manager():
	var root = get_tree().root
	var world: Node = null
	for child in root.get_children():
		if child.name == "World":
			world = child
			if world:
				game_manager = world.find_child("GameManager")
				if game_manager:
					return game_manager
	
	return null
