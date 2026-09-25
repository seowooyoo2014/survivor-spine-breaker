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
	var frozen_pos: Vector2 = game.player_pos
	game._process(0.5)
	assert(game.player_pos == frozen_pos)
	game.advance_card()
	assert(game.card_kind == "friend")
	game.advance_card()
	for tick in 150:
		game.update_intro(0.05)
		if game.intro_phase == 3: break
	assert(game.intro_phase == 3 and game.camera_x > 0.0)
	game.update_intro(3.4)
	assert(game.state == "card" and game.card_kind == "commander")
	game.advance_card()
	for tick in 400:
		game.update_intro(0.05)
		if game.state == "tutorial": break
	assert(game.state == "tutorial")
	game.start_prologue_battle()
	assert(game.command_cap() == 0)
	assert(game.cores.is_empty())
	var hero: Dictionary = game.heroes[0]
	var fallen: Dictionary = game.make_ally("brute", hero["pos"] + Vector2(12, 0), 0, false)
	fallen["hp"] = 0.0
	game.allies.clear()
	game.allies.append(fallen)
	game.update_allies(0.05)
	assert(game.pickups.size() == 2, "Elite death should drop a gem and chest")
	hero["pos"] = game.pickups[1]["pos"]
	game.update_pickups(0.05)
	assert(hero["charm"], "Hero should receive an item from the chest")
	for i in 4:
		game.pickups.append({"kind":"gem", "pos":hero["pos"], "lane":0, "value":1})
	game.update_pickups(0.05)
	assert(hero["level"] >= 2, "Hero must level from collected gems")
	game.give_hero_item(hero, "bomb")
	assert(hero["bomb"])
	game.give_hero_item(hero, "shield")
	var hp_before: float = hero["hp"]
	game.damage_hero(hero, 30.0)
	assert(hero["shield"] == 0 and hero["hp"] == hp_before)
	game.elapsed = game.MAX_TIME - 0.01
	game.update_battle(0.05)
	assert(game.state == "lost", "Surviving hero wins at 30 minutes")
	for stage in range(1, 4):
		game.start_stage(stage)
		assert(game.command_cap() == 0, "Stages 1–3 must remain subordinate")
		assert(game.cores.is_empty(), "No core objective")
		game.summon_squad()
		assert(game.controlled_count() == 0)
	assert(game.heroes.size() == 2 and game.pending_heroes.size() == 1)
	for enemy in game.heroes: enemy["hp"] = 0.0
	game.pending_heroes.clear()
	game.update_battle(0.05)
	assert(game.state == "promotion", "Promotion follows stage 3")
	game.start_stage(4)
	assert(game.command_cap() >= 12)
	game.select_squad(1)
	assert(game.equipped_squad == "frost")
	game.summon_squad()
	assert(game.controlled_count() == 2)
	assert(FileAccess.file_exists("user://save_v3.cfg"))
	print("V3_SMOKE_OK: loot, levels, survival, subordinate stages, promotion, command selection")
	game.free()
	quit(0)
