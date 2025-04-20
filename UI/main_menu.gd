extends Control

@onready var btn_play: Button = %Btn_Play
@onready var btn_how_to: Button = %Btn_HowTo
@onready var btn_quit: Button = %Btn_Quit


func _ready() -> void:
	btn_play.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")	
	)
	
	btn_how_to.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://lvl_how_to.tscn")
	)
	
