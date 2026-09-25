extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var game = load("res://multi_observer.tscn").instantiate()
	root.add_child(game)
	game.start_operation()
	assert(game.launched.count(true) == 1)
	game.operation_elapsed = 120.0
	game._process(0.01)
	assert(game.active_count() == 4)
	assert(game.arenas[0].terrain_seed != game.arenas[1].terrain_seed)
	for i in 4:
		assert(game.arenas[i].obstacles.size() >= 9)
		assert(game.arenas[i].state == "observe")
	game.gain_shared_xp(250.0)
	assert(game.demon_level >= 2)
	assert(game.mana_max >= 105.0)
	game.current_event = {"kind":"chest","arena":1,"id":"test"}
	game.begin_roulette()
	var reward = game.roulette["reward"]
	game.save_game()
	var other = load("res://multi_observer.tscn").instantiate()
	root.add_child(other)
	assert(other.roulette["reward"] == reward)
	assert(other.active_count() == 4)
	for i in 4: assert(absf(other.launch_times[i]-game.launch_times[i]) < 0.001)
	other.finish_roulette()
	var count = other.awarded.size()
	other.finish_roulette()
	assert(other.awarded.size() == count)
	print("MULTI_ARENA_OK")
	other.queue_free()
	game.queue_free()
	quit()
