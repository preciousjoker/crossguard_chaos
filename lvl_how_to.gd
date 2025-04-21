extends Control
@onready var btn_next = %Btn_Next
@onready var btn_previous = %Btn_Previous
@onready var how_to_1 = %HowTo_1
@onready var how_to_2 = %HowTo_2
@onready var how_to_3 = %HowTo_3
@onready var btn_play = %Btn_Play

const HOW_TO_PREFIX = "HowTo_"
var pages: int = 0
var current_page: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_page(0)
	
	btn_next.connect("pressed", func() -> void:
		current_page += 1
		current_page = clampi(current_page, 0, 2)
		print("Current Page on Next: %d" % current_page)
		show_page(current_page)
	)
	
	btn_previous.connect("pressed", func() -> void:
		current_page -= 1
		current_page = clampi(current_page, 0, 2)
		show_page(current_page)	
	)
	
	btn_play.connect("pressed", func() -> void:
		get_tree().change_scene_to_file("res://Levels/Level1.tscn")
	)


func show_page(idx: int) -> void:
	match idx:
		0:
			how_to_1.show()
			how_to_2.hide()
			how_to_3.hide()
			btn_next.show()
			btn_previous.hide()
			btn_play.hide()
		1:
			how_to_1.hide()
			how_to_2.show()
			how_to_3.hide()
			btn_next.show()
			btn_previous.show()
			btn_play.hide()
		2:
			how_to_1.hide()
			how_to_2.hide()
			how_to_3.show()
			btn_next.hide()
			btn_previous.show()
			btn_play.show()
	
