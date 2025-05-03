@tool
extends EditorSyntaxHighlighter

const COMMENT_COLOR = Color.WEB_GRAY
const KEYWORD_COLOR = Color.CORAL
const KEYWORD_COLOR_2 = Color.GOLD
const STD_COLOR = Color.WHITE_SMOKE

const SPECIAL = ":(),"
const SPECIAL_COLOR = Color.CORNFLOWER_BLUE

const FILE_COLOR = Color.DARK_GRAY
const WORLD_COLOR = Color.HOT_PINK
const OBJECT_COLOR = Color.LIGHT_PINK
const ACTION_COLOR = Color.GREEN_YELLOW
const EVENT_COLOR = Color.AQUA
const BLOCK_COLOR = Color.DARK_KHAKI
const CMD_COLOR = Color.LIGHT_SALMON
const TEXT_COLOR = Color.GRAY
const QUEST_COLOR = Color.HOT_PINK

const KEYWORDS = {
	"version" : [KEYWORD_COLOR, SPECIAL_COLOR],
	"script" : [KEYWORD_COLOR, SPECIAL_COLOR],
	"worlds" : [KEYWORD_COLOR, SPECIAL_COLOR],
	"projects" : [KEYWORD_COLOR, SPECIAL_COLOR],
	"init" : [KEYWORD_COLOR, SPECIAL_COLOR],
	"debug" : [KEYWORD_COLOR, SPECIAL_COLOR],
	
	"UNREACHABLE" : [KEYWORD_COLOR, SPECIAL_COLOR],
	"DONE" : [KEYWORD_COLOR, SPECIAL_COLOR],
	
	"onInit" : [EVENT_COLOR, SPECIAL_COLOR],
	"onNewMainQuest" : [EVENT_COLOR, SPECIAL_COLOR],
	"onNewSubQuest" : [EVENT_COLOR, SPECIAL_COLOR],
	"onNewQuestStatus" : [EVENT_COLOR, SPECIAL_COLOR],
	"onSearchLimitReached" : [EVENT_COLOR, SPECIAL_COLOR],
	"onSpaceLimitReached" : [EVENT_COLOR, SPECIAL_COLOR],
	"onAction" : [EVENT_COLOR, SPECIAL_COLOR],
	
	"ACT" : [KEYWORD_COLOR_2, BLOCK_COLOR],
	"ACT_IF" : [KEYWORD_COLOR_2, BLOCK_COLOR],
	"SPLIT" : [KEYWORD_COLOR_2, BLOCK_COLOR],
	"ALWAYS" : [KEYWORD_COLOR_2, BLOCK_COLOR],
	
	"expect" : [CMD_COLOR, SPECIAL_COLOR],
	"push" : [CMD_COLOR, SPECIAL_COLOR],
	"pause" : [CMD_COLOR, STD_COLOR],
	"print" : [CMD_COLOR, STD_COLOR],
	"exit" : [CMD_COLOR, STD_COLOR],
}

func _get_name() -> String:
	return "(LibMozok) .qsf"

func _get_supported_languages() -> PackedStringArray:
	return ["TextFile"]

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var color_map = {}
	var text_editor = get_text_edit()
	var str = text_editor.get_line(line)

	color_map[0] = { "color": STD_COLOR }

	# Comments
	var comment = str.find("#")
	if comment > -1:
		color_map[comment] = { "color": COMMENT_COLOR }
		str = str.substr(0, comment)

	# Some Commands
	for cmd in ["print ", "pause ", "exit "]:
		if (str.strip_edges() + " ").begins_with(cmd):
			color_map[0] = { "color": CMD_COLOR }
			color_map[str.find(cmd) + len(cmd)] = { "color": TEXT_COLOR }
			return color_map

	# Quest Sections:
	var startsWith = str.strip_edges().substr(0, 1)
	var startsWithUpper = startsWith == startsWith.to_upper()
	if line > 0:
		var l = line
		while l >= 0:
			l -= 1
			var prev_line = text_editor.get_line(l)
			if prev_line.contains("#"):
				prev_line = prev_line.substr(0, prev_line.find("#"))
			if prev_line.contains("]"):
				prev_line = prev_line.substr(prev_line.find("]") + 1)
			prev_line = prev_line.strip_edges()
			if prev_line.is_valid_identifier():
				continue
			if prev_line.ends_with(":"):
				if prev_line.begins_with("worlds"):
					color_map[0] = { "color": WORLD_COLOR }
			break

	# Keywords
	var need_col = ["worlds", "projects", "init", "debug"]
	for keyword in KEYWORDS.keys():
		var pos = str.find(keyword)
		if pos < 0:
			continue
		if pos > 0:
			var left = str.substr(pos - 1, len(keyword))
			if left.is_valid_identifier():
				continue
		if pos + len(keyword) <= len(str):
			var right = str.substr(pos, len(keyword) + 1)
			if right.is_valid_identifier():
				continue
		if keyword in need_col:
			if str.strip_edges().ends_with(":") == false:
				continue
		color_map[pos] = { "color": KEYWORDS[keyword][0] }
		color_map[pos + len(keyword)] = { "color": KEYWORDS[keyword][1] }

	# World
	if str.contains("[") and str.contains("]"):
		color_map[str.find("[")] = { "color": WORLD_COLOR }
		color_map[str.find("]") + 1] = { "color": STD_COLOR }

	# Special
	var std_col = STD_COLOR
	for i in len(str):
		if SPECIAL.find(str[i]) >= 0:
			if SPECIAL.find(str[i]) == SPECIAL.find("("):
				std_col = OBJECT_COLOR
				color_map[
						color_map.keys().filter(func (n): return n < i).max()
						] = { "color": ACTION_COLOR }
			color_map[i] = { "color": SPECIAL_COLOR }
			if color_map.keys().has(i+1) == false:
				color_map[i+1] = { "color": std_col }

	#print(color_map)
	color_map.sort()
	return color_map
