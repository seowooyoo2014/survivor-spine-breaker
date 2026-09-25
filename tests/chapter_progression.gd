extends SceneTree

# Run against an isolated copy of the project so user:// saves stay untouched.
func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var scene: PackedScene = load("res://multi_observer.tscn")
	var game = scene.instantiate()
	root.add_child(game)
	await process_frame
	assert(game.history_prologue != null)
	game.history_prologue.finish_intro()
	if game.screen_mode == "tutorial": game.close_tutorial()
	assert(game.screen_mode == "chapter_select")
	game.selected_chapter = 1
	game.start_operation()
	assert(game.launched.count(true) == 1)
	assert(game.monster_level == 1)
	game.gain_shared_xp(game.monster_xp_goal()+1.0)
	assert(game.monster_level == 2 and game.events.size() == 1)
	game.advance_event(0.0)
	assert(not game.roulette.is_empty())
	game.finish_roulette()
	game.finish_roulette()
	assert(game.awarded.size() == 1)
	game.close_reward()
	game.save_game()
	game.queue_free()
	await process_frame
	var resumed = scene.instantiate()
	root.add_child(resumed)
	await process_frame
	resumed.history_prologue.finish_intro()
	if resumed.screen_mode == "tutorial": resumed.close_tutorial()
	resumed.load_game()
	assert(resumed.monster_level == 2 and resumed.awarded.size() == 1)
	for chapter in range(1,11):
		resumed.selected_chapter = chapter
		resumed.start_operation()
		var scheduled := 0
		for time in resumed.launch_times:
			if time < 100000000.0: scheduled += 1
		assert(scheduled == resumed.CHAPTER_COUNTS[chapter-1])
		await process_frame
	resumed.selected_chapter = 1
	resumed.start_operation()
	var arena = resumed.arenas[resumed.first_active_index()]
	resumed.monster_level = 4
	arena.monster_level = 4
	assert(arena.make_monster("bat",Vector2(220,230))["level"] == 4)
	arena.state = "victory"
	resumed.finish_operation()
	assert(resumed.chapter_success and int(resumed.meta["unlocked_chapter"]) >= 2)
	var currency: int = int(resumed.meta["demon_currency"])
	resumed.finish_operation()
	assert(int(resumed.meta["demon_currency"]) == currency)
	print("CHAPTER_PROGRESSION_OK")
	quit()
