extends SceneTree
func _initialize() -> void: call_deferred("run_checks")
func simulate(seed: int, starting_hp: float) -> Dictionary:
	var g = load("res://observer.tscn").instantiate()
	root.add_child(g)
	g.meta = g.default_meta()
	g.fresh_run()
	g.state = "observe"
	g.elapsed = 600.0
	g.time_marks.assign([300,600])
	g.hp_marks.assign([75,50,25])
	g.next_trap_at = 900.0
	g.hero["level"] = 30
	g.hero["max_hp"] = 3800.0
	g.hero["hp"] = starting_hp
	g.hero["blade"] = 4
	g.hero["orb"] = 3
	g.hero["bomb"] = 2
	g.hero["shield"] = 0
	g.rng.seed = seed
	g.start_boss("mini")
	var grade: String = g.boss["grade"]
	for tick in 1200:
		if g.state != "mini": break
		g.boss["pos"] = g.boss["pos"].move_toward(g.hero["pos"],205.0*0.05)
		g.boss_attack()
		g.boss_special()
		g.update_simulation(0.05)
	var result := {"grade":grade,"state":g.state,"hero_hp":g.hero["hp"]}
	g.free()
	return result
func run_checks() -> void:
	var close: Dictionary = simulate(9,900.0)
	var lethal: Dictionary = simulate(5,900.0)
	var easy: Dictionary = simulate(9,2000.0)
	assert(close["grade"] == "약함" and close["state"] == "observe" and close["hero_hp"] > 0.0 and close["hero_hp"] < 300.0)
	assert(lethal["grade"] == "강함" and lethal["state"] == "victory")
	assert(easy["grade"] == "약함" and easy["state"] == "observe" and easy["hero_hp"] > 1000.0)
	print("OBSERVER_MINIBOSS_BALANCE_OK: close survival, hero death, easy survival")
	quit(0)
