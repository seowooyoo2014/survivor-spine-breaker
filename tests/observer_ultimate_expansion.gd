extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var g = load("res://observer.tscn").instantiate()
	root.add_child(g)
	g.meta = g.default_meta()
	g.fresh_run()
	assert(g.TYPES.size()-1 == 50)
	assert(g.obstacles.size() == 13)
	assert(not g.blocked_at(g.hero["pos"],20.0))
	var tree: Dictionary = g.obstacles[0]
	assert(not g.clear_line(tree["pos"]+Vector2(-70,0),tree["pos"]+Vector2(70,0)))
	assert(g.move_clear(tree["pos"]+Vector2(-50,0),Vector2(35,0),8.0).distance_to(tree["pos"]) >= float(tree["radius"])+8.0)
	for index in g.WEAPONS.size():
		var weapon: String = g.WEAPONS[index]
		var items: Dictionary = g.hero["items"]
		g.hero[weapon] = 5
		items[g.ITEMS[index]] = 1
		g.hero["items"] = items
		g.queue_ready_evolutions()
		assert(g.pending_evolutions.has(weapon) and not g.evolved.has(weapon))
		g.hero_level_up()
		assert(g.evolved.has(weapon))
	assert(g.evolved.size() == 6 and g.counter_due.size() == 6)
	g.state = "observe"
	g.elapsed = 121.0
	g.check_events()
	assert(g.state == "chest" and g.current_event["kind"] == "counter_chest")
	g.open_chest()
	assert(g.state == "chest_result" and g.counter_opened.size() == 1)
	var counter_id: String = g.current_event["reward"]
	assert(g.COUNTERS.has(counter_id) and g.unlocked.has(counter_id))
	g.open_chest()
	assert(g.counter_opened.size() == 1)
	g.finish_event()
	g.events.clear()
	g.start_boss("final")
	g.mana = 100.0
	assert(g.reserve_squad(counter_id))
	var late_weapon := "blade" if not g.counter_opened.has("blade") else "orb"
	g.counter_due.append({"weapon":late_weapon,"at":g.elapsed+0.1})
	g.elapsed += 0.2
	g.check_events()
	assert(g.state == "chest" and g.return_state == "final")
	g.open_chest()
	g.finish_event()
	assert(g.state == "final" and g.counter_opened.has(late_weapon))
	g.save_run()
	var loaded = load("res://observer_v1.gd").new()
	root.add_child(loaded)
	loaded.load_meta()
	loaded.load_run()
	assert(loaded.obstacles.size() == 13)
	assert(loaded.evolved.size() == 6 and loaded.counter_opened.size() == 2)
	assert(loaded.reserves.has(counter_id))
	var old_save := ConfigFile.new()
	assert(old_save.load(g.SAVE_PATH) == OK)
	var old_hero: Dictionary = old_save.get_value("run","hero",{})
	var old_blade: int = old_hero["blade"]
	for key in ["lightning","fire","arrow","items","lightning_cd","fire_cd","arrow_cd"]: old_hero.erase(key)
	old_save.set_value("run","hero",old_hero)
	for key in ["obstacles","pending_evolutions","evolved","counter_due","counter_opened","return_state"]: old_save.erase_section_key("run",key)
	assert(old_save.save(g.SAVE_PATH) == OK)
	loaded.load_run()
	assert(loaded.hero["blade"] == old_blade and loaded.hero["lightning"] == 0)
	assert(loaded.obstacles.size() == 13 and loaded.evolved.is_empty())
	loaded.free()
	g.free()
	print("OBSERVER_ULTIMATE_EXPANSION_OK")
	quit(0)
