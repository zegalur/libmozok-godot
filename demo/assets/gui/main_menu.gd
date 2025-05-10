extends Control
## Main menu screen.

signal tutorial()
signal new_game()
signal load_game()
signal exit()

const M_TUTORIAL = 0
const M_NEW_GAME = 1
const M_LOAD = 2
const M_EXIT = 3


## Deactivates the main menu's choice panel.
func deactivate() -> void:
	%Menu.active = false


## Activates the main menu's choice panel.
func activate() -> void:
	%Menu.active = true


func _on_menu_option_selected(indx: int) -> void:
	if indx == M_TUTORIAL:
		emit_signal("tutorial")
	elif indx == M_NEW_GAME:
		emit_signal("new_game")
	elif indx == M_LOAD:
		emit_signal("load_game")
	elif indx == M_EXIT:
		emit_signal("exit")


func _on_menu_back_pressed() -> void:
	%Menu.selected = M_EXIT
