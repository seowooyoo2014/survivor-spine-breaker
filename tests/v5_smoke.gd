extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_new_story()
	game.start_stage(1)
	assert(game.allies.any(func(a): return a["kind"] == "commander"))
	var batz: Dictionary = game.allies.filter(func(a): return a["kind"] == "commander")[0]
	var old_hp: float = batz["hp"]
	game.damage_ally(batz, 100.0)
	assert(batz["hp"] == old_hp - 45.0)
	var hero: Dictionary = game.heroes[0]
	game.allies.clear()
	game.player_pos = hero["pos"]
	hero["contact_cd"] = 0.0
	old_hp = hero["hp"]
	game.apply_hero_contact(hero, 0.01)
	assert(hero["hp"] < old_hp)
	old_hp = hero["hp"]
	game.apply_hero_contact(hero, 0.01)
	assert(hero["hp"] == old_hp)
	game.player_downed = true
	hero["contact_cd"] = 0.0
	game.apply_hero_contact(hero, 0.01)
	assert(hero["hp"] == old_hp, "Downed Akuma cannot contact damage")
	game.player_downed = false
	var start_pos: Vector2 = hero["pos"]
	game.update_heroes(0.05)
	assert(hero["pos"].distance_to(start_pos) > 0.1, "Hero must keep moving")
	game.begin_battle_end(true, "victory")
	game.finish_battle_end()
	assert(game.state == "return_cutscene" and game.save_location == "camp")
	game.update_return_cutscene(3.1)
	assert(game.state == "camp_event" and game.camp_stage == 1)
	for i in game.camp_event_lines.size(): game.advance_camp_event()
	assert(game.state == "camp")
	game.camp_pos = Vector2(1010, 452)
	game.interact_camp()
	assert(game.guild_guard_seen and game.state == "camp_guard")
	for i in 3:
		game.guard_index += 1
		if game.guard_index >= 3: game.state = "camp"
	assert(game.state == "camp")
	assert(game.shop_offers().all(func(o): return o["id"] != "frost" and o["id"] != "captain"))
	game.camp_pos = Vector2(700, 450)
	game.open_camp_chest()
	assert(game.state == "camp_reward" and game.opened_chest_stages.has(1))
	var reward: String = game.camp_chest_result
	var previous_gold: int = game.gold
	game.open_camp_chest()
	assert(game.camp_chest_result == reward and game.gold == previous_gold)
	game.state = "camp"
	game.camp_pos = Vector2(1185, 445)
	game.interact_camp()
	assert(game.state == "stage2_briefing")
	game.briefing_index = 2
	game.start_stage(2)
	assert(game.heroes.size() == 2 and game.allies.any(func(a): return a["kind"] == "commander"))
	game.elapsed = game.MAX_TIME - 0.01
	game.update_battle(0.05)
	assert(game.state == "battle_end" and not game.end_victory)
	game.finish_battle_end()
	assert(game.state == "lost")
	game.start_stage(2)
	game.begin_battle_end(true, "victory")
	game.finish_battle_end()
	game.update_return_cutscene(3.1)
	assert(game.camp_stage == 2 and game.save_location == "camp")
	game.prepare_camp_after_stage(3)
	game.enter_camp(true)
	assert(game.camp_stage == 3)
	game.gold = 300
	game.buy_guild_contract(0)
	assert(game.frost_hired and game.gold == 230)
	game.start_stage(4)
	assert(game.command_cap() >= 12 and not game.captain_hired)
	game.save_location = "camp"
	game.camp_stage = 3
	game.save_game()
	var reloaded = load("res://main_v5.gd").new()
	root.add_child(reloaded)
	assert(reloaded.state == "title" and reloaded.save_location == "camp" and reloaded.frost_hired)
	assert(reloaded.opened_chest_stages.has(1))
	var old_save := ConfigFile.new()
	old_save.set_value("story", "prologue_done", true)
	old_save.set_value("story", "next_stage", 2)
	old_save.set_value("progress", "gold", 47)
	assert(old_save.save("user://save_v3.cfg") == OK)
	reloaded.load_save()
	assert(reloaded.next_stage == 2 and reloaded.gold == 47 and reloaded.save_location == "battle")
	print("V5_SMOKE_OK: return, camp, guard, chest, briefing, hero contact, guild, save")
	reloaded.free()
	game.free()
	quit(0)
