extends Popup

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		_on_DoneButton_pressed()

func _on_DoneButton_pressed() -> void:
	hide()

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
