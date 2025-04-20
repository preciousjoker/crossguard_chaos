extends Area2D

func _ready() -> void:
	connect("input_event", on_input_event)


func on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var click = event as InputEventMouseButton
	if click and click.pressed and click.button_index == 1:
		print("Clicked car test")
