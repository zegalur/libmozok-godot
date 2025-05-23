# Auto-generated by LibMozok Utils Plugin.
# Working Dir: res://assets/quests/tutorials/
# Main QSF: main.qsf
# Date/Time: 2025-05-03T19:59:40

class_name T

class tut:
	static var objects = [
		"controlsTutorial",
		"movementAction",
		"attackAction",
		"hideAction",
		"fightingTutorial",
		"killEnemyAction",
		"blockAttackAction",
		"takeHitAction",
		"takeHeartAction",
		"dieAction",
		"keyTutorial",
		"pickUpKeyAction",
		"openDoorAction",
		"puzzleTutorial",
		"puzzleTutorial_GetHeart",
		"pt_cell_00",
		"pt_cell_01",
		"pt_cell_02",
		"pt_cell_03",
		"pt_cell_10",
		"pt_cell_11",
		"pt_cell_12",
		"pt_cell_13",
		"pt_cell_20",
		"pt_cell_21",
		"pt_cell_22",
		"pt_cell_23",
		"pt_cell_30",
		"pt_cell_31",
		"pt_cell_32",
		"pt_cell_33",
		"portalTutorial",
		]

	enum ApplyTutorialAction_1_tutorialAction {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	static func ApplyTutorialAction(
			data : int,
			server : LibMozokServer,
			tutorialAction : ApplyTutorialAction_1_tutorialAction,
			):
		server.pushAction(
				"tut", 
				"ApplyTutorialAction", 
				[
					objects[tutorialAction], 
				], 
				data)

	enum FinishTutorial_2_1_tutorial {
		controlsTutorial = 0,
		fightingTutorial = 4,
		keyTutorial = 10,
		puzzleTutorial = 13,
		puzzleTutorial_GetHeart = 14,
		portalTutorial = 31,
		}

	enum FinishTutorial_2_2_action1 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	enum FinishTutorial_2_3_action2 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	static func FinishTutorial_2(
			data : int,
			server : LibMozokServer,
			tutorial : FinishTutorial_2_1_tutorial,
			action1 : FinishTutorial_2_2_action1,
			action2 : FinishTutorial_2_3_action2,
			):
		server.pushAction(
				"tut", 
				"FinishTutorial_2", 
				[
					objects[tutorial], 
					objects[action1], 
					objects[action2], 
				], 
				data)

	enum FinishTutorial_3_1_tutorial {
		controlsTutorial = 0,
		fightingTutorial = 4,
		keyTutorial = 10,
		puzzleTutorial = 13,
		puzzleTutorial_GetHeart = 14,
		portalTutorial = 31,
		}

	enum FinishTutorial_3_2_action1 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	enum FinishTutorial_3_3_action2 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	enum FinishTutorial_3_4_action3 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	static func FinishTutorial_3(
			data : int,
			server : LibMozokServer,
			tutorial : FinishTutorial_3_1_tutorial,
			action1 : FinishTutorial_3_2_action1,
			action2 : FinishTutorial_3_3_action2,
			action3 : FinishTutorial_3_4_action3,
			):
		server.pushAction(
				"tut", 
				"FinishTutorial_3", 
				[
					objects[tutorial], 
					objects[action1], 
					objects[action2], 
					objects[action3], 
				], 
				data)

	enum FinishTutorial_5_1_tutorial {
		controlsTutorial = 0,
		fightingTutorial = 4,
		keyTutorial = 10,
		puzzleTutorial = 13,
		puzzleTutorial_GetHeart = 14,
		portalTutorial = 31,
		}

	enum FinishTutorial_5_2_action1 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	enum FinishTutorial_5_3_action2 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	enum FinishTutorial_5_4_action3 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	enum FinishTutorial_5_5_action4 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	enum FinishTutorial_5_6_action5 {
		movementAction = 1,
		attackAction = 2,
		hideAction = 3,
		killEnemyAction = 5,
		blockAttackAction = 6,
		takeHitAction = 7,
		takeHeartAction = 8,
		dieAction = 9,
		pickUpKeyAction = 11,
		openDoorAction = 12,
		}

	static func FinishTutorial_5(
			data : int,
			server : LibMozokServer,
			tutorial : FinishTutorial_5_1_tutorial,
			action1 : FinishTutorial_5_2_action1,
			action2 : FinishTutorial_5_3_action2,
			action3 : FinishTutorial_5_4_action3,
			action4 : FinishTutorial_5_5_action4,
			action5 : FinishTutorial_5_6_action5,
			):
		server.pushAction(
				"tut", 
				"FinishTutorial_5", 
				[
					objects[tutorial], 
					objects[action1], 
					objects[action2], 
					objects[action3], 
					objects[action4], 
					objects[action5], 
				], 
				data)

	enum ControlsTutorial_1_tutorial {
		controlsTutorial = 0,
		}

	static func ControlsTutorial(
			data : int,
			server : LibMozokServer,
			tutorial : ControlsTutorial_1_tutorial,
			):
		server.pushAction(
				"tut", 
				"ControlsTutorial", 
				[
					objects[tutorial], 
				], 
				data)

	enum FightingTutorial_1_prevTutorial {
		controlsTutorial = 0,
		}

	enum FightingTutorial_2_tutorial {
		fightingTutorial = 4,
		}

	static func FightingTutorial(
			data : int,
			server : LibMozokServer,
			prevTutorial : FightingTutorial_1_prevTutorial,
			tutorial : FightingTutorial_2_tutorial,
			):
		server.pushAction(
				"tut", 
				"FightingTutorial", 
				[
					objects[prevTutorial], 
					objects[tutorial], 
				], 
				data)

	enum KeyTutorial_1_prevTutorial {
		fightingTutorial = 4,
		}

	enum KeyTutorial_2_tutorial {
		keyTutorial = 10,
		}

	static func KeyTutorial(
			data : int,
			server : LibMozokServer,
			prevTutorial : KeyTutorial_1_prevTutorial,
			tutorial : KeyTutorial_2_tutorial,
			):
		server.pushAction(
				"tut", 
				"KeyTutorial", 
				[
					objects[prevTutorial], 
					objects[tutorial], 
				], 
				data)

	static func PTut_BlockExit(
			data : int,
			server : LibMozokServer,
			):
		server.pushAction(
				"tut", 
				"PTut_BlockExit", 
				[
				], 
				data)

	enum PTut_MoveLeft_1_a {
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	enum PTut_MoveLeft_2_b {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		}

	static func PTut_MoveLeft(
			data : int,
			server : LibMozokServer,
			a : PTut_MoveLeft_1_a,
			b : PTut_MoveLeft_2_b,
			):
		server.pushAction(
				"tut", 
				"PTut_MoveLeft", 
				[
					objects[a], 
					objects[b], 
				], 
				data)

	enum PTut_MoveRight_1_a {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		}

	enum PTut_MoveRight_2_b {
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	static func PTut_MoveRight(
			data : int,
			server : LibMozokServer,
			a : PTut_MoveRight_1_a,
			b : PTut_MoveRight_2_b,
			):
		server.pushAction(
				"tut", 
				"PTut_MoveRight", 
				[
					objects[a], 
					objects[b], 
				], 
				data)

	enum PTut_MoveUp_1_a {
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	enum PTut_MoveUp_2_b {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		}

	static func PTut_MoveUp(
			data : int,
			server : LibMozokServer,
			a : PTut_MoveUp_1_a,
			b : PTut_MoveUp_2_b,
			):
		server.pushAction(
				"tut", 
				"PTut_MoveUp", 
				[
					objects[a], 
					objects[b], 
				], 
				data)

	enum PTut_MoveDown_1_a {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		}

	enum PTut_MoveDown_2_b {
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	static func PTut_MoveDown(
			data : int,
			server : LibMozokServer,
			a : PTut_MoveDown_1_a,
			b : PTut_MoveDown_2_b,
			):
		server.pushAction(
				"tut", 
				"PTut_MoveDown", 
				[
					objects[a], 
					objects[b], 
				], 
				data)

	enum PTut_PushLeft_1_a {
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	enum PTut_PushLeft_2_b {
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	enum PTut_PushLeft_3_c {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		}

	static func PTut_PushLeft(
			data : int,
			server : LibMozokServer,
			a : PTut_PushLeft_1_a,
			b : PTut_PushLeft_2_b,
			c : PTut_PushLeft_3_c,
			):
		server.pushAction(
				"tut", 
				"PTut_PushLeft", 
				[
					objects[a], 
					objects[b], 
					objects[c], 
				], 
				data)

	enum PTut_PushRight_1_a {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		}

	enum PTut_PushRight_2_b {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		}

	enum PTut_PushRight_3_c {
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	static func PTut_PushRight(
			data : int,
			server : LibMozokServer,
			a : PTut_PushRight_1_a,
			b : PTut_PushRight_2_b,
			c : PTut_PushRight_3_c,
			):
		server.pushAction(
				"tut", 
				"PTut_PushRight", 
				[
					objects[a], 
					objects[b], 
					objects[c], 
				], 
				data)

	enum PTut_PushUp_1_a {
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	enum PTut_PushUp_2_b {
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	enum PTut_PushUp_3_c {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		}

	static func PTut_PushUp(
			data : int,
			server : LibMozokServer,
			a : PTut_PushUp_1_a,
			b : PTut_PushUp_2_b,
			c : PTut_PushUp_3_c,
			):
		server.pushAction(
				"tut", 
				"PTut_PushUp", 
				[
					objects[a], 
					objects[b], 
					objects[c], 
				], 
				data)

	enum PTut_PushDown_1_a {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		}

	enum PTut_PushDown_2_b {
		pt_cell_00 = 15,
		pt_cell_01 = 16,
		pt_cell_02 = 17,
		pt_cell_03 = 18,
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		}

	enum PTut_PushDown_3_c {
		pt_cell_10 = 19,
		pt_cell_11 = 20,
		pt_cell_12 = 21,
		pt_cell_13 = 22,
		pt_cell_20 = 23,
		pt_cell_21 = 24,
		pt_cell_22 = 25,
		pt_cell_23 = 26,
		pt_cell_30 = 27,
		pt_cell_31 = 28,
		pt_cell_32 = 29,
		pt_cell_33 = 30,
		}

	static func PTut_PushDown(
			data : int,
			server : LibMozokServer,
			a : PTut_PushDown_1_a,
			b : PTut_PushDown_2_b,
			c : PTut_PushDown_3_c,
			):
		server.pushAction(
				"tut", 
				"PTut_PushDown", 
				[
					objects[a], 
					objects[b], 
					objects[c], 
				], 
				data)

	enum PTut_Finish_1_player_cell {
		pt_cell_00 = 15,
		}

	enum PTut_Finish_2_main_tutorial {
		puzzleTutorial = 13,
		}

	enum PTut_Finish_3_tutorial {
		puzzleTutorial_GetHeart = 14,
		}

	static func PTut_Finish(
			data : int,
			server : LibMozokServer,
			player_cell : PTut_Finish_1_player_cell,
			main_tutorial : PTut_Finish_2_main_tutorial,
			tutorial : PTut_Finish_3_tutorial,
			):
		server.pushAction(
				"tut", 
				"PTut_Finish", 
				[
					objects[player_cell], 
					objects[main_tutorial], 
					objects[tutorial], 
				], 
				data)

	enum PTut_Cancel_1_player_cell {
		pt_cell_00 = 15,
		}

	enum PTut_Cancel_2_main_tutorial {
		puzzleTutorial = 13,
		}

	enum PTut_Cancel_3_tutorial {
		puzzleTutorial_GetHeart = 14,
		}

	static func PTut_Cancel(
			data : int,
			server : LibMozokServer,
			player_cell : PTut_Cancel_1_player_cell,
			main_tutorial : PTut_Cancel_2_main_tutorial,
			tutorial : PTut_Cancel_3_tutorial,
			):
		server.pushAction(
				"tut", 
				"PTut_Cancel", 
				[
					objects[player_cell], 
					objects[main_tutorial], 
					objects[tutorial], 
				], 
				data)

	enum PuzzleTutorial_GetHeart_1_main_tutorial {
		puzzleTutorial = 13,
		}

	enum PuzzleTutorial_GetHeart_2_tutorial {
		puzzleTutorial_GetHeart = 14,
		}

	static func PuzzleTutorial_GetHeart(
			data : int,
			server : LibMozokServer,
			main_tutorial : PuzzleTutorial_GetHeart_1_main_tutorial,
			tutorial : PuzzleTutorial_GetHeart_2_tutorial,
			):
		server.pushAction(
				"tut", 
				"PuzzleTutorial_GetHeart", 
				[
					objects[main_tutorial], 
					objects[tutorial], 
				], 
				data)

	enum PuzzleTutorial_1_prevTutorial {
		keyTutorial = 10,
		}

	enum PuzzleTutorial_2_tutorial {
		puzzleTutorial = 13,
		}

	static func PuzzleTutorial(
			data : int,
			server : LibMozokServer,
			prevTutorial : PuzzleTutorial_1_prevTutorial,
			tutorial : PuzzleTutorial_2_tutorial,
			):
		server.pushAction(
				"tut", 
				"PuzzleTutorial", 
				[
					objects[prevTutorial], 
					objects[tutorial], 
				], 
				data)

	static func PTut_BlockEntrance(
			data : int,
			server : LibMozokServer,
			):
		server.pushAction(
				"tut", 
				"PTut_BlockEntrance", 
				[
				], 
				data)

	enum MoveToPortal_1_entrance_cell {
		pt_cell_33 = 30,
		}

	enum MoveToPortal_2_tutorial {
		portalTutorial = 31,
		}

	static func MoveToPortal(
			data : int,
			server : LibMozokServer,
			entrance_cell : MoveToPortal_1_entrance_cell,
			tutorial : MoveToPortal_2_tutorial,
			):
		server.pushAction(
				"tut", 
				"MoveToPortal", 
				[
					objects[entrance_cell], 
					objects[tutorial], 
				], 
				data)

	enum PortalTutorial_1_prevTutorial {
		puzzleTutorial = 13,
		}

	enum PortalTutorial_2_tutorial {
		portalTutorial = 31,
		}

	enum PortalTutorial_3_entrance {
		pt_cell_33 = 30,
		}

	static func PortalTutorial(
			data : int,
			server : LibMozokServer,
			prevTutorial : PortalTutorial_1_prevTutorial,
			tutorial : PortalTutorial_2_tutorial,
			entrance : PortalTutorial_3_entrance,
			):
		server.pushAction(
				"tut", 
				"PortalTutorial", 
				[
					objects[prevTutorial], 
					objects[tutorial], 
					objects[entrance], 
				], 
				data)

	static func InitTutorials(
			data : int,
			server : LibMozokServer,
			):
		server.pushAction(
				"tut", 
				"InitTutorials", 
				[
				], 
				data)
