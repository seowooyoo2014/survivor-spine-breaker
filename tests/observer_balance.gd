extends SceneTree
func _initialize() -> void:
	call_deferred("run_check")
func run_check() -> void:
	var g = load("res://observer.tscn").instantiate()
	root.add_child(g)
	g.fresh_run()
	g.state = "observe"
	var report_mark := 0
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
		if int(g.elapsed)/300 > report_mark:
			report_mark = int(g.elapsed)/300
			print("time=",snapped(g.elapsed,1)," hp=",int(g.hero["hp"])," level=",g.hero["level"]," mobs=",g.monsters.size()," state=",g.state)
	print("END state=",g.state," time=",snapped(g.elapsed,1)," hero_hp=",int(g.hero["hp"])," level=",g.hero["level"])
	g.free()
	quit(0)
