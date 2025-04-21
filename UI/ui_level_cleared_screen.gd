extends Control
@onready var btn_next_level: Button = %Btn_NextLevel
@onready var btn_quit: Button = %Btn_Quit
@export var next_level_name: String = ""


func _ready() -> void:
	GameEvents.level_cleared.connect(func() -> void:
		get_tree().paused = true
		visible = true	
	)
	
	btn_next_level.connect("pressed", func() -> void:
		#load next level
		get_tree().paused = false
		var next_level_path: String = "res://Levels/" + next_level_name + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
	)
	
	btn_quit.connect("pressed", func() -> void:
		get_tree().quit()	
	)
