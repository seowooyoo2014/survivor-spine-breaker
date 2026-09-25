extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var game = load("res://multi_observer.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	assert(game.operation_started)
	assert(game.active_indices().size() == 1)
	var first: int = game.active_indices()[0]
	assert(game.arena_rect(first).size == Vector2(1200,900))
	var waiting: Array[int] = []
	for i in 4:
		if not game.launched[i]: waiting.append(i)
	game.launch_arena(waiting[0])
	for i in game.active_indices(): assert(game.arena_rect(i).size == Vector2(600,900))
	game.launch_arena(waiting[1])
	assert(game.arena_rect(game.active_indices()[0]).size == Vector2(600,900))
	for i in game.active_indices().slice(1): assert(game.arena_rect(i).size == Vector2(600,450))
	game.launch_arena(waiting[2])
	var indices: Array[int] = game.active_indices()
	assert(indices.size() == 4)
	for i in 4:
		assert(game.arena_rect(i).size == Vector2(600,450))
		assert(game.arenas[i].hero_class == i)
		assert(game.arenas[i].hero["class"] == i)
		assert(game.arenas[i].terrain_connected())
	var kinds := []
	for i in 4:
		var kind: String = game.arenas[i].obstacles[0]["kind"]
		kinds.append(kind)
	assert(kinds[0] != kinds[1] and kinds[1] != kinds[2] and kinds[2] != kinds[3])
	var counts := {1:0,3:0,5:0}
	game.rng.seed = 12345
	for n in 10000: counts[game.roll_reward_count()] += 1
	assert(counts[1] > 6800 and counts[1] < 7600)
	assert(counts[3] > 1900 and counts[3] < 2700)
	assert(counts[5] > 300 and counts[5] < 700)
	var hero_counts := {1:0,3:0,5:0}
	game.arenas[first].rng.seed = 54321
	for n in 10000: hero_counts[game.arenas[first].roll_hero_chest_count()] += 1
	assert(hero_counts[1] > 6800 and hero_counts[1] < 7600)
	assert(hero_counts[3] > 1900 and hero_counts[3] < 2700)
	assert(hero_counts[5] > 300 and hero_counts[5] < 700)
	game.current_event = {"kind":"unlock","arena":first,"picks":1}
	game.options.clear()
	game.options.append("skeleton")
	var before: float = game.arenas[first].elapsed
	game._process(0.05)
	assert(game.arenas[first].elapsed > before)
	game.current_event.clear()
	game.arenas[first].counter_due.append({"weapon":"orb","at":game.arenas[first].elapsed})
	game.collect_counter_due(first)
	assert(game.unlocked.has("mirror_eye"))
	assert(game.arenas[first].counter_opened.has("orb"))
	assert(game.arenas[first].monsters.any(func(m): return m["type"] == "mirror_eye"))
	var archer = arena_for_test(game,first)
	var old_hp: float = archer.hero["hp"]
	archer.monsters.clear()
	archer.monster_shots.clear()
	archer.obstacles.clear()
	archer.monsters.append(archer.make_monster("archer",archer.hero["pos"]+Vector2(0,-75)))
	archer.monsters[0]["attack_cd"] = 0.0
	archer.update_monsters(0.01)
	assert(archer.monster_shots.size() == 1 and archer.hero["hp"] == old_hp)
	archer.obstacles.append({"kind":"rock","pos":archer.monster_shots[0]["pos"]+Vector2(0,10),"radius":7.0})
	archer.update_monster_shots(0.05)
	assert(archer.monster_shots.is_empty())
	game.current_event = {"kind":"chest","arena":first,"id":"test"}
	game.begin_roulette()
	assert(game.roulette["rewards"].size() in [1,3,5])
	var serial: int = game.roulette["serial"]
	game.finish_roulette()
	var awards: int = game.awarded.size()
	game.finish_roulette()
	assert(game.awarded.size() == awards and game.awarded.has("%s_%d" % [game.run_id,serial]))
	var arena = game.arenas[first]
	arena.hero_chests.append({"pos":arena.hero["pos"]})
	var old_level: int = arena.hero["level"]
	arena.update_drops(0.05)
	assert(int(arena.hero_chest_show["count"]) in [1,3,5])
	assert(arena.hero["level"] == old_level)
	var pending = load("res://multi_observer.tscn").instantiate()
	root.add_child(pending)
	pending.set_process(false)
	game.save_game()
	pending.load_game()
	assert(pending.arenas[first].hero_chest_show["ids"] == arena.hero_chest_show["ids"])
	pending.queue_free()
	arena.update_drops(3.0)
	assert(arena.hero_chest_show.is_empty())
	var restored = load("res://multi_observer.tscn").instantiate()
	root.add_child(restored)
	restored.set_process(false)
	game.save_game()
	restored.load_game()
	assert(restored.arenas[first].hero_class == arena.hero_class)
	assert(restored.awarded.has("%s_%d" % [game.run_id,serial]))
	assert(restored.arenas[first].counter_opened.has("orb"))
	restored.queue_free()
	print("DYNAMIC_ARENA_REWARD_OK")
	game.queue_free()
	await process_frame
	quit()

func arena_for_test(game, index: int):
	return game.arenas[index]
