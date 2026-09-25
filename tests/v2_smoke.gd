extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_new_story()
	assert(game.state == "intro" and game.intro_phase == 0)
	assert(game.voice.stream.data.size() > 0, "Opening voice-like sound must exist")
	game.update_intro(1.8)
	assert(game.intro_phase == 1)
	game.update_intro(2.4)
	assert(game.state == "card" and game.card_kind == "slime")
	var frozen_pos: Vector2 = game.player_pos
	game._process(1.0)
	assert(game.player_pos == frozen_pos, "Character card must pause walking")
	game.advance_card()
	assert(game.card_kind == "friend")
	game.advance_card()
	assert(game.state == "intro" and game.intro_phase == 2)
	for tick in 150:
		game.update_intro(0.05)
		if game.intro_phase == 3: break
	assert(game.intro_phase == 3, "Friends must reach the commander")
	assert(game.camera_x > 0.0, "Camera must follow the walk")
	game.update_intro(3.4)
	assert(game.state == "card" and game.card_kind == "commander")
	game.advance_card()
	assert(game.intro_phase == 4)
	for tick in 400:
		game.update_intro(0.05)
		if game.state == "tutorial": break
	assert(game.state == "tutorial", "Scout, monster rush, and battle tutorial must play")
	game.start_prologue_battle()
	assert(game.command_cap() == 0)
	assert(game.heroes.size() == 1 and game.allies.size() >= 12)
	assert(play_battle(game, 0), "Prologue hero must be defeatable with friends")
	assert(game.state == "promotion" and game.prologue_done)

	game.start_stage(1)
	assert(game.command_cap() == 4 and game.heroes.size() == 1)
	game.summon_squad()
	assert(game.controlled_count() == 2)
	assert(play_battle(game, 1), "Stage 1 must be winnable")
	assert(game.state == "reward" and game.chest_offers.size() == 3)
	var frost_index := -1
	for i in game.chest_offers.size():
		if game.chest_offers[i]["id"] == "frost": frost_index = i
	assert(frost_index >= 0, "Stage 1 must offer the next needed counter")
	game.choose_reward(frost_index)
	assert(game.state == "shop" and game.frost_hired)

	game.start_stage(2)
	assert(game.command_cap() >= 6 and game.cores.size() == 2 and game.heroes.size() == 2)
	assert(play_battle(game, 2), "Stage 2 must be winnable by walking between places")
	assert(game.state == "reward" and game.chest_offers.size() == 3)
	var captain_index := -1
	for i in game.chest_offers.size():
		if game.chest_offers[i]["id"] == "captain": captain_index = i
	assert(captain_index >= 0)
	game.choose_reward(captain_index)
	assert(game.captain_hired)

	game.start_stage(3)
	assert(game.command_cap() >= 10 and game.pending_heroes.size() == 1)
	assert(play_battle(game, 3), "Stage 3 must be winnable against three heroes")
	assert(game.state == "reward" and game.gold > 0)
	assert(FileAccess.file_exists("user://save_v2.cfg"))
	var reloaded = load("res://main_v2.gd").new()
	root.add_child(reloaded)
	assert(reloaded.state == "title" and reloaded.next_stage == 4)
	print("V2_SMOKE_OK: opening, cards, rush, prologue, stages 1-3, rewards, save")
	reloaded.free()
	game.free()
	quit(0)

func play_battle(game: Node2D, stage: int) -> bool:
	for tick in 4200:
		if game.state == "promotion" or game.state == "reward": return true
		if game.state == "lost":
			print("BATTLE_LOST stage=", stage, " elapsed=", game.elapsed, " player_hp=", game.player_hp)
			return false
		if not game.heroes.is_empty():
			var target: Dictionary = game.heroes[0]
			for hero in game.heroes:
				if game.player_pos.distance_to(hero["pos"]) < game.player_pos.distance_to(target["pos"]): target = hero
			game.player_pos = game.player_pos.move_toward(target["pos"] + Vector2(-52, 0), 245.0 * 0.05)
			if stage > 0 and tick % 68 == 0 and game.controlled_count() + game.SQUADS[game.equipped_squad]["members"].size() <= game.command_cap():
				game.summon_squad()
			if tick % 52 == 0: game.dash()
		game.update_battle(0.05)
	print("BATTLE_TIMEOUT stage=", stage, " heroes=", game.heroes.size())
	return false
