extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func click_at(game, point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = point
	game._unhandled_input(event)

func run_test() -> void:
	var game = load("res://multi_observer.tscn").instantiate()
	root.add_child(game)
	game.start_operation()
	var first: int = game.launch_times.find(0.0)
	assert(game.focus == -1)
	var card0: Rect2 = game.squad_card_rect(0)
	var point := card0.position+Vector2(12,12)
	var initial_mana: float = game.mana
	click_at(game,point)
	assert(game.reserves.is_empty() and game.mana == initial_mana)
	assert(game.notice.find("전장") >= 0)
	var digit := InputEventKey.new()
	digit.keycode = KEY_1
	digit.pressed = true
	game._unhandled_input(digit)
	assert(game.reserves.is_empty())
	var waiting := -1
	for i in 4:
		if not game.launched[i]: waiting = i; break
	assert(waiting >= 0)
	click_at(game,Vector2(float(waiting%2)*600.0+20.0,float(waiting/2)*450.0+50.0))
	assert(game.focus == waiting)
	click_at(game,point)
	assert(game.reserves.is_empty())
	assert(game.notice.find("입장") >= 0)
	click_at(game,Vector2(float(first%2)*600.0+20.0,float(first/2)*450.0+50.0))
	assert(game.focus == first)
	var cost: float = game.arenas[first].TYPES["zombie"]["cost"]
	click_at(game,point)
	assert(game.reserves.size() == 1)
	assert(game.reserves[0]["arena"] == first and game.reserves[0]["type"] == "zombie")
	assert(absf(game.mana-(initial_mana-cost)) < 0.001)
	click_at(game,point)
	assert(game.reserves.size() == 2)
	assert(absf(game.mana-(initial_mana-cost*2.0)) < 0.001)
	game.mana = 0.0
	click_at(game,point)
	assert(game.reserves.size() == 2 and game.notice.find("마력") >= 0)
	game.mana = game.mana_max
	game.reserves.append({"arena":first,"type":"zombie"})
	click_at(game,point)
	assert(game.reserves.size() == game.reserve_limit and game.notice.find("대기열") >= 0)
	var before_spawn: int = game.arenas[first].monsters.size()
	game.reserve_clock = 2.4
	game._process(0.01)
	assert(game.reserves.size() == game.reserve_limit-1)
	assert(game.arenas[first].monsters.size() > before_spawn)
	game.reserves.clear()
	var entries: Array[String] = game.unlocked.duplicate()
	for key in game.reference_arena().TYPES.keys():
		var id: String = key
		if id != "bat" and not entries.has(id): entries.append(id)
		if entries.size() >= 16: break
	game.unlocked = entries
	click_at(game,Vector2(1530,858))
	assert(game.roster_page == 1)
	var page_id: String = game.unlocked[14]
	var page_cost: float = game.reference_arena().TYPES[page_id]["cost"]
	game.mana = maxf(game.mana_max,page_cost+5.0)
	click_at(game,point)
	assert(game.reserves.size() == 1 and game.reserves[0]["type"] == page_id)
	assert(game.focus == first)
	game.current_event = {"kind":"unlock","arena":first,"id":"test","picks":1}
	game.options.assign(["rat"])
	game.choose_unlock(0)
	assert(game.focus == first)
	game.arenas[first].state = "victory"
	assert(game.squad_block_reason(page_id).find("종료") >= 0)
	game.arenas[first].state = "observe"
	game.current_event = {"kind":"chest","arena":first,"id":"test_chest"}
	game.begin_roulette()
	assert(game.focus == first)
	game.save_game()
	game.set_process(false)
	var resumed = load("res://multi_observer.tscn").instantiate()
	root.add_child(resumed)
	assert(resumed.focus == first and resumed.roster_page == 1)
	assert(resumed.reserves.size() == 1 and resumed.reserves[0]["type"] == page_id)
	assert(resumed.current_event["kind"] == "chest")
	assert(resumed.roulette["reward"] == game.roulette["reward"])
	print("MULTI_ARENA_SQUAD_CARDS_OK")
	resumed.queue_free()
	game.queue_free()
	quit()
