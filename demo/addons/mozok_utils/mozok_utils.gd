@tool
extends EditorPlugin

const MainPanel = preload("res://addons/mozok_utils/utils_screen.tscn")
var main_panel_instance : Control

const QuestHighlighter = preload("res://addons/mozok_utils/quest_highlighter.gd")
const QSFHighlighter = preload("res://addons/mozok_utils/qsf_highlighter.gd")
var quest_highlighter : EditorSyntaxHighlighter
var qsf_highlighter : EditorSyntaxHighlighter

func _enter_tree() -> void:
	_set_editor_settings()
	
	# Setting-uo the main panel.
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)
	
	# Add code highlighters.
	quest_highlighter = QuestHighlighter.new()
	qsf_highlighter = QSFHighlighter.new()
	var script_editor = EditorInterface.get_script_editor()
	script_editor.register_syntax_highlighter(quest_highlighter)
	script_editor.register_syntax_highlighter(qsf_highlighter)

func _exit_tree() -> void:
	# Remove syntax highlighters.
	var script_editor = EditorInterface.get_script_editor()
	if is_instance_valid(quest_highlighter):
		script_editor.unregister_syntax_highlighter(quest_highlighter)
		quest_highlighter = null
	if is_instance_valid(qsf_highlighter):
		script_editor.unregister_syntax_highlighter(qsf_highlighter)
		qsf_highlighter = null
		
	# Remove main panel.
	if is_instance_valid(main_panel_instance):
		main_panel_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible

func _get_plugin_name():
	return "LibMozok"

func _get_plugin_icon():
	return load("res://addons/mozok_utils/imgs/gdmozok-icon.svg") as Texture2D

func _set_editor_settings() -> void:
	var editor_settings = EditorInterface.get_editor_settings()
	
	# Add libmozok file extensions.
	const EXTENSIONS = "docks/filesystem/textfile_extensions"
	var extensions_val = editor_settings.get_setting(EXTENSIONS) as String
	var enabled = extensions_val.split(",")
	var add_extensions = ""
	if not ("quest" in enabled):
		add_extensions += ",quest"
	if not ("qsf" in enabled):
		add_extensions += ",qsf"
	if add_extensions.length() > 0:
		editor_settings.set_setting(
			EXTENSIONS, extensions_val + add_extensions)
