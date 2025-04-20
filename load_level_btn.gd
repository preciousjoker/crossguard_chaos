extends Button

func _ready() -> void:
	self.connect("pressed", func() -> void:
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")	
	)
