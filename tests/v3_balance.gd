extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_new_story()
	game.start_prologue_battle()
	for stage in range(0, 5):
		if stage > 0: game.start_stage(stage)
		var result := play(game, stage)
		print("stage=", stage, " result=", result, " elapsed=", snapped(game.elapsed, 0.1), " hero_count=", game.heroes.size(), " hero_hp=", game.heroes[0]["hp"] if not game.heroes.is_empty() else 0, " player_hp=", game.player_hp, " gold=", game.gold)
		assert(result, "Each battle should be winnable by an active player")
	print("V3_BALANCE_OK")
	game.free()
	quit(0)

func play(game: Node2D, stage: int) -> bool:
	for tick in 9000:
		if game.stage_number != stage: return true
		if game.state in ["reward", "promotion", "ending"]: return true
		if game.state == "lost": return false
		if not game.heroes.is_empty():
			var target: Dictionary = game.heroes[0]
			for hero in game.heroes:
				if game.player_pos.distance_to(hero["pos"]) < game.player_pos.distance_to(target["pos"]): target = hero
			game.player_pos = game.player_pos.move_toward(target["pos"] + Vector2(-43, 0), 245.0 * 0.05)
			if tick % 55 == 0: game.dash()
			if stage == 4 and tick % 70 == 0:
				game.summon_squad()
		game.update_battle(0.05)
	return false
