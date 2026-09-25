extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var g = load("res://observer.tscn").instantiate()
	root.add_child(g)
	g.fresh_run()
	assert(g.state == "opening" and g.hero["hp"] > 0.0)
	g.state = "observe"
	g.update_simulation(1.2)
	assert(g.monsters.size() >= 1 and g.monsters[0]["type"] == "bat")
	var mana: float = g.mana
	assert(g.reserve_squad("zombie"))
	assert(g.reserves.size() == 1 and g.mana < mana)
	g.update_simulation(2.5)
	assert(g.reserves.is_empty() and g.monsters.any(func(m): return m["type"] == "zombie"))
	g.elapsed = 300.0
	g.check_events()
	assert(g.state == "unlock" and g.time_marks.has(300))
	var frozen: float = g.elapsed
	g._process(0.05)
	assert(g.elapsed == frozen)
	var first: String = g.current_options[0]
	g.choose_unlock(0)
	assert(g.unlocked.has(first) and g.state == "observe")
	g.check_events()
	assert(g.state == "observe" and g.time_marks.count(300) == 1)
	g.hero["hp"] = g.hero["max_hp"]*0.74
	g.check_events()
	assert(g.hp_marks.has(75) and g.state == "unlock")
	g.choose_unlock(0)
	assert(g.state == "unlock" and g.chosen_count == 1)
	g.choose_unlock(0)
	assert(g.state == "chest")
	g.open_chest()
	assert(g.state == "chest_result" and g.chest_marks.has("hp_75") and g.reward_ids.size() == 1)
	var reward: String = g.last_result
	g.open_chest()
	assert(g.last_result == reward and g.reward_ids.size() == 1)
	g.finish_event()
	if g.state == "mini":
		g.update_boss(60.1)
	assert(g.state == "observe")
	g.start_boss("mini")
	assert(g.state == "mini")
	g.update_boss(60.1)
	assert(g.state == "observe" and g.boss.is_empty())
	g.events.clear()
	g.time_marks.assign([300,600,900,1200,1500])
	g.hp_marks.assign([75,50,25])
	g.hero["hp"] = g.hero["max_hp"]
	g.monsters.clear()
	g.elapsed = 1799.99
	g.update_simulation(0.05)
	assert(g.state == "final" and g.boss["hp"] > 0.0)
	g.save_run()
	var loaded = load("res://observer_v1.gd").new()
	root.add_child(loaded)
	loaded.load_run()
	assert(loaded.state == "final" and loaded.time_marks.has(300) and loaded.hp_marks.has(75))
	assert(loaded.reward_ids.size() == 1 and loaded.boss["hp"] > 0.0)
	loaded.hero["hp"] = 0.0
	loaded.update_simulation(0.01)
	assert(loaded.state == "victory")
	loaded.fresh_run()
	loaded.current_event = {"kind":"chest","id":"forced_mini","picks":1}
	loaded.state = "chest"
	var chosen_seed := -1
	for seed in 1000:
		loaded.rng.seed = seed
		if loaded.rng.randi_range(0,5) == 5:
			chosen_seed = seed
			break
	assert(chosen_seed >= 0)
	loaded.rng.seed = chosen_seed
	loaded.open_chest()
	assert(loaded.current_event["reward"] == "mini_token" and loaded.reward_ids.size() == 1)
	loaded.finish_event()
	assert(loaded.state == "mini" and loaded.boss_time == 0.0)
	loaded.events.clear()
	loaded.time_marks.assign([300,600,900,1200,1500])
	loaded.hp_marks.assign([75,50,25])
	loaded.hero["hp"] = loaded.hero["max_hp"]
	loaded.monsters.clear()
	loaded.elapsed = loaded.BATTLE_TIME-0.01
	loaded.update_simulation(0.05)
	assert(loaded.state == "final", "Final demon should replace a still-active mini boss at 30 minutes")
	loaded.fresh_run()
	loaded.state = "observe"
	loaded.start_boss("final")
	loaded.boss["hp"] = 0.0
	loaded.update_simulation(0.01)
	assert(loaded.state == "defeat")
	print("OBSERVER_SMOKE_OK")
	loaded.free()
	g.free()
	quit(0)
