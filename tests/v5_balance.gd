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
		print("stage=", stage, " result=", result, " elapsed=", snapped(game.elapsed, 0.1), " hp=", game.player_hp, " hero_count=", game.heroes.size())
		assert(result, "Active player must be able to finish the battle")
		if game.state == "battle_end": game.finish_battle_end()
	print("V5_BALANCE_OK")
	game.free()
	quit(0)

func play(game: Node2D, stage: int) -> bool:
	var highest_level := 1
	var saw_charm := false
	var saw_bomb := false
	var saw_frost := false
	for tick in 7200:
		if game.state in ["battle_end", "promotion", "ending"]:
			if stage == 1:
				print("stage1_growth level=", highest_level, " charm=", saw_charm, " bomb=", saw_bomb, " frost=", saw_frost)
				assert(highest_level >= 3 and saw_charm and saw_bomb and saw_frost, "Hero growth and late troop unlock must occur in stage 1")
			return true
		if game.state == "lost": return false
		if stage == 1:
			for hero in game.heroes:
				highest_level = maxi(highest_level, hero["level"])
				saw_charm = saw_charm or hero["charm"]
				saw_bomb = saw_bomb or hero["bomb"]
			for ally in game.allies:
				saw_frost = saw_frost or ally["kind"] == "frost"
		if not game.heroes.is_empty() and not game.player_downed:
			var target: Dictionary = game.heroes[0]
			for hero in game.heroes:
				if game.player_pos.distance_to(hero["pos"]) < game.player_pos.distance_to(target["pos"]): target = hero
			game.player_pos = game.player_pos.move_toward(target["pos"] + Vector2(-125, 0), 245.0 * 0.05)
			if tick % 6 == 0: game.fire_slime(target["pos"] - Vector2(game.camera_x, 0))
			if tick % 55 == 0: game.dash()
			if stage == 4 and tick % 70 == 0: game.summon_squad()
		game.update_battle(0.05)
	return false
