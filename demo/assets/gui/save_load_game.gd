extends Control

signal option_selected(indx : int)

func _ready() -> void:
	hide()

func activate(title : String, options : Array[String]) -> void:
	show()
	get_tree().paused = true
	%TitleLabel.text = title
	%ChoicePanel.options = options
	%ChoicePanel.active = true

func _on_choice_panel_back_pressed() -> void:
	%ChoicePanel.selected = 9

func _on_choice_panel_option_selected(indx: int) -> void:
	hide()
	%ChoicePanel.active = false
	get_tree().paused = false
	emit_signal("option_selected", indx)
