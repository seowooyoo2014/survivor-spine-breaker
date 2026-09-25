extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var g = load("res://observer.tscn").instantiate()
	root.add_child(g)
	g.meta = g.default_meta()
	g.fresh_run()
	g.state = "observe"
	g.mana = 12.0
	g.hero["hp"] = 100.0
	g.hero["shield"] = 1
	assert(g.damage_hero(200.0) == 0.0 and g.demon_xp == 0.0)
	assert(g.damage_hero(200.0) == 100.0)
	assert(g.demon_level == 2 and g.demon_xp == 0.0)
	assert(g.mana_max == 105.0 and g.mana == 17.0)
	assert(g.damage_hero(50.0) == 0.0 and g.demon_level == 2)
	g.hero["hp"] = g.hero["max_hp"]
	var old: Dictionary = g.make_monster("zombie",Vector2(80,200))
	var old_hp: float = old["max_hp"]
	var old_damage: float = old["damage"]
	g.hero_level_up()
	var newer: Dictionary = g.make_monster("zombie",Vector2(90,200))
	assert(old["level"] == 1 and newer["level"] == 2)
	assert(old["max_hp"] == old_hp and old["damage"] == old_damage)
	assert(newer["max_hp"] > old_hp and newer["damage"] > old_damage)
	g.monsters.clear()
	g.traps.clear()
	g.hero["motion"] = Vector2.RIGHT
	g.hero["pos"] = Vector2(400,350)
	g.elapsed = 180.0
	g.next_trap_at = 180.0
	g.update_traps(0.01)
	assert(g.traps.size() == 1 and g.next_trap_at == 360.0)
	var trap_pos: Vector2 = g.traps[0]["pos"]
	g.hero["pos"] = trap_pos
	g.update_traps(0.01)
	assert(g.traps.is_empty() and g.hero["slow_time"] > 0.0)
	assert(g.monsters.size() == 4 and g.monsters.all(func(m): return m["type"] == "trap_elite" and m["level"] == 2))
	g.monsters.clear()
	g.traps.append({"pos":Vector2(100,100),"ttl":1.0})
	g.update_traps(1.1)
	assert(g.traps.is_empty())
	g.hero["hp"] = g.hero["max_hp"]
	g.hero["level"] = 20
	var grades: Array[String] = []
	for seed in 35:
		g.rng.seed = seed
		g.start_boss("mini")
		var grade: String = g.boss["grade"]
		if not grades.has(grade): grades.append(grade)
		var factor: float = g.boss["grade_factor"]
		assert(is_equal_approx(g.boss["max_hp"],1200.0*g.monster_hp_multiplier(20)*factor))
		assert(g.boss["level"] == 20 and g.boss["damage_mult"] > 0.0)
	assert(grades.size() == 3, "All three mini-boss grades must be reachable")
	g.traps.append({"pos":Vector2(300,300),"ttl":12.5})
	g.next_trap_at = 540.0
	g.save_run()
	var loaded = load("res://observer_v1.gd").new()
	root.add_child(loaded)
	loaded.load_run()
	assert(loaded.demon_level == 2 and loaded.boss["grade"] == g.boss["grade"])
	assert(loaded.traps.size() == 1 and loaded.traps[0]["ttl"] == 12.5 and loaded.next_trap_at == 540.0)
	var c := ConfigFile.new()
	assert(c.load(g.SAVE_PATH) == OK)
	for key in ["demon_level","demon_xp","traps","next_trap_at"]: c.erase_section_key("run",key)
	assert(c.save(g.SAVE_PATH) == OK)
	loaded.load_run()
	assert(loaded.demon_level == 1 and loaded.demon_xp == 0.0 and loaded.traps.is_empty())
	assert(loaded.next_trap_at > loaded.elapsed)
	print("OBSERVER_GROWTH_TRAP_OK: actual damage XP, future spawn levels, trap, grades, save compatibility")
	loaded.free()
	g.free()
	quit(0)
