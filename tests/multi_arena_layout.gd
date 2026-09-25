extends SceneTree

const FONT = preload("res://fonts/NanumGothic-Regular.ttf")

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	assert(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 1600)
	assert(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 900)
	var game = load("res://multi_observer.tscn").instantiate()
	root.add_child(game)
	game.start_operation()
	game.operation_elapsed = 120.0
	game._process(0.01)
	for i in 4:
		var card := Rect2(Vector2(float(i%2)*600.0,float(i/2)*450.0),Vector2(600,450))
		var battle := Rect2(card.position+Vector2(42,31),Vector2(516,349))
		var footer := Rect2(card.position+Vector2(0,382),Vector2(600,68))
		assert(card.end.x <= 1200.0 and card.end.y <= 900.0)
		assert(not battle.intersects(footer))
		assert(card.encloses(battle) and card.encloses(footer))
		var arena = game.arenas[i]
		for j in 6:
			var line := "%s %d/5 · %s %d/3 ★" % [arena.ULTIMATE_NAMES[j].substr(0,3),5,game.ITEM_SHORT[j],3]
			assert(FONT.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x <= 177.0)
		var heading := "F%d %s  30:00 / 30:00  영웅 Lv99  HP 100%% · 일시 정지" % [i+1,game.NAMES[i]]
		assert(FONT.get_string_size(heading,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x <= 580.0)
	for local_index in 14:
		var card: Rect2 = game.squad_card_rect(local_index)
		assert(card.position.x >= 1200.0 and card.end.x <= 1600.0)
		assert(card.position.y >= 510.0 and card.end.y < 845.0)
	print("MULTI_ARENA_LAYOUT_OK")
	game.queue_free()
	quit()
