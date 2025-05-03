@tool
class_name SelectOptionNode
extends PanelContainer

signal option_selected(indx : int)
signal selection_changed(indx : int)
signal back_pressed()

@export var active : bool = true:
	get: return active
	set(value): 
		active = value
		_set_active(value)
@export var loop : bool = true

## If `true` will makes height big enough to fit all the options.
@export var fit_options : bool = false:
	get: return fit_options
	set(value):
		fit_options = value
		_rebuild_list()
		_update_selection()

@export var options : Array[String] = [ "Option #1", "Option #2" ]:
	get: return options
	set(value):
		options = value
		_rebuild_list()
		selected = selected
		#_update_selection()

@export var selected : int = 0:
	get: return selected
	set(value): 
		selected = value
		if value < 0:
			selected = options.size() - 1 if loop else 0
		if value >= options.size():
			selected = options.size() - 1 if not loop else 0
		emit_signal("selection_changed", selected)
		_update_selection()

@onready var _options = $ScrollContainer/Options
@onready var _space_1 = $OptionsTemplates/Space_1.duplicate()
@onready var _space_2 = $OptionsTemplates/Space_2.duplicate()
@onready var _selected = $OptionsTemplates/Selected.duplicate()
@onready var _unselected = $OptionsTemplates/Unselected.duplicate()
@onready var _active_theme = load(
		"res://assets/gui/other/choice_panel_active.tres") as StyleBoxFlat

func _ready() -> void:
	_set_active(active)
	_rebuild_list()
	_update_selection()

func _input(event: InputEvent) -> void:
	if not active:
		return
	elif event.is_action_pressed("menu_up"):
		selected -= 1
	elif event.is_action_pressed("menu_down"):
		selected += 1
	elif event.is_action_pressed("menu_select"):
		Input.action_release("use")
		Input.action_release("menu_select")
		emit_signal("option_selected", selected)
	elif event.is_action_pressed("menu_back"):
		emit_signal("back_pressed")

func _process(delta: float) -> void:
	if fit_options:
		await get_tree().process_frame
		custom_minimum_size.y = $ScrollContainer/Options.size.y

func _rebuild_list() -> void:
	if not is_node_ready():
		return
	for n in _options.get_children():
		_options.remove_child(n)
	_options.add_child(_space_1)
	_options.add_child(_selected)
	for i in options.size():
		var option = _unselected.duplicate()
		option.get_child(1).text = str(i + 1) + "."
		option.get_child(2).text = options[i]
		_options.add_child(option)
	_options.add_child(_space_2)

func _update_selection() -> void:
	if not is_node_ready():
		return
	var indx = max(0, min(options.size(), selected))
	_selected.get_child(1).text = str(indx + 1) + "." 
	_selected.get_child(2).text = options[indx]
	_options.move_child(_selected, 1)
	for n in _options.get_children():
		n.show()
	_options.get_child(2 + indx).hide()
	_options.move_child(_selected, 1 + indx)
	await get_tree().process_frame
	$ScrollContainer.ensure_control_visible(_selected)

func _set_active(value : bool) -> void:
	set("theme_override_styles/panel", _active_theme if value else null)
