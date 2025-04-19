extends Control
@onready var btn_try_again: Button = $Btn_TryAgain
@onready var btn_quit: Button = $Btn_Quit
@onready var label: Label = %Label


func _ready() -> void:
	GameEvents.level_timer_expired.connect(func() -> void:
		get_tree().paused = true
		visible = true
		label.text = "Time Expired!!"	
	)
	
	GameEvents.car_crash.connect(func() -> void:
		get_tree().paused = true
		visible = true
		label.text = "CRASH!!"
	)
	
	btn_try_again.connect("pressed", func() -> void:
		get_tree().paused = false
		visible = false
		get_tree().reload_current_scene()
	)
	
	btn_quit.connect("pressed", func() -> void:
		get_tree().quit()	
	)
