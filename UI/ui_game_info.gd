extends Control

@onready var lbl_cars_left: Label = %Lbl_CarsLeft
@onready var lbl_time_left: Label = %Lbl_TimeLeft

var game_manager: GameManager = null

func _ready() -> void:
	var world: Node = null
	var root = get_tree().root
	
	GameEvents.level_timer_expired.connect(func() -> void:
		hide()	
	) 
	
	GameEvents.car_crash.connect(func() -> void:
		hide()	
	)
	
	# go through root children and find the world and game manager
	for child in root.get_children():
		print(child.name)
		if child.name == "World":
			world = child
	if world:
		game_manager = world.find_child("GameManager")
		lbl_cars_left.text = str(game_manager.cars_left)
	
	# Decrease cars left each time one is processed
	GameEvents.car_processed.connect(func() -> void:
		if game_manager:
			lbl_cars_left.text = str(game_manager.cars_left)
	)
	

func _process(delta: float) -> void:
	if game_manager:
		lbl_time_left.text = "%.2f" % game_manager.level_timer.time_left
