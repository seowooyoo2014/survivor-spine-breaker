extends SceneTree
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var outcomes: Array[String] = []
	for seed in [11,83]:
		var g = load("res://observer.tscn").instantiate()
		root.add_child(g)
		g.fresh_run()
		g.rng.seed = seed
		g.state = "observe"
		var reserve_mark := -1
		for tick in 40000:
			if g.state == "unlock": g.choose_unlock(0)
			elif g.state == "chest": g.open_chest()
			elif g.state == "chest_result": g.finish_event()
			elif g.state == "victory" or g.state == "defeat" or g.state == "final": break
			else:
				if g.state == "observe" and int(g.elapsed)/8 > reserve_mark:
					reserve_mark = int(g.elapsed)/8
					g.reserve_squad("zombie")
				g.update_simulation(0.05)
		outcomes.append(g.state)
		print("SEED ",seed," result=",g.state," time=",snapped(g.elapsed,1)," hero_hp=",int(g.hero["hp"])," hero_lv=",g.hero["level"]," demon_lv=",g.demon_level)
		assert(g.state == "victory" or g.state == "final", "A run must end or reach the showdown")
		g.free()
	print("SEED_BALANCE_OK: ",outcomes)
	quit(0)
