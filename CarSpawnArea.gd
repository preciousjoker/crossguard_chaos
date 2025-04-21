class_name CarSpawnArea extends Area2D

@export var invalid_turn_direction: Car.ETurnDirection = Car.ETurnDirection.ALL # ALL is a poor identifier but it's a hack
@export var right_turn_only: bool = false
@export var left_turn_only: bool = false
@export var straight_only: bool = false
@onready var spawn_timer: Timer = %SpawnTimer
@export var car_scene = preload("res://car.tscn")
@export_range(1.0, 20.0, 1.0) var spawn_interval_min: float = 1.0
@export var spawn_interval_max: float = 5.0
var occupying_car: Car = null
var game_manager: GameManager
var world2D: Node2D = null

func _ready() -> void:
	game_manager = find_game_manager()
	
	spawn_timer.wait_time = set_new_wait_time()
	spawn_timer.start()
	spawn_timer.connect("timeout", func() -> void:
		if occupying_car == null and game_manager and game_manager.can_spawn():
			if world2D:
				# set up new car and add to scene
				var car: Car = car_scene.instantiate()
				car.determine_turn_direction(invalid_turn_direction, right_turn_only, left_turn_only, straight_only)
				car.set_rage_parameters(game_manager.max_time, game_manager.rage_increase, game_manager.queue_multiplier, game_manager.top_queue_multiplier)
				car.global_position = self.global_position
				car.global_rotation = self.global_rotation
				world2D.add_child(car)
				occupying_car = car
				
				# tell manager we spawned a car
				if game_manager:
					game_manager.cars_spawned += 1
					car.game_manager = game_manager
			
		# set new wait time for next spawn
		spawn_timer.wait_time = set_new_wait_time()
	)
	
	connect("area_exited", func(area: Area2D) -> void:
		if area is Car and occupying_car != null:
			if area.get_rid() == occupying_car.get_rid():
				occupying_car = null
	)
	
func set_new_wait_time() -> float:
	# get a random time interval between min and max
	return randf_range(
		spawn_interval_min,
		spawn_interval_max + 1.0
	)


func find_game_manager() -> GameManager:
	var root = get_tree().root
	var world = null
	for child in root.get_children(false):
		if child.name == "World":
			world = child
			world2D = world.find_child("World2D")
			game_manager = world.find_child("GameManager")
			return game_manager
			
	# did not find World or GameManager node
	return null
