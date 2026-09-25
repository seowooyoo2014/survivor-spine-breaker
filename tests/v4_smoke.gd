extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_new_story()
	assert(game.state == "intro")
	assert(game.voice.stream.data.size() > 0)
	game.update_intro(1.8)
	game.update_intro(2.4)
	assert(game.state == "card" and game.card_kind == "slime")
	game.advance_card()
	assert(game.card_kind == "friend")
	game.advance_card()
	for tick in 150:
		game.update_intro(0.05)
		if game.intro_phase == 3: break
	assert(game.intro_phase == 3)
	game.update_intro(3.4)
	assert(game.state == "card" and game.card_kind == "commander")
	var source := FileAccess.get_file_as_string("res://main_v4.gd")
	assert(source.contains("아쿠마") and source.contains("말록") and source.contains("바츠"))
	assert(not source.contains("말랑") and not source.contains("달각") and not source.contains("그루크"))
	game.start_prologue_battle()
	var hero: Dictionary = game.heroes[0]
	hero["pos"] = game.player_pos + Vector2(130, 0)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = hero["pos"] - Vector2(game.camera_x, 0)
	game._unhandled_input(click)
	assert(game.slime_shots.size() == 1)
	var old_hp: float = hero["hp"]
	game.update_slime_shots(0.2)
	assert(hero["hp"] < old_hp and game.slime_shots.is_empty(), "Click projectile must hit")
	var friend: Dictionary = {}
	var commander: Dictionary = {}
	for ally in game.allies:
		if ally["kind"] == "friend": friend = ally
		if ally["kind"] == "commander": commander = ally
	assert(not friend.is_empty() and not commander.is_empty())
	friend["hp"] = 0.0
	commander["hp"] = 0.0
	game.update_allies(0.01)
	assert(friend["downed"] and commander["downed"] and game.allies.has(friend) and game.allies.has(commander), "Named allies must remain on field")
	game.player_hp = 0.0
	game.update_battle(0.01)
	assert(game.player_downed and game.state == "prologue_battle")
	hero["hp"] = 0.0
	game.update_heroes(0.01)
	assert(game.fallen_heroes.size() == 1)
	game.update_battle(0.01)
	assert(game.state == "battle_end")
	game.revive_named_cast()
	assert(not game.player_downed and not friend["downed"] and not commander["downed"])
	game.finish_battle_end()
	assert(game.state == "battle" and game.stage_number == 1)
	assert(game.allies.any(func(a): return a["kind"] == "commander"))
	var initial_count: int = game.allies.size()
	var first_positions: Array[Vector2] = []
	for side in 4:
		game.spawn_clock = 1.16
		game.update_stage1_spawns(0.01)
		first_positions.append(game.allies.back()["pos"])
	assert(game.allies.size() == initial_count + 4)
	assert(first_positions[0].x < game.camera_x + 45.0)
	assert(first_positions[1].x > game.camera_x + 1230.0)
	assert(first_positions[2].y == 145.0 and first_positions[3].y == 590.0)
	game.elapsed = 12.0
	game.spawn_index = 5
	game.spawn_clock = 1.16
	game.update_stage1_spawns(0.01)
	assert(game.allies.back()["kind"] == "skeleton")
	game.elapsed = 25.0
	game.spawn_index = 8
	game.spawn_clock = 1.16
	game.update_stage1_spawns(0.01)
	assert(game.allies.back()["kind"] == "frost")
	game.elapsed = 45.0
	game.spawn_index = 13
	game.spawn_clock = 1.16
	game.update_stage1_spawns(0.01)
	assert(game.allies.back()["kind"] == "brute")
	var stage_hero: Dictionary = game.heroes[0]
	game.give_hero_item(stage_hero, "charm")
	game.give_hero_item(stage_hero, "bomb")
	assert(stage_hero["weapon_levels"]["charm"] == 1 and stage_hero["weapon_levels"]["bomb"] == 1)
	stage_hero["attack_cd"] = 0.0
	stage_hero["charm_cd"] = 0.0
	stage_hero["bomb_cd"] = 0.0
	var target: Dictionary = game.make_ally("goblin", stage_hero["pos"] + Vector2(25, 0), 0, false)
	game.allies.append(target)
	game.update_stage1_hero_weapons(stage_hero, target, 25.0)
	assert(stage_hero["attack_cd"] > 0.0 and stage_hero["charm_cd"] > 0.0 and stage_hero["bomb_cd"] > 0.0)
	assert(target["hp"] < target["max_hp"])
	for i in 4:
		game.pickups.append({"kind": "gem", "pos": stage_hero["pos"], "lane": 0, "value": 1})
	game.update_pickups(0.01)
	assert(stage_hero["level"] == 2 and stage_hero["weapon_levels"]["charm"] == 2)
	game.pickups.append({"kind": "chest", "pos": stage_hero["pos"], "lane": 0})
	game.update_pickups(0.01)
	assert(stage_hero["weapon_levels"]["blade"] == 2, "Chest must upgrade owned weapon")
	game.start_stage(2)
	assert(game.heroes.size() == 2)
	game.start_stage(3)
	assert(game.pending_heroes.size() == 1)
	game.start_stage(4)
	assert(game.command_cap() >= 12)
	game.start_stage(1)
	game.elapsed = game.MAX_TIME - 0.01
	game.update_battle(0.05)
	assert(game.state == "battle_end" and not game.end_victory)
	game.finish_battle_end()
	assert(game.state == "lost")
	game.start_stage(1)
	assert(game.state == "battle" and game.spawn_index == 0, "Retry must reset the wave")
	assert(FileAccess.file_exists("user://save_v3.cfg"))
	game.prologue_done = true
	game.next_stage = 3
	game.save_game()
	var reloaded = load("res://main_v4.gd").new()
	root.add_child(reloaded)
	assert(reloaded.state == "title" and reloaded.next_stage == 3, "Existing save_v3 schema must remain readable")
	print("V4_SMOKE_OK: click shot, downed cast, four-side spawns, unlocks, weapons, later stages")
	reloaded.free()
	game.free()
	quit(0)
