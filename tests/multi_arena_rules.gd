extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var game = load("res://multi_observer.tscn").instantiate()
	root.add_child(game)
	game.start_operation()
	assert(game.launched.count(true) == 1)
	var first: int = game.launch_times.find(0.0)
	assert(first >= 0)
	var immediate := 0
	var delayed := 0
	for start_at in game.launch_times:
		if start_at < 1.0: immediate += 1
		else:
			assert(start_at >= 30.0 and start_at <= 120.0)
			delayed += 1
	assert(immediate == 2 and delayed == 2)
	game.arenas[first].update_simulation(1.0)
	game.operation_elapsed = 1.0
	game._process(0.01)
	assert(game.launched.count(true) == 2)
	var second := -1
	for i in 4:
		if i != first and game.launched[i]: second = i
	assert(second >= 0)
	assert(game.arenas[first].elapsed > game.arenas[second].elapsed)
	game.operation_elapsed = 120.0
	game._process(0.01)
	assert(game.launched.count(true) == 4)
	for i in 4:
		assert(game.arenas[i].terrain_connected())
		assert(game.arenas[i].obstacles.size() >= 9)
	game.focus = first
	var before_mana: float = game.mana
	assert(game.reserve("zombie"))
	assert(game.reserves.back()["arena"] == game.focus)
	assert(game.mana < before_mana)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(700,30)
	game._unhandled_input(click)
	assert(game.focus == 1)
	var switch_key := InputEventKey.new()
	switch_key.keycode = KEY_F4
	switch_key.pressed = true
	game._unhandled_input(switch_key)
	assert(game.focus == 3)
	game.current_event = {"kind":"chest","arena":0,"id":"odds"}
	var normal := 0
	var rare := 0
	var legend := 0
	for i in 900:
		game.begin_roulette()
		match game.roulette["tier"]:
			"normal": normal += 1
			"rare": rare += 1
			"legendary": legend += 1
	assert(normal > 300 and normal < 500)
	assert(rare > 300 and rare < 500)
	assert(legend > 50 and legend < 150)
	game.pity_normals = 2
	for i in 50:
		game.begin_roulette()
		assert(game.roulette["tier"] != "normal")
		game.pity_normals = 2
	game.current_event = {"kind":"counter","arena":0,"weapon":"blade","id":"counter"}
	game.pity_normals = 2
	game.begin_roulette()
	assert(game.pity_normals == 2)
	assert(game.roulette["reward"] == "counter_blade")
	for i in 4:
		game.arenas[i].elapsed = 1800.0
		game.arenas[i].state = "observe"
		game.arenas[i].start_boss("final")
	game.focus = 0
	game.arenas[0].manual_control = true
	for i in range(1,4): game.arenas[i].manual_control = false
	var old: Vector2 = game.arenas[1].boss["pos"]
	game.arenas[1].update_boss(0.5)
	assert(game.arenas[1].boss["pos"] != old)
	game.set_process(false)
	game.save_game()
	var saved = load("res://multi_observer.tscn").instantiate()
	root.add_child(saved)
	assert(saved.arenas[1].state == "final")
	assert(saved.arenas[1].boss["pos"].distance_to(game.arenas[1].boss["pos"]) < 0.01)
	for i in 4: assert(absf(saved.launch_times[i]-game.launch_times[i]) < 0.001)
	print("MULTI_ARENA_RULES_OK")
	saved.queue_free()
	game.queue_free()
	quit()
