@tool
extends EditorSyntaxHighlighter

const COMMENT_COLOR = Color.WEB_GRAY
const KEYWORD_COLOR_1 = Color.CORAL
const KEYWORD_COLOR_2 = Color.SANDY_BROWN
const STD_COLOR = Color.WHITE_SMOKE

const SPECIAL = ":(),"
const SPECIAL_COLOR = Color.CORNFLOWER_BLUE

const TYPE_COLOR = Color.LIGHT_SKY_BLUE
const OBJECT_COLOR = Color.LIGHT_PINK
const REL_COLOR = Color.AQUAMARINE
const ACTION_COLOR = Color.GREEN_YELLOW
const QUEST_COLOR = Color.HOT_PINK
const MAIN_QUEST_COLOR = Color.CORNFLOWER_BLUE

const KEYWORDS = {
	"version" : [KEYWORD_COLOR_1, SPECIAL_COLOR],
	"project" : [KEYWORD_COLOR_1, SPECIAL_COLOR],
	"type" : [KEYWORD_COLOR_1, TYPE_COLOR],
	"object" : [KEYWORD_COLOR_1, OBJECT_COLOR],
	"include" : [KEYWORD_COLOR_1, STD_COLOR],
	"rel" : [KEYWORD_COLOR_1, REL_COLOR],
	"rlist" : [KEYWORD_COLOR_1, REL_COLOR],
	"action" : [KEYWORD_COLOR_1, ACTION_COLOR],
	"N/A" : [Color.RED, ACTION_COLOR],
	"pre" : [KEYWORD_COLOR_2, STD_COLOR],
	"rem" : [KEYWORD_COLOR_2, STD_COLOR],
	"add" : [KEYWORD_COLOR_2, STD_COLOR],
	"quest" : [KEYWORD_COLOR_1, QUEST_COLOR],
	"main_quest" : [KEYWORD_COLOR_1, MAIN_QUEST_COLOR],
	"preconditions" : [KEYWORD_COLOR_2, STD_COLOR],
	"goal" : [KEYWORD_COLOR_2, STD_COLOR],
	"actions" : [KEYWORD_COLOR_2, STD_COLOR],
	"objects" : [KEYWORD_COLOR_2, STD_COLOR],
	"subquests" : [KEYWORD_COLOR_2, STD_COLOR],
	"status" : [KEYWORD_COLOR_1, STD_COLOR],
	"ACTIVE" : [SPECIAL_COLOR, STD_COLOR],
	"INACTIVE" : [SPECIAL_COLOR, STD_COLOR],
	"DONE" : [SPECIAL_COLOR, STD_COLOR],
	"options" : [KEYWORD_COLOR_2, STD_COLOR],
	"searchLimit" : [KEYWORD_COLOR_1, SPECIAL_COLOR],
	"spaceLimit" : [KEYWORD_COLOR_1, SPECIAL_COLOR],
	"omega" : [KEYWORD_COLOR_1, SPECIAL_COLOR],
	"heuristic" : [KEYWORD_COLOR_1, SPECIAL_COLOR],
	"SIMPLE" : [SPECIAL_COLOR, STD_COLOR],
	"HSP" : [SPECIAL_COLOR, STD_COLOR],
	"use_atree" : [KEYWORD_COLOR_1, STD_COLOR],
	"strategy" : [KEYWORD_COLOR_1, STD_COLOR],
	"ASTAR" : [SPECIAL_COLOR, STD_COLOR],
	"DFS" : [SPECIAL_COLOR, STD_COLOR],
}

func _get_name() -> String:
	return "(LibMozok) .quest"

func _get_supported_languages() -> PackedStringArray:
	return ["TextFile"]

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var color_map = {}
	var text_editor = get_text_edit()
	var str = text_editor.get_line(line)

	color_map[0] = { "color": STD_COLOR }

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
			prev_line = prev_line.strip_edges()
			if prev_line.is_valid_identifier():
				continue
			if prev_line.ends_with(":"):
				if prev_line.begins_with("objects"):
					color_map[0] = { 
						"color": TYPE_COLOR if startsWithUpper else OBJECT_COLOR }
				elif prev_line.begins_with("actions"):
					color_map[0] = { "color": ACTION_COLOR }
				elif prev_line.begins_with("subquests"):
					color_map[0] = { "color": QUEST_COLOR }
			break

	# Comments
	var comment = str.find("#")
	if comment > -1:
		color_map[comment] = { "color": COMMENT_COLOR }
		str = str.substr(0, comment)

	# Keywords
	var is_object = false
	var is_type = false
	var is_rel = false
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
		if keyword == "object":
			is_object = true
		if keyword == "type":
			is_type = true
		if keyword == "rel":
			is_rel = true
		color_map[pos] = { "color": KEYWORDS[keyword][0] }
		color_map[pos + len(keyword)] = { "color": KEYWORDS[keyword][1] }

	# Special
	var std_col = STD_COLOR
	if is_object or is_type or is_rel:
		std_col = TYPE_COLOR
	for i in len(str):
		if SPECIAL.find(str[i]) >= 0:
			if SPECIAL.find(str[i]) == SPECIAL.find("("):
				std_col = OBJECT_COLOR
				color_map[
						color_map.keys().filter(func (n): return n < i).max()
						] = { "color": REL_COLOR }
			if SPECIAL.find(str[i]) == SPECIAL.find(":"):
				std_col = TYPE_COLOR
				if color_map[0]["color"] == STD_COLOR:
					color_map[0] = { "color": OBJECT_COLOR }
			color_map[i] = { "color": SPECIAL_COLOR }
			if color_map.keys().has(i+1) == false:
				color_map[i+1] = { "color": std_col }

	#print(color_map)
	color_map.sort()
	return color_map
