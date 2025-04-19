extends Control
@onready var btn_next_level: Button = %Btn_NextLevel
@onready var btn_quit: Button = %Btn_Quit


func _ready() -> void:
	GameEvents.level_cleared.connect(func() -> void:
		get_tree().paused = true
		visible = true	
	)
	
	btn_next_level.connect("pressed", func() -> void:
		#load next level
		GameEvents.load_next_level.emit()
	)
	
	btn_quit.connect("pressed", func() -> void:
		get_tree().quit()	
	)
