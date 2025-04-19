class_name GameManager extends Node

@onready var level_timer: Timer = %LevelTimer
@export var next_level: PackedScene = null
@export var max_cars: int = 50
@export var time_limit: float = 60.0

var cars_left: int = 0
var cars_spawned = 0
var car_queue: Array[Car] = []


func _ready() -> void:
	cars_left = max_cars
	level_timer.wait_time = time_limit
	level_timer.connect("timeout", func() -> void:
		print("Time in level has run out. Bring out menu")
		GameEvents.level_timer_expired.emit()
	)
	level_timer.start(0.0)
	
	GameEvents.car_processed.connect(func() -> void:
		cars_left -= 1
		print("Cars left: %d" % cars_left)
		if cars_left <= 0:
			GameEvents.level_cleared.emit()
	)
	
	GameEvents.load_next_level.connect(func() -> void:
		print("Loading next level")	
	)

func can_spawn() -> bool:
	return cars_spawned < max_cars
