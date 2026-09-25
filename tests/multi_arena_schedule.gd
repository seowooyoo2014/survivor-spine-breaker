extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	assert(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 1600)
	assert(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 900)
	var game = load("res://multi_observer.tscn").instantiate()
	root.add_child(game)
	game.start_operation()
	assert(game.launched.count(true) == 1)
	var first: int = game.launch_times.find(0.0)
	assert(first >= 0 and game.focus == -1)
	var early := 0
	var late := 0
	for start_at in game.launch_times:
		if start_at < 1.0: early += 1
		else:
			assert(start_at >= 30.0 and start_at <= 120.0)
			late += 1
	assert(early == 2 and late == 2)
	var original_times: Array[float] = game.launch_times.duplicate()
	game.operation_elapsed = 0.04
	game.save_game()
	game.set_process(false)
	var resumed = load("res://multi_observer.tscn").instantiate()
	root.add_child(resumed)
	assert(resumed.launched.count(true) == 1)
	assert(absf(resumed.operation_elapsed-0.04) < 0.001)
	for i in 4: assert(absf(resumed.launch_times[i]-original_times[i]) < 0.001)
	resumed.operation_elapsed = 1.0
	resumed._process(0.01)
	assert(resumed.launched.count(true) == 2)
	resumed.operation_elapsed = 120.0
	resumed._process(0.01)
	assert(resumed.launched.count(true) == 4)
	assert(resumed.arenas[first].elapsed > 0.0)
	for i in 4: assert(resumed.arenas[i].elapsed < 1.0)
	print("MULTI_ARENA_SCHEDULE_OK")
	resumed.queue_free()
	game.queue_free()
	quit()
