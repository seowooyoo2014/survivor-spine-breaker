extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var g = load("res://observer.tscn").instantiate()
	root.add_child(g)
	g.meta = g.default_meta()
	assert(g.TYPES.size()-1 == 50)
	assert(g.meta["codex"].size() == 5)
	g.fresh_run()
	assert(g.hero["max_hp"] == 700.0)
	assert(g.buy_upgrade(0) == false)
	g.meta["demon_currency"] = 100
	assert(g.buy_upgrade(0))
	assert(g.meta["demon_mana"] == 1 and g.meta["demon_currency"] == 80)
	g.fresh_run()
	assert(g.mana_max == 108.0)
	g.state = "observe"
	g.elapsed = 100.0
	g.total_damage = 700.0
	g.hero["hp"] = 0.0
	g.end_run(true,"test")
	var currency: int = g.meta["demon_currency"]
	assert(currency > 80)
	g.award_meta()
	assert(g.meta["demon_currency"] == currency, "Result reward must be idempotent")
	g.meta = g.default_meta()
	g.fresh_run()
	g.elapsed = 1800.0
	g.total_damage = 700.0
	g.hero["hp"] = 10.0
	g.end_run(false,"test")
	assert(int(g.meta["demon_currency"]) < currency-80, "30-minute payout must be lower than an early kill")
	g.meta = g.default_meta()
	g.fresh_run()
	g.meta["total_damage"] = 7000.0
	g.refresh_codex()
	assert(g.meta["codex"].size() >= 15, "Damage achievements should unlock catalogue tiers")
	g.meta = g.default_meta()
	g.fresh_run()
	g.state = "observe"
	g.elapsed = 180.0
	g.automatic_clock = 7.5
	g.bat_clock = 0.0
	g.update_simulation(0.01)
	assert(g.monsters.any(func(m): return m["type"] in ["rat","crawler"]))
	g.current_event = {"kind":"unlock","id":"time_300","picks":1}
	g.build_unlock_options()
	assert(g.current_options.all(func(id): return id == "mana_refill" or g.meta["codex"].has(id)))
	g.meta["total_seconds"] = 140.0*60.0
	g.refresh_codex()
	assert(g.meta["codex"].size() == 30)
	g.meta["hero_hp"] = 6
	g.meta["hero_armor"] = 6
	g.meta["hero_weapon"] = 6
	g.save_meta()
	g.fresh_run()
	assert(g.hero["max_hp"] == 2500.0)
	assert(g.hero["blade"] == 4)
	assert(g.hero["armor_meta"] == 6)
	g.save_run()
	var loaded = load("res://observer_v1.gd").new()
	root.add_child(loaded)
	loaded.load_meta()
	loaded.load_run()
	assert(loaded.hero["max_hp"] == 2500.0)
	assert(loaded.meta["codex"].size() == 30)
	var old_save := ConfigFile.new()
	assert(old_save.load(g.SAVE_PATH) == OK)
	for key in ["run_id","total_damage","payout_done","automatic_clock"]:
		old_save.erase_section_key("run",key)
	assert(old_save.save(g.SAVE_PATH) == OK)
	loaded.load_run()
	assert(loaded.run_id.begins_with("legacy_") and loaded.total_damage == 0.0)
	loaded.free()
	g.free()
	print("OBSERVER_META_GROWTH_OK")
	quit(0)
