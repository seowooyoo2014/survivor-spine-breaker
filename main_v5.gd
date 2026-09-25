extends Node2D

const FONT = preload("res://fonts/NanumGothic-Regular.ttf")
const VOICE_BLEEP = preload("res://audio/voice_bleep.wav")
const SCREEN := Vector2(1280, 720)
const STAGE_CAP := {4: 12}
const MAX_TIME := 1800.0
const SAVE_PATH := "user://save_v3.cfg"
const SQUADS := {
	"goblin": {"name": "고블린 분대", "cost": 30.0, "members": ["goblin", "goblin"]},
	"frost": {"name": "냉동 분대", "cost": 40.0, "members": ["frost", "frost"]},
	"captain": {"name": "해골 대장 분대", "cost": 75.0, "members": ["captain", "skeleton", "skeleton"]}
}
const MONSTERS := {
	"goblin": {"hp": 43.0, "damage": 4.5, "speed": 100.0, "color": Color("88c666")},
	"skeleton": {"hp": 62.0, "damage": 4.0, "speed": 79.0, "color": Color("e0ddd2")},
	"frost": {"hp": 55.0, "damage": 5.0, "speed": 82.0, "color": Color("83d9ed")},
	"captain": {"hp": 125.0, "damage": 9.0, "speed": 72.0, "color": Color("dfca8e")},
	"friend": {"hp": 140.0, "damage": 6.0, "speed": 112.0, "color": Color("faf0d5")},
	"defender": {"hp": 43.0, "damage": 0.3, "speed": 110.0, "color": Color("9ac074")},
	"commander": {"hp": 620.0, "damage": 10.0, "speed": 88.0, "color": Color("6c9f57")},
	"brute": {"hp": 160.0, "damage": 10.0, "speed": 60.0, "color": Color("a878b2")}
}

var state := "title"
var intro_phase := 0
var phase_time := 0.0
var card_kind := ""
var stage_number := 0
var next_stage := 1
var prologue_done := false
var gold := 0
var frost_hired := false
var captain_hired := false
var hp_upgrade := false
var army_upgrade := false
var cap_bonus := 0
var equipped_squad := "goblin"
var save_location := "battle"
var camp_stage := 0
var camp_pos := Vector2(640, 510)
var opened_chest_stages: Array[int] = []
var camp_event_seen_stages: Array[int] = []
var camp_chest_result := ""
var slime_power_upgrade := false
var guild_guard_seen := false
var guard_index := 0
var camp_event_lines: Array[Dictionary] = []
var camp_event_index := 0
var briefing_index := 0
var camp_save_clock := 0.0
var world_width := 2300.0
var camera_x := 0.0
var player_pos := Vector2(335, 420)
var friend_pos := Vector2(160, 415)
var commander_pos := Vector2(1190, 390)
var runner_pos := Vector2(2180, 365)
var player_hp := 100.0
var player_max_hp := 100.0
var player_attack_cd := 0.0
var dash_cd := 0.0
var dash_time := 0.0
var summon_cd := 0.0
var mana := 100.0
var elapsed := 0.0
var rescue_used := false
var player_downed := false
var spawn_clock := 0.0
var spawn_index := 0
var end_victory := false
var end_reason := ""
var last_aim := Vector2.RIGHT
var heroes: Array[Dictionary] = []
var allies: Array[Dictionary] = []
var fallen_heroes: Array[Dictionary] = []
var slime_shots: Array[Dictionary] = []
var cores: Array[Dictionary] = []
var pickups: Array[Dictionary] = []
var hero_announcements: Array[String] = []
var pending_heroes: Array[Dictionary] = []
var message := ""
var message_time := 0.0
var hit_fx: Array[Dictionary] = []
var voice: AudioStreamPlayer
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	voice = AudioStreamPlayer.new()
	add_child(voice)
	voice.stream = VOICE_BLEEP
	voice.volume_db = -10.0
	if FileAccess.file_exists(SAVE_PATH):
		load_save()
		state = "title"
	else:
		start_new_story()

func _exit_tree() -> void:
	if voice != null:
		voice.stop()
		voice.stream = null

func speak() -> void:
	if DisplayServer.get_name() == "headless": return
	voice.stop()
	voice.play()

func load_save() -> void:
	var save := ConfigFile.new()
	if save.load(SAVE_PATH) != OK: return
	prologue_done = bool(save.get_value("story", "prologue_done", false))
	next_stage = clampi(int(save.get_value("story", "next_stage", 1)), 1, 5)
	gold = maxi(0, int(save.get_value("progress", "gold", 0)))
	frost_hired = bool(save.get_value("progress", "frost_hired", false))
	captain_hired = bool(save.get_value("progress", "captain_hired", false))
	hp_upgrade = bool(save.get_value("progress", "hp_upgrade", false))
	army_upgrade = bool(save.get_value("progress", "army_upgrade", false))
	cap_bonus = clampi(int(save.get_value("progress", "cap_bonus", 0)), 0, 3)
	equipped_squad = String(save.get_value("progress", "equipped_squad", "goblin"))
	slime_power_upgrade = bool(save.get_value("progress", "slime_power_upgrade", false))
	save_location = String(save.get_value("story", "location", "battle"))
	camp_stage = clampi(int(save.get_value("story", "camp_stage", 0)), 0, 3)
	camp_pos = save.get_value("story", "camp_pos", Vector2(640, 510))
	opened_chest_stages.clear()
	for value in save.get_value("story", "opened_chest_stages", []): opened_chest_stages.append(int(value))
	camp_event_seen_stages.clear()
	for value in save.get_value("story", "camp_event_seen_stages", []): camp_event_seen_stages.append(int(value))
	camp_chest_result = String(save.get_value("story", "camp_chest_result", ""))
	guild_guard_seen = bool(save.get_value("story", "guild_guard_seen", false))
	camp_event_index = maxi(0, int(save.get_value("story", "camp_event_index", 0)))
	if not SQUADS.has(equipped_squad) or (equipped_squad == "frost" and not frost_hired) or (equipped_squad == "captain" and not captain_hired):
		equipped_squad = "goblin"

func save_game() -> void:
	var save := ConfigFile.new()
	save.set_value("story", "prologue_done", prologue_done)
	save.set_value("story", "next_stage", next_stage)
	save.set_value("progress", "gold", gold)
	save.set_value("progress", "frost_hired", frost_hired)
	save.set_value("progress", "captain_hired", captain_hired)
	save.set_value("progress", "hp_upgrade", hp_upgrade)
	save.set_value("progress", "army_upgrade", army_upgrade)
	save.set_value("progress", "cap_bonus", cap_bonus)
	save.set_value("progress", "equipped_squad", equipped_squad)
	save.set_value("progress", "slime_power_upgrade", slime_power_upgrade)
	save.set_value("story", "location", save_location)
	save.set_value("story", "camp_stage", camp_stage)
	save.set_value("story", "camp_pos", camp_pos)
	save.set_value("story", "opened_chest_stages", opened_chest_stages)
	save.set_value("story", "camp_event_seen_stages", camp_event_seen_stages)
	save.set_value("story", "camp_chest_result", camp_chest_result)
	save.set_value("story", "guild_guard_seen", guild_guard_seen)
	save.set_value("story", "camp_event_index", camp_event_index)
	save.save(SAVE_PATH)

func start_new_story() -> void:
	prologue_done = false
	next_stage = 1
	gold = 0
	frost_hired = false
	captain_hired = false
	hp_upgrade = false
	army_upgrade = false
	cap_bonus = 0
	equipped_squad = "goblin"
	slime_power_upgrade = false
	save_location = "battle"
	camp_stage = 0
	camp_pos = Vector2(640, 510)
	opened_chest_stages.clear()
	camp_event_seen_stages.clear()
	camp_chest_result = ""
	guild_guard_seen = false
	camp_event_index = 0
	save_game()
	start_intro()

func start_intro() -> void:
	state = "intro"
	intro_phase = 0
	phase_time = 0.0
	stage_number = 0
	world_width = 2300.0
	camera_x = 0.0
	player_pos = Vector2(335, 420)
	friend_pos = Vector2(125, 417)
	commander_pos = Vector2(1190, 390)
	runner_pos = Vector2(2190, 365)
	heroes.clear()
	allies.clear()
	cores.clear()
	pickups.clear()
	fallen_heroes.clear()
	slime_shots.clear()
	for i in 13:
		var x := 990.0 + float(i % 7) * 46.0
		var y := 275.0 + float(i / 7) * 118.0 + float(i % 2) * 22.0
		allies.append(make_ally("defender", Vector2(x, y), 0, false))
	speak()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and (state == "battle" or state == "prologue_battle"):
		var mouse: InputEventMouseButton = event
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			if state == "battle" and stage_number == 4 and mouse.position.y >= 610.0:
				if mouse.position.x >= 470.0 and mouse.position.x < 845.0:
					select_squad(int((mouse.position.x - 470.0) / 125.0))
			else:
				fire_slime(mouse.position)
			queue_redraw()
		return
	if not (event is InputEventKey and event.pressed and not event.echo): return
	var key: int = event.keycode
	if state == "title":
		if key == KEY_ENTER:
			if prologue_done:
				if next_stage > 4: state = "ending"
				elif save_location == "camp": enter_camp(false)
				else: start_stage(next_stage)
			else: start_intro()
		elif key == KEY_N: start_new_story()
	elif state == "card" and key == KEY_ENTER:
		advance_card()
	elif state == "tutorial" and key == KEY_ENTER:
		start_prologue_battle()
	elif state == "promotion" and key == KEY_ENTER:
		prepare_camp_after_stage(3)
		enter_camp(true)
	elif state == "battle_end" and key == KEY_ENTER and phase_time >= 1.2:
		finish_battle_end()
	elif state == "battle" or state == "prologue_battle":
		if key == KEY_SPACE: dash()
		elif state == "battle" and stage_number == 4:
			if key == KEY_R: summon_squad()
			elif key >= KEY_1 and key <= KEY_3: select_squad(key - KEY_1)
	elif state == "camp" and key == KEY_E:
		interact_camp()
	elif state == "camp_event" and key == KEY_ENTER:
		advance_camp_event()
	elif state == "camp_guard" and key == KEY_ENTER:
		guard_index += 1
		if guard_index >= 3: state = "camp"
	elif state == "camp_reward" and key == KEY_ENTER:
		state = "camp"
	elif state == "camp_shop":
		if key == KEY_1 or key == KEY_2: buy_offer(key - KEY_1)
		elif key == KEY_ENTER: state = "camp"
	elif state == "camp_guild":
		if key == KEY_1 or key == KEY_2: buy_guild_contract(key - KEY_1)
		elif key == KEY_ENTER: state = "camp"
	elif state == "stage2_briefing" and key == KEY_ENTER:
		briefing_index += 1
		if briefing_index >= 3: start_stage(2)
	elif state == "lost" and key == KEY_ENTER:
		if stage_number == 0: start_prologue_battle()
		else: start_stage(stage_number)
	elif state == "ending" and key == KEY_ENTER:
		state = "title"
	queue_redraw()

func advance_card() -> void:
	if card_kind == "slime":
		card_kind = "friend"
	elif card_kind == "friend":
		state = "intro"
		intro_phase = 2
		phase_time = 0.0
	elif card_kind == "commander":
		state = "intro"
		intro_phase = 4
		phase_time = 0.0
		speak()

func show_card(kind: String) -> void:
	card_kind = kind
	state = "card"
	phase_time = 0.0

func _process(delta: float) -> void:
	var dt := minf(delta, 0.05)
	if state == "intro": update_intro(dt)
	elif state == "battle" or state == "prologue_battle": update_battle(dt)
	elif state == "return_cutscene": update_return_cutscene(dt)
	elif state == "camp": update_camp(dt)
	elif state == "battle_end":
		phase_time += dt
		if phase_time >= 1.2: revive_named_cast()
		if phase_time >= 3.2: finish_battle_end()
	if message_time > 0.0: message_time = maxf(0.0, message_time - dt)
	for i in range(hit_fx.size() - 1, -1, -1):
		hit_fx[i]["time"] -= dt
		if hit_fx[i]["time"] <= 0.0: hit_fx.remove_at(i)
	queue_redraw()

func update_intro(dt: float) -> void:
	phase_time += dt
	match intro_phase:
		0:
			if phase_time >= 1.7: change_phase(1)
		1:
			friend_pos = friend_pos.move_toward(player_pos + Vector2(-68, 0), 100.0 * dt)
			if phase_time >= 2.3: show_card("slime")
		2:
			player_pos = player_pos.move_toward(Vector2(1050, 412), 130.0 * dt)
			friend_pos = friend_pos.move_toward(player_pos + Vector2(-58, 8), 160.0 * dt)
			camera_x = clampf(player_pos.x - 540.0, 0.0, world_width - SCREEN.x)
			if player_pos.x >= 1048.0:
				change_phase(3)
				speak()
		3:
			if phase_time >= 3.3: show_card("commander")
		4:
			if phase_time >= 3.0: change_phase(5)
		5:
			if phase_time >= 2.2:
				change_phase(6)
				speak()
		6:
			runner_pos = runner_pos.move_toward(Vector2(1360, 363), 350.0 * dt)
			if runner_pos.x <= 1362.0:
				change_phase(7)
				speak()
		7:
			for ally in allies:
				ally["pos"] = ally["pos"].move_toward(Vector2(1850, ally["pos"].y), 255.0 * dt)
			player_pos = player_pos.move_toward(Vector2(1740, 412), 180.0 * dt)
			friend_pos = friend_pos.move_toward(player_pos + Vector2(-55, 10), 210.0 * dt)
			commander_pos = commander_pos.move_toward(Vector2(1720, 390), 160.0 * dt)
			camera_x = clampf(player_pos.x - 530.0, 0.0, world_width - SCREEN.x)
			if player_pos.x >= 1710.0 or phase_time >= 5.0:
				state = "tutorial"
				player_pos = Vector2(1720, 412)
				friend_pos = Vector2(1670, 420)
				camera_x = 1000.0

func change_phase(value: int) -> void:
	intro_phase = value
	phase_time = 0.0

func make_ally(kind: String, pos: Vector2, lane: int, controlled: bool) -> Dictionary:
	var data: Dictionary = MONSTERS[kind]
	var hp: float = data["hp"] * (1.15 if army_upgrade and controlled else 1.0)
	return {"kind": kind, "pos": pos, "lane": lane, "controlled": controlled,
		"hp": hp, "max_hp": hp, "attack_cd": rng.randf_range(0.0, 0.5), "downed": false}

func start_prologue_battle() -> void:
	var keep_cutscene_allies := state == "tutorial" and not allies.is_empty()
	state = "prologue_battle"
	stage_number = 0
	world_width = 2300.0
	player_pos = Vector2(1700, 410)
	friend_pos = Vector2(1660, 425)
	player_max_hp = 300.0
	player_hp = player_max_hp
	player_attack_cd = 0.0
	dash_cd = 0.0
	dash_time = 0.0
	elapsed = 0.0
	rescue_used = false
	player_downed = false
	spawn_clock = 0.0
	spawn_index = 0
	camera_x = 1010.0
	heroes.clear()
	fallen_heroes.clear()
	slime_shots.clear()
	cores.clear()
	pickups.clear()
	pending_heroes.clear()
	if not keep_cutscene_allies:
		allies.clear()
		for i in 13:
			allies.append(make_ally("defender", Vector2(1730 + (i % 5) * 38, 250 + (i / 5) * 80), 0, false))
	allies.append(make_ally("friend", friend_pos, 0, false))
	allies.append(make_ally("commander", commander_pos if keep_cutscene_allies else Vector2(1710, 370), 0, false))
	allies.append(make_ally("brute", Vector2(1800, 350), 0, false))
	add_hero("첫 영웅", "blade", Vector2(2040, 390), 0, 800.0, 42, 92.0)
	set_message("말록: 혼자 가지 마! 같이 싸우자!", 4.0)

func start_stage(number: int) -> void:
	state = "battle"
	stage_number = number
	world_width = 1600.0 if number == 1 else 2300.0
	player_pos = Vector2(420, 420) if number == 1 else Vector2(1130, 415)
	player_max_hp = 300.0 + number * 110.0 + (60.0 if hp_upgrade else 0.0)
	player_hp = player_max_hp
	player_attack_cd = 0.0
	dash_cd = 0.0
	dash_time = 0.0
	summon_cd = 0.0
	mana = 100.0
	elapsed = 0.0
	player_downed = false
	spawn_clock = 0.0
	spawn_index = 0
	camera_x = clampf(player_pos.x - 550.0, 0.0, world_width - SCREEN.x)
	heroes.clear()
	fallen_heroes.clear()
	slime_shots.clear()
	allies.clear()
	cores.clear()
	pickups.clear()
	pending_heroes.clear()
	for lane in (2 if number > 1 else 1):
		var center := (650.0 if number == 1 else 680.0) if lane == 0 else 1580.0
		for i in (18 if number == 2 else 36):
			allies.append(make_ally("defender", Vector2(center - 140 + (i % 9) * 35, 190 + (i / 9) * 96 + (i % 2) * 12), lane, false))
		allies.append(make_ally("brute", Vector2(center + 95, 395), lane, false))
	allies.append(make_ally("friend", Vector2(player_pos.x - 55, player_pos.y + 20), lane_for_x(player_pos.x), false))
	if number <= 2:
		allies.append(make_ally("commander", Vector2(player_pos.x + 56, player_pos.y - 30), 0, false))
	if number == 1:
		add_hero("정문 영웅", "blade", Vector2(1370, 395), 0, 3000.0, 110, 100.0)
	elif number == 2:
		add_hero("불의 지팡이 영웅", "fire", Vector2(820, 400), 0, 1450.0, 125, 96.0)
		add_hero("서쪽 영웅", "blade", Vector2(1510, 380), 1, 1450.0, 125, 96.0)
	else:
		add_hero("불의 지팡이 영웅", "fire", Vector2(800, 390), 0, 390.0, 145, 100.0)
		add_hero("사냥꾼 영웅", "arrow", Vector2(1510, 390), 1, 400.0, 145, 102.0)
		pending_heroes.append({"delay": 18.0, "name": "뒤늦은 영웅", "weapon": "blade", "pos": Vector2(1100, 360), "lane": 0, "hp": 400.0, "gold": 145, "speed": 97.0})
	save_location = "battle"
	set_message("바츠: 전열 유지. 영웅의 생존 시간을 끊어라." if number == 1 else ("말록: 영웅이 30분을 버티면 패배야." if number < 4 else "바츠: 분대를 선택하고 전선을 확보하라."), 4.0)

func add_hero(hero_name: String, weapon: String, pos: Vector2, lane: int, hp: float, bounty: int, speed: float) -> void:
	heroes.append({"name": hero_name, "weapon": weapon, "pos": pos, "lane": lane, "hp": hp,
		"max_hp": hp, "bounty": bounty, "speed": speed, "level": 1, "exp": 0,
		"attack_cd": 0.5, "slow": 0.0, "bomb_cd": 4.0, "charm_cd": 2.0,
		"bomb": false, "charm": false, "shield": 0, "kills": 0, "exp_goal": 4,
		"contact_cd": 0.0, "wander_phase": rng.randf_range(0.0, TAU),
		"weapon_levels": {"blade": 1, "charm": 0, "bomb": 0}})

func lane_for_x(x: float) -> int:
	return 0 if stage_number <= 1 or x < 1150.0 else 1

func command_cap() -> int:
	return 0 if stage_number < 4 else STAGE_CAP[4] + cap_bonus

func select_squad(index: int) -> void:
	var ids := ["goblin", "frost", "captain"]
	if index < 0 or index >= ids.size(): return
	var chosen: String = ids[index]
	if (chosen == "frost" and not frost_hired) or (chosen == "captain" and not captain_hired):
		set_message("먼저 진영 길드에서 분대 계약을 맺어야 한다.", 2.5)
		return
	equipped_squad = chosen
	set_message("선택: %s. R로 전선 진입 명령." % SQUADS[chosen]["name"], 2.0)
	save_game()

func controlled_count() -> int:
	var total := 0
	for ally in allies:
		if ally["controlled"] and ally["hp"] > 0.0: total += 1
	return total

func cycle_squad() -> void:
	var owned := ["goblin"]
	if frost_hired: owned.append("frost")
	if captain_hired: owned.append("captain")
	equipped_squad = owned[(owned.find(equipped_squad) + 1) % owned.size()]
	save_game()

func summon_squad() -> void:
	if stage_number < 4: return
	if summon_cd > 0.0: return
	var squad: Dictionary = SQUADS[equipped_squad]
	var count: int = squad["members"].size()
	if controlled_count() + count > command_cap():
		set_message("지휘 한도에 빈자리가 부족해!", 2.5)
		return
	if mana < squad["cost"]:
		set_message("마력이 부족해!", 2.0)
		return
	mana -= squad["cost"]
	summon_cd = 3.2
	for i in count:
		var spawn_pos := player_pos + Vector2(-30.0 + float(i) * 30.0, 42.0 + float(i % 2) * 26.0)
		allies.append(make_ally(squad["members"][i], spawn_pos, lane_for_x(player_pos.x), true))
	set_message("%s, 현재 전선으로 진입하라." % squad["name"], 2.5)

func dash() -> void:
	if dash_cd > 0.0 or player_downed: return
	dash_cd = 3.0
	dash_time = 0.3

func fire_slime(screen_pos: Vector2) -> void:
	if player_downed: return
	var aim_world := screen_pos + Vector2(camera_x, 0.0)
	var direction: Vector2 = (aim_world - player_pos).normalized()
	if direction.length_squared() < 0.01: direction = last_aim
	last_aim = direction
	slime_shots.append({"pos": player_pos + direction * 21.0, "vel": direction * 650.0, "travel": 0.0,
		"damage": 17.0 + (4.0 if slime_power_upgrade else 0.0)})
	hit_fx.append({"pos": player_pos + direction * 20.0, "time": 0.09, "color": Color("a8f5ae")})

func update_slime_shots(dt: float) -> void:
	for i in range(slime_shots.size() - 1, -1, -1):
		var shot: Dictionary = slime_shots[i]
		var origin: Vector2 = shot["pos"]
		var destination: Vector2 = origin + shot["vel"] * dt
		shot["pos"] = destination
		shot["travel"] += origin.distance_to(destination)
		var hit := false
		for hero in heroes:
			if hero["hp"] <= 0.0: continue
			var closest: Vector2 = Geometry2D.get_closest_point_to_segment(hero["pos"], origin, destination)
			if closest.distance_to(hero["pos"]) <= 24.0:
				damage_hero(hero, shot["damage"])
				hit_fx.append({"pos": closest, "time": 0.22, "color": Color("80e8a3")})
				hit = true
				break
		if hit or shot["travel"] > 900.0 or destination.x < 0.0 or destination.x > world_width or destination.y < 60.0 or destination.y > 670.0:
			slime_shots.remove_at(i)

func update_stage1_spawns(dt: float) -> void:
	if stage_number != 1: return
	spawn_clock += dt
	if spawn_clock < 1.15: return
	spawn_clock -= 1.15
	var active := 0
	for ally in allies:
		if ally["hp"] > 0.0 and ally["kind"] != "friend" and ally["kind"] != "commander": active += 1
	if active >= 90: return
	var side := spawn_index % 4
	var x := clampf(camera_x + 50.0 + rng.randf() * (SCREEN.x - 100.0), 35.0, world_width - 35.0)
	var y := rng.randf_range(175.0, 560.0)
	match side:
		0: x = clampf(camera_x + 30.0, 35.0, world_width - 35.0)
		1: x = clampf(camera_x + SCREEN.x - 30.0, 35.0, world_width - 35.0)
		2: y = 145.0
		3: y = 590.0
	var kind := "goblin"
	if elapsed >= 45.0 and spawn_index % 14 == 13: kind = "brute"
	elif elapsed >= 25.0 and spawn_index % 3 == 2: kind = "frost"
	elif elapsed >= 12.0 and spawn_index % 2 == 1: kind = "skeleton"
	allies.append(make_ally(kind, Vector2(x, y), 0, false))
	spawn_index += 1

func begin_battle_end(victory: bool, reason: String) -> void:
	state = "battle_end"
	phase_time = 0.0
	end_victory = victory
	end_reason = reason
	set_message(reason, 3.0)

func revive_named_cast() -> void:
	if player_downed:
		player_downed = false
		player_hp = maxf(1.0, player_max_hp * 0.45)
	for ally in allies:
		if ally["downed"]:
			ally["downed"] = false
			ally["hp"] = maxf(1.0, ally["max_hp"] * 0.45)

func finish_battle_end() -> void:
	if state != "battle_end": return
	revive_named_cast()
	if not end_victory:
		lose(end_reason)
	elif stage_number == 0:
		prologue_done = true
		next_stage = 1
		save_game()
		start_stage(1)
	else:
		prepare_camp_after_stage(stage_number)
		begin_return_cutscene()

func prepare_camp_after_stage(number: int) -> void:
	camp_stage = number
	next_stage = maxi(next_stage, number + 1)
	save_location = "camp"
	camp_pos = Vector2(640, 510)
	camp_event_index = 0
	save_game()

func begin_return_cutscene() -> void:
	state = "return_cutscene"
	phase_time = 0.0
	revive_named_cast()
	set_message("바츠: 부상자를 확인했다. 전원 진영으로 돌아간다.", 3.0)

func update_return_cutscene(dt: float) -> void:
	phase_time += dt
	player_pos.x = maxf(45.0, player_pos.x - 140.0 * dt)
	for ally in allies:
		if ally["kind"] == "friend" or ally["kind"] == "commander":
			var moving_pos: Vector2 = ally["pos"]
			moving_pos.x = maxf(45.0, moving_pos.x - 140.0 * dt)
			ally["pos"] = moving_pos
	camera_x = lerpf(camera_x, clampf(player_pos.x - 560.0, 0.0, world_width - SCREEN.x), minf(1.0, dt * 5.0))
	if phase_time >= 3.0: enter_camp(true)

func camp_lines(number: int) -> Array[Dictionary]:
	if number == 1:
		return [
			{"speaker": "바츠", "line": "전열 정리. 부상자는 치료소로. 아쿠마, 너도 따라와.", "portrait": "commander"},
			{"speaker": "말록", "line": "저 보석... 영웅이 남긴 것인데 네 몸에 반응하고 있어.", "portrait": "friend"},
			{"speaker": "아쿠마", "line": "손을 대지 않았는데도 안쪽에서 울리는 것 같아.", "portrait": "slime"},
			{"speaker": "바츠", "line": "지금은 보고하지 않는다. 내가 먼저 확인하겠다.", "portrait": "commander"}
		]
	if number == 2:
		return [
			{"speaker": "말록", "line": "두 갈래 전선에서 돌아왔는데 보석이 다시 빛났어.", "portrait": "friend"},
			{"speaker": "아쿠마", "line": "영웅이 가까워질 때마다 반응이 강해졌어.", "portrait": "slime"},
			{"speaker": "바츠", "line": "원인은 아직 모른다. 확인되지 않은 일은 기록하지 마라.", "portrait": "commander"}
		]
	return [
		{"speaker": "바츠", "line": "지휘관 임명은 완료됐다. 길드에서 분대 계약을 확인해라.", "portrait": "commander"},
		{"speaker": "말록", "line": "이제 길드 문지기도 널 막지는 못하겠군.", "portrait": "friend"}
	]

func enter_camp(_arrived: bool) -> void:
	world_width = SCREEN.x
	camera_x = 0.0
	player_pos = camp_pos
	camp_event_lines = camp_lines(camp_stage)
	if not camp_event_seen_stages.has(camp_stage):
		camp_event_index = mini(camp_event_index, camp_event_lines.size() - 1)
		state = "camp_event"
	else:
		state = "camp"
	save_location = "camp"
	save_game()

func advance_camp_event() -> void:
	camp_event_index += 1
	if camp_event_index >= camp_event_lines.size():
		if not camp_event_seen_stages.has(camp_stage): camp_event_seen_stages.append(camp_stage)
		camp_event_index = 0
		state = "camp"
	save_game()

func update_camp(dt: float) -> void:
	var motion := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): motion.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): motion.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): motion.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): motion.y += 1.0
	if motion.length_squared() > 0.0:
		camp_pos += motion.normalized() * 230.0 * dt
		camp_pos.x = clampf(camp_pos.x, 35.0, SCREEN.x - 35.0)
		camp_pos.y = clampf(camp_pos.y, 220.0, 620.0)
		player_pos = camp_pos
	camp_save_clock += dt
	if camp_save_clock >= 2.0:
		camp_save_clock = 0.0
		save_game()

func interact_camp() -> void:
	if camp_pos.distance_to(Vector2(700, 450)) < 85.0:
		open_camp_chest()
	elif camp_pos.distance_to(Vector2(355, 458)) < 105.0:
		state = "camp_shop"
	elif camp_pos.distance_to(Vector2(1010, 452)) < 110.0:
		if camp_stage >= 3:
			state = "camp_guild"
		elif not guild_guard_seen:
			guild_guard_seen = true
			guard_index = 0
			state = "camp_guard"
			save_game()
		else: set_message("문지기: 지휘관 계급장을 확인받고 오라.", 3.0)
	elif camp_pos.distance_to(Vector2(1185, 445)) < 100.0:
		if not opened_chest_stages.has(camp_stage):
			set_message("바츠: 보급 상자를 확인하고 출정하라.", 3.0)
			return
		save_location = "battle"
		save_game()
		if next_stage == 2:
			briefing_index = 0
			state = "stage2_briefing"
		else: start_stage(next_stage)
	else:
		set_message("가까운 시설에서 E를 눌러라.", 2.0)

func open_camp_chest() -> void:
	if opened_chest_stages.has(camp_stage):
		set_message("이번 전투의 보급품은 이미 수령했다.", 2.5)
		return
	var pool := ["gold", "gold"]
	if not hp_upgrade: pool.append("hp")
	if not slime_power_upgrade: pool.append("slime_power")
	var choice: String = pool[rng.randi_range(0, pool.size() - 1)]
	match choice:
		"gold":
			gold += 80
			camp_chest_result = "금화 80 획득"
		"hp":
			hp_upgrade = true
			camp_chest_result = "슬라임 심장 획득 · 최대 체력 +60"
		"slime_power":
			slime_power_upgrade = true
			camp_chest_result = "점액 압축낭 획득 · 점액탄 피해 +4"
	opened_chest_stages.append(camp_stage)
	state = "camp_reward"
	save_game()

func buy_guild_contract(index: int) -> void:
	if camp_stage < 3: return
	var id := "frost" if index == 0 else "captain"
	var price := 70 if index == 0 else 145
	if (id == "frost" and frost_hired) or (id == "captain" and captain_hired):
		set_message("이미 계약한 분대다.", 2.0)
		return
	if gold < price:
		set_message("금화가 부족하다.", 2.0)
		return
	gold -= price
	if id == "frost": frost_hired = true
	else: captain_hired = true
	equipped_squad = id
	set_message("%s 계약 완료." % SQUADS[id]["name"], 2.5)
	save_game()

func set_message(value: String, duration: float = 3.0) -> void:
	message = value
	message_time = duration

func update_battle(dt: float) -> void:
	elapsed += dt
	if elapsed >= MAX_TIME:
		if stage_number <= 2: begin_battle_end(false, "영웅이 30분 동안 생존했다. 전선 철수.")
		else: lose("영웅이 30분 동안 살아남았습니다.")
		return
	player_attack_cd = maxf(0.0, player_attack_cd - dt)
	dash_cd = maxf(0.0, dash_cd - dt)
	dash_time = maxf(0.0, dash_time - dt)
	summon_cd = maxf(0.0, summon_cd - dt)
	mana = minf(100.0, mana + 5.0 * dt)
	update_player(dt)
	update_slime_shots(dt)
	update_allies(dt)
	update_pickups(dt)
	update_heroes(dt)
	update_stage1_spawns(dt)
	for i in range(pending_heroes.size() - 1, -1, -1):
		if elapsed >= pending_heroes[i]["delay"]:
			var pending: Dictionary = pending_heroes[i]
			add_hero(pending["name"], pending["weapon"], pending["pos"], pending["lane"], pending["hp"], pending["gold"], pending["speed"])
			pending_heroes.remove_at(i)
			set_message("정찰병: 또 다른 영웅이 길목에 나타났어!", 3.0)
	if player_hp <= 0.0:
		if stage_number <= 2:
			if not player_downed:
				player_downed = true
				player_hp = 0.0
				set_message("말록: 아쿠마가 쓰러졌다. 대형 유지!", 3.5)
		else:
			lose("아쿠마가 쓰러졌습니다. Enter로 다시 도전하세요.")
			return
	if heroes.is_empty() and pending_heroes.is_empty():
		if stage_number <= 2:
			begin_battle_end(true, "바츠: 영웅 전투 불능. 전원 전열을 정비하라.")
		else:
			next_stage = maxi(next_stage, stage_number + 1)
			save_game()
			if stage_number == 3:
				prepare_camp_after_stage(3)
				state = "promotion"
			else: state = "ending"

func update_player(dt: float) -> void:
	if player_downed: return
	var motion := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): motion.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): motion.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): motion.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): motion.y += 1.0
	if motion.length_squared() > 0.0:
		player_pos += motion.normalized() * (435.0 if dash_time > 0.0 else 245.0) * dt
	player_pos.x = clampf(player_pos.x, 30.0, world_width - 30.0)
	player_pos.y = clampf(player_pos.y, 135.0, 615.0)
	camera_x = lerpf(camera_x, clampf(player_pos.x - 600.0, 0.0, world_width - SCREEN.x), minf(1.0, dt * 7.0))

func update_allies(dt: float) -> void:
	for ally in allies:
		if ally["hp"] <= 0.0: continue
		ally["attack_cd"] = maxf(0.0, ally["attack_cd"] - dt)
		var target: Dictionary = {}
		var best := INF
		for hero in heroes:
			if hero["lane"] != ally["lane"] or hero["hp"] <= 0.0: continue
			var distance: float = ally["pos"].distance_to(hero["pos"])
			if distance < best:
				best = distance
				target = hero
		if target.is_empty(): continue
		var data: Dictionary = MONSTERS[ally["kind"]]
		if best > 32.0:
			ally["pos"] = ally["pos"].move_toward(target["pos"], data["speed"] * dt)
		elif ally["attack_cd"] <= 0.0:
			var damage: float = data["damage"] * (1.2 if army_upgrade and ally["controlled"] else 1.0)
			damage_hero(target, damage)
			ally["attack_cd"] = 0.78
			if ally["kind"] == "frost": target["slow"] = 1.4
	for i in range(allies.size() - 1, -1, -1):
		if allies[i]["hp"] <= 0.0:
			var fallen: Dictionary = allies[i]
			if stage_number <= 2 and (fallen["kind"] == "friend" or fallen["kind"] == "commander"):
				fallen["hp"] = 0.0
				fallen["downed"] = true
				continue
			pickups.append({"kind": "gem", "pos": fallen["pos"], "lane": fallen["lane"], "value": 2 if fallen["kind"] == "brute" or fallen["kind"] == "captain" else 1})
			if fallen["kind"] == "brute" or fallen["kind"] == "captain":
				pickups.append({"kind": "chest", "pos": fallen["pos"] + Vector2(24, -8), "lane": fallen["lane"]})
			allies.remove_at(i)

func update_pickups(_dt: float) -> void:
	for i in range(pickups.size() - 1, -1, -1):
		var item: Dictionary = pickups[i]
		for hero in heroes:
			if hero["hp"] <= 0.0 or hero["lane"] != item["lane"]: continue
			if hero["pos"].distance_to(item["pos"]) > 27.0: continue
			if item["kind"] == "gem":
				hero["exp"] += item["value"]
				while hero["exp"] >= hero["exp_goal"]:
					hero["exp"] -= hero["exp_goal"]
					hero_level_up(hero)
			elif item["kind"] == "chest" or item["kind"] == "charm" or item["kind"] == "bomb":
				give_hero_item(hero, item["kind"])
			pickups.remove_at(i)
			break

func damage_hero(hero: Dictionary, amount: float) -> void:
	if hero["shield"] > 0:
		hero["shield"] -= 1
		hit_fx.append({"pos": hero["pos"], "time": 0.22, "color": Color("9bdcf5")})
	else:
		hero["hp"] -= amount

func damage_ally(ally: Dictionary, amount: float) -> void:
	ally["hp"] -= amount * (0.45 if ally["kind"] == "commander" else 1.0)

func apply_hero_contact(hero: Dictionary, dt: float) -> void:
	hero["contact_cd"] = maxf(0.0, hero["contact_cd"] - dt)
	if hero["contact_cd"] > 0.0: return
	if not player_downed and hero["pos"].distance_to(player_pos) <= 29.0:
		damage_hero(hero, 7.0)
		hero["contact_cd"] = 0.35
		return
	for ally in allies:
		if ally["hp"] <= 0.0 or ally["lane"] != hero["lane"]: continue
		var radius := 37.0 if ally["kind"] == "commander" or ally["kind"] == "brute" else 29.0
		if hero["pos"].distance_to(ally["pos"]) <= radius:
			damage_hero(hero, 5.0 if ally["kind"] == "commander" or ally["kind"] == "brute" else 3.0)
			hero["contact_cd"] = 0.35
			return

func give_hero_item(hero: Dictionary, source: String) -> void:
	var kind := source
	if stage_number == 1:
		var levels: Dictionary = hero["weapon_levels"]
		if source == "chest":
			kind = "charm" if levels["charm"] == 0 else ("bomb" if levels["bomb"] == 0 else ("blade" if levels["blade"] < 3 else ("charm" if levels["charm"] < 3 else ("bomb" if levels["bomb"] < 3 else "shield"))))
		if kind != "shield":
			levels[kind] = mini(3, int(levels[kind]) + 1)
			hero["charm"] = levels["charm"] > 0
			hero["bomb"] = levels["bomb"] > 0
		else:
			hero["shield"] += 1
		set_message("정찰병: %s, %s %s 확보." % [hero["name"], item_name(kind), "강화" if kind != "shield" and levels[kind] > 1 else "획득"], 3.5)
		return
	if source == "chest": kind = "charm" if not hero["charm"] else ("bomb" if not hero["bomb"] else "shield")
	match kind:
		"charm": hero["charm"] = true
		"bomb": hero["bomb"] = true
		"shield": hero["shield"] += 1
	set_message("정찰병: %s이(가) %s을(를) 얻었다!" % [hero["name"], item_name(kind)], 3.5)

func item_name(kind: String) -> String:
	match kind:
		"blade": return "검"
		"charm": return "매혹구"
		"bomb": return "폭탄"
		_: return "보호막"

func update_heroes(dt: float) -> void:
	for hero in heroes:
		if hero["hp"] <= 0.0: continue
		hero["attack_cd"] = maxf(0.0, hero["attack_cd"] - dt)
		hero["slow"] = maxf(0.0, hero["slow"] - dt)
		hero["bomb_cd"] = maxf(0.0, hero["bomb_cd"] - dt)
		hero["charm_cd"] = maxf(0.0, hero["charm_cd"] - dt)
		var target: Dictionary = {}
		var best := 250.0
		for ally in allies:
			if ally["lane"] != hero["lane"] or ally["hp"] <= 0.0: continue
			var distance: float = hero["pos"].distance_to(ally["pos"])
			if distance < best:
				best = distance
				target = ally
		var nearest_item: Dictionary = {}
		var item_distance := 370.0
		for item in pickups:
			if item["lane"] != hero["lane"]: continue
			var d: float = hero["pos"].distance_to(item["pos"])
			if d < item_distance:
				item_distance = d
				nearest_item = item
		hero["wander_phase"] += dt * 0.85
		var wander := Vector2(cos(hero["wander_phase"]), sin(hero["wander_phase"] * 0.77)).normalized()
		var threat_pos: Vector2 = target["pos"] if not target.is_empty() else player_pos
		var threat_distance: float = best if not target.is_empty() else INF
		if not player_downed and hero["pos"].distance_to(player_pos) < threat_distance:
			threat_pos = player_pos
			threat_distance = hero["pos"].distance_to(player_pos)
		var direction := wander
		if not nearest_item.is_empty() and threat_distance > 125.0 and item_distance < 330.0:
			direction = (nearest_item["pos"] - hero["pos"]).normalized()
		elif threat_distance < 260.0:
			var away: Vector2 = (hero["pos"] - threat_pos).normalized()
			direction = (away * 0.78 + Vector2(-away.y, away.x) * 0.15 + wander * 0.18).normalized()
		if direction.length_squared() < 0.01: direction = wander
		var min_x := 38.0 if stage_number <= 1 or hero["lane"] == 0 else 1195.0
		var max_x := world_width - 38.0 if stage_number <= 1 or hero["lane"] == 1 else 1105.0
		if hero["pos"].x <= min_x + 12.0 and direction.x < 0.0: direction.x = absf(direction.x)
		if hero["pos"].x >= max_x - 12.0 and direction.x > 0.0: direction.x = -absf(direction.x)
		if hero["pos"].y <= 155.0 and direction.y < 0.0: direction.y = absf(direction.y)
		if hero["pos"].y >= 580.0 and direction.y > 0.0: direction.y = -absf(direction.y)
		direction = direction.normalized()
		hero["pos"] += direction * hero["speed"] * (0.55 if hero["slow"] > 0.0 else 1.0) * dt
		hero["pos"].x = clampf(hero["pos"].x, min_x, max_x)
		hero["pos"].y = clampf(hero["pos"].y, 145.0, 590.0)
		apply_hero_contact(hero, dt)
		if stage_number == 1:
			update_stage1_hero_weapons(hero, target, best)
			continue
		var damage := 19.0 + float(hero["level"] - 1) * 4.0
		if hero["weapon"] == "fire": damage += 5.0
		if hero["attack_cd"] <= 0.0:
			if not target.is_empty() and best < (150.0 if hero["weapon"] == "arrow" else 115.0):
				for ally in allies:
					if ally["lane"] == hero["lane"] and ally["pos"].distance_to(target["pos"]) < (43.0 if hero["weapon"] == "fire" else 14.0):
						damage_ally(ally, damage * (0.55 if ally["kind"] == "frost" and hero["weapon"] == "fire" else 1.0))
				hit_fx.append({"pos": target["pos"], "time": 0.20, "color": Color("ffa763")})
			elif hero["pos"].distance_to(player_pos) < 105.0 and dash_time <= 0.0:
				player_hp -= damage * 0.32
			hero["attack_cd"] = maxf(0.43, 0.98 - float(hero["level"] - 1) * 0.07)
		if hero["charm"] and hero["charm_cd"] <= 0.0:
			for ally in allies:
				if ally["lane"] == hero["lane"] and ally["pos"].distance_to(hero["pos"]) < 100.0: damage_ally(ally, 15.0 + hero["level"] * 2.0)
			if hero["pos"].distance_to(player_pos) < 100.0: player_hp -= 3.0
			hero["charm_cd"] = 1.8
			hit_fx.append({"pos": hero["pos"], "time": 0.35, "color": Color(0.9, 0.4, 0.85, 0.45)})
		if hero["bomb"] and hero["bomb_cd"] <= 0.0:
			var center: Vector2 = target["pos"] if not target.is_empty() else player_pos
			for ally in allies:
				if ally["lane"] == hero["lane"] and ally["pos"].distance_to(center) < 86.0: damage_ally(ally, 38.0 + hero["level"] * 4.0)
			if player_pos.distance_to(center) < 86.0 and dash_time <= 0.0: player_hp -= 9.0
			hero["bomb_cd"] = 5.5
			hit_fx.append({"pos": center, "time": 0.45, "color": Color(1.0, 0.45, 0.12, 0.65)})
	for i in range(heroes.size() - 1, -1, -1):
		if heroes[i]["hp"] <= 0.0:
			var dead: Dictionary = heroes[i]
			if stage_number <= 1: fallen_heroes.append({"pos": dead["pos"], "name": dead["name"]})
			heroes.remove_at(i)
			gold += dead["bounty"]
			if not player_downed: player_hp = minf(player_max_hp, player_hp + 130.0)
			save_game()
			set_message("%s 격퇴! 금화 %d, 체력 회복!" % [dead["name"], dead["bounty"]], 3.2)

func update_stage1_hero_weapons(hero: Dictionary, target: Dictionary, nearest: float) -> void:
	var levels: Dictionary = hero["weapon_levels"]
	if hero["attack_cd"] <= 0.0:
		if not target.is_empty() and nearest < 105.0:
			for ally in allies:
				if ally["hp"] > 0.0 and ally["pos"].distance_to(target["pos"]) < 22.0:
					damage_ally(ally, 17.0 + levels["blade"] * 5.0)
			hit_fx.append({"pos": target["pos"], "time": 0.24, "color": Color("f3dfad"), "kind": "slash"})
		elif not player_downed and hero["pos"].distance_to(player_pos) < 105.0 and dash_time <= 0.0:
			player_hp -= 8.0 + levels["blade"] * 2.0
			hit_fx.append({"pos": player_pos, "time": 0.18, "color": Color("f3dfad"), "kind": "slash"})
		hero["attack_cd"] = maxf(0.43, 0.92 - levels["blade"] * 0.08)
	if levels["charm"] > 0 and hero["charm_cd"] <= 0.0:
		var charm_radius: float = 85.0 + float(levels["charm"]) * 13.0
		for ally in allies:
			if ally["hp"] > 0.0 and ally["pos"].distance_to(hero["pos"]) < charm_radius:
				damage_ally(ally, 11.0 + levels["charm"] * 5.0)
		if not player_downed and hero["pos"].distance_to(player_pos) < charm_radius: player_hp -= 3.0 + levels["charm"]
		hit_fx.append({"pos": hero["pos"], "time": 0.36, "color": Color("d77edc"), "kind": "charm"})
		hero["charm_cd"] = maxf(1.0, 2.2 - levels["charm"] * 0.3)
	if levels["bomb"] > 0 and hero["bomb_cd"] <= 0.0:
		var center: Vector2 = target["pos"] if not target.is_empty() else hero["pos"] + Vector2(60, 0)
		var radius: float = 66.0 + float(levels["bomb"]) * 10.0
		for ally in allies:
			if ally["hp"] > 0.0 and ally["pos"].distance_to(center) < radius:
				damage_ally(ally, 20.0 + levels["bomb"] * 8.0)
		if not player_downed and player_pos.distance_to(center) < radius and dash_time <= 0.0: player_hp -= 8.0 + levels["bomb"] * 2.0
		hit_fx.append({"pos": center, "time": 0.46, "color": Color("ff8e45"), "kind": "bomb"})
		hero["bomb_cd"] = maxf(3.6, 6.2 - levels["bomb"] * 0.7)

func hero_level_up(hero: Dictionary) -> void:
	hero["level"] += 1
	hero["exp_goal"] += 3
	hero["max_hp"] += 42.0
	hero["hp"] = minf(hero["max_hp"], hero["hp"] + 60.0)
	if stage_number == 1:
		if hero["level"] == 2: give_hero_item(hero, "charm")
		elif hero["level"] == 3: give_hero_item(hero, "bomb")
		else: give_hero_item(hero, "chest")
	else:
		if hero["level"] == 2: give_hero_item(hero, "charm")
		elif hero["level"] == 3: give_hero_item(hero, "bomb")
	set_message("정찰병: %s 레벨 %d, %s 강화!" % [hero["name"], hero["level"], weapon_name(hero["weapon"])], 3.5)

func weapon_name(kind: String) -> String:
	match kind:
		"fire": return "불의 지팡이"
		"arrow": return "활"
		_: return "검"

func shop_offers() -> Array[Dictionary]:
	return [
		{"id": "hp", "name": "슬라임 심장", "price": 90, "detail": "최대 체력 +60"},
		{"id": "slime_power", "name": "점액 압축낭", "price": 100, "detail": "점액탄 피해 +4"}
	]

func buy_offer(index: int) -> void:
	if state != "camp_shop": return
	var offer: Dictionary = shop_offers()[index]
	var id: String = offer["id"]
	if (id == "hp" and hp_upgrade) or (id == "slime_power" and slime_power_upgrade):
		set_message("이미 가지고 있어.", 2.0)
		return
	if gold < offer["price"]:
		set_message("금화가 부족해.", 2.0)
		return
	gold -= offer["price"]
	match id:
		"hp": hp_upgrade = true
		"slime_power": slime_power_upgrade = true
	save_game()
	set_message("구매 완료: %s" % offer["name"], 2.5)

func lose(reason: String) -> void:
	state = "lost"
	set_message(reason, 10.0)

func _draw() -> void:
	if state == "title":
		draw_title()
		return
	if state == "ending":
		draw_ending()
		return
	if state == "intro" and intro_phase == 0:
		draw_rect(Rect2(Vector2.ZERO, SCREEN), Color.BLACK)
		text_line("아쿠마... 야, 아쿠마! 일어나!", Vector2(440, 390), 25, Color("edf0ed"))
		return
	if state.begins_with("camp") or state == "stage2_briefing":
		draw_camp_scene()
		draw_camp_overlay()
		return
	draw_world_scene()
	if state == "intro": draw_intro_overlay()
	elif state == "card": draw_card()
	elif state == "tutorial": draw_tutorial()
	elif state == "promotion": draw_promotion()
	elif state == "return_cutscene": draw_return_overlay()
	elif state == "battle_end": draw_battle_end()
	elif state == "battle" or state == "prologue_battle": draw_hud()
	elif state == "lost": draw_lost()

func text_line(value: String, pos: Vector2, size: int = 19, tint: Color = Color.WHITE) -> void:
	draw_string(FONT, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, tint)

func box(rect: Rect2, fill: Color = Color("293044")) -> void:
	draw_rect(rect, fill)
	draw_rect(rect, Color("8e9ab0"), false, 2.0)

func draw_camp_scene() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("83bed3"))
	for i in 8:
		var cx := float(i * 191 + 44)
		draw_circle(Vector2(cx, 108 + (i % 3) * 18), 33, Color("e6f4ed"))
		draw_circle(Vector2(cx + 28, 106 + (i % 3) * 18), 24, Color("f2f7ef"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 350), Vector2(150, 112), Vector2(360, 350)]), Color("78959a"))
	draw_colored_polygon(PackedVector2Array([Vector2(210, 360), Vector2(475, 62), Vector2(735, 360)]), Color("668a90"))
	draw_colored_polygon(PackedVector2Array([Vector2(600, 358), Vector2(872, 87), Vector2(1100, 358)]), Color("71969c"))
	draw_colored_polygon(PackedVector2Array([Vector2(925, 357), Vector2(1135, 135), Vector2(1280, 350)]), Color("5d7f83"))
	draw_colored_polygon(PackedVector2Array([Vector2(364, 187), Vector2(475, 62), Vector2(582, 188), Vector2(506, 159), Vector2(479, 183), Vector2(445, 154)]), Color("e4ecdf"))
	draw_colored_polygon(PackedVector2Array([Vector2(768, 192), Vector2(872, 87), Vector2(970, 202), Vector2(894, 174), Vector2(863, 195), Vector2(844, 163)]), Color("e6f1e8"))
	draw_rect(Rect2(0, 322, 1280, 398), Color("648b59"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 610), Vector2(320, 487), Vector2(600, 460), Vector2(760, 465), Vector2(1280, 358), Vector2(1280, 515), Vector2(790, 548), Vector2(550, 553), Vector2(0, 720)]), Color("a49a73"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 642), Vector2(350, 504), Vector2(680, 484), Vector2(820, 480), Vector2(1280, 392), Vector2(1280, 417), Vector2(820, 506), Vector2(630, 512), Vector2(0, 675)]), Color("c2b68c"))
	for i in 85:
		var gx := float((i * 173 + 43) % 1280)
		var gy := float((i * 109 + 17) % 330 + 363)
		draw_rect(Rect2(gx, gy, 3, 7), Color("4c794b"))
		if i % 5 == 0: draw_rect(Rect2(gx + 4, gy + 2, 4, 3), Color("d3cb8b"))
	for i in 8:
		var tx := float(65 + i * 165)
		var ty := float(352 + (i % 2) * 21)
		draw_rect(Rect2(tx, ty, 8, 72), Color("524f3b"))
		draw_colored_polygon(PackedVector2Array([Vector2(tx - 28, ty + 32), Vector2(tx + 4, ty - 42), Vector2(tx + 36, ty + 32)]), Color("385e48"))
		draw_colored_polygon(PackedVector2Array([Vector2(tx - 23, ty + 14), Vector2(tx + 4, ty - 34), Vector2(tx + 31, ty + 14)]), Color("47785a"))
	for i in 5:
		var fx := float(45 + i * 31)
		draw_rect(Rect2(fx, 561, 5, 33), Color("746246"))
		draw_line(Vector2(fx, 567), Vector2(fx + 31, 562), Color("8c7958"), 4)
		draw_line(Vector2(fx, 584), Vector2(fx + 31, 579), Color("8c7958"), 4)
	# Forge and merchant on the left.
	draw_rect(Rect2(238, 357, 220, 137), Color("735c47"))
	draw_colored_polygon(PackedVector2Array([Vector2(217, 364), Vector2(351, 300), Vector2(480, 364)]), Color("504d48"))
	draw_rect(Rect2(278, 405, 57, 89), Color("30383c"))
	draw_rect(Rect2(361, 405, 58, 46), Color("c8a76e"))
	draw_rect(Rect2(368, 413, 44, 30), Color("515a51"))
	draw_circle(Vector2(170, 488), 28, Color("473b33"))
	draw_circle(Vector2(170, 480), 19, Color("dc8847"))
	draw_circle(Vector2(170, 470), 11, Color("f7c76a"))
	draw_colored_polygon(PackedVector2Array([Vector2(515, 385), Vector2(563, 333), Vector2(622, 386)]), Color("b7a47f"))
	draw_rect(Rect2(518, 385, 104, 20), Color("8b765d"))
	draw_rect(Rect2(563, 365, 7, 40), Color("514c40"))
	draw_rect(Rect2(744, 477, 42, 28), Color("866849"))
	draw_rect(Rect2(746, 479, 38, 5), Color("c59d5d"))
	draw_rect(Rect2(791, 470, 31, 24), Color("755d46"))
	text_line("장비점", Vector2(302, 354), 17, Color("fff0c1"))
	# Guild hut, gate and watch post.
	draw_rect(Rect2(911, 345, 206, 149), Color("6f6653"))
	draw_colored_polygon(PackedVector2Array([Vector2(887, 356), Vector2(1010, 286), Vector2(1138, 356)]), Color("424b43"))
	draw_rect(Rect2(990, 415, 50, 79), Color("31383a"))
	draw_rect(Rect2(986, 413, 4, 81), Color("a69166"))
	draw_rect(Rect2(1040, 413, 4, 81), Color("a69166"))
	text_line("길드", Vector2(990, 346), 17, Color("fff0c1"))
	draw_rect(Rect2(1166, 358, 9, 110), Color("614b39"))
	draw_rect(Rect2(1152, 348, 98, 34), Color("51483e"))
	text_line("출정로 →", Vector2(1160, 372), 15, Color("fff0c1"))
	# Single supply chest; its opened lid remains visible after a claim.
	var chest_open := opened_chest_stages.has(camp_stage)
	draw_rect(Rect2(676, 428, 49, 30), Color("5d392e"))
	draw_rect(Rect2(680, 432, 41, 23), Color("a87943"))
	draw_rect(Rect2(695, 430, 10, 25), Color("dfc671"))
	if chest_open: draw_rect(Rect2(674, 414, 50, 9), Color("987846"))
	else: draw_rect(Rect2(676, 421, 49, 11), Color("795332"))
	text_line("보급 상자", Vector2(656, 406), 15, Color("fff0c1"))
	draw_character(Vector2(554, 419), "commander", 0.0)
	draw_character(Vector2(606, 455), "friend", 0.0)
	draw_character(Vector2(968, 474), "goblin", 0.0)
	draw_character(camp_pos, "slime", Time.get_ticks_msec() * 0.001)
	box(Rect2(16, 14, 442, 74), Color(0.08, 0.15, 0.18, 0.88))
	text_line("진영  ·  %d스테이지 귀환" % camp_stage, Vector2(32, 44), 20, Color("f5d58a"))
	text_line("금화 %d     WASD 이동  ·  시설 앞 E" % gold, Vector2(32, 71), 16)
	if state == "camp" and message_time > 0.0:
		box(Rect2(195, 605, 890, 80), Color(0.09, 0.16, 0.19, 0.95))
		text_line(message, Vector2(218, 653), 19)

func draw_camp_overlay() -> void:
	if state == "camp": return
	if state == "camp_event":
		var line: Dictionary = camp_event_lines[camp_event_index]
		dialogue(line["speaker"], line["line"], line["portrait"], "Enter 계속")
		return
	if state == "camp_guard":
		var guard_lines: Array[Dictionary] = [
			{"speaker": "문지기", "line": "멈춰라. 이 문은 지휘관의 계약 구역이다.", "portrait": "goblin"},
			{"speaker": "아쿠마", "line": "분대 계약서를 볼 수는 없습니까?", "portrait": "slime"},
			{"speaker": "문지기", "line": "지금은 안 된다. 계급장을 받아 오면 내가 문을 열겠다.", "portrait": "goblin"}
		]
		var guard_line: Dictionary = guard_lines[guard_index]
		dialogue(guard_line["speaker"], guard_line["line"], guard_line["portrait"], "Enter 계속")
		return
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.02, 0.04, 0.05, 0.62))
	if state == "camp_reward":
		box(Rect2(300, 191, 680, 333), Color("31474a"))
		text_line("보급 상자 개봉", Vector2(503, 257), 30, Color("f5d58a"))
		text_line(camp_chest_result, Vector2(408, 360), 24)
		text_line("이번 전투의 보급품은 하나뿐이다.", Vector2(432, 421), 18)
		text_line("Enter 닫기", Vector2(799, 488), 17)
	elif state == "camp_shop": draw_shop()
	elif state == "camp_guild":
		box(Rect2(220, 115, 840, 500), Color("303f48"))
		text_line("길드 · 분대 계약   금화 %d" % gold, Vector2(355, 171), 28, Color("f5d58a"))
		text_line("1  냉동 분대 계약   70금화%s" % ("  [계약됨]" if frost_hired else ""), Vector2(300, 266), 22)
		text_line("2  해골 대장 분대 계약   145금화%s" % ("  [계약됨]" if captain_hired else ""), Vector2(300, 340), 22)
		text_line("계약한 분대는 지휘관 전투에서 선택할 수 있다.", Vector2(300, 433), 18)
		text_line("Enter 닫기", Vector2(860, 564), 18)
	elif state == "stage2_briefing":
		box(Rect2(170, 135, 940, 450), Color("303f48"))
		var brief: Array[String] = ["두 접근로에 영웅이 한 명씩 있다.|직접 걸어서 전선을 오가라.", "영웅은 멈추지 않고 도망친다.|보석과 상자도 안전할 때만 줍는다.", "살아 있는 몬스터의 몸에 닿으면 영웅도 다친다.|WASD 이동, 좌클릭 점액탄, Space 회피."]
		draw_portrait("commander", Vector2(225, 211))
		text_line("바츠 · 2스테이지 작전", Vector2(360, 219), 29, Color("f5d58a"))
		var briefing_lines := brief[briefing_index].split("|")
		text_line(briefing_lines[0], Vector2(241, 345), 21)
		text_line(briefing_lines[1], Vector2(241, 397), 21)
		text_line("Enter 계속  %d/3" % (briefing_index + 1), Vector2(826, 537), 18)

func draw_return_overlay() -> void:
	dialogue("바츠", "부상자를 확인했다. 전원 진영으로 돌아간다.", "commander")

func draw_world_scene() -> void:
	var ground := Color("334d43") if stage_number != 2 else Color("3f4b43")
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("152326"))
	draw_set_transform(Vector2(-camera_x, 0))
	draw_rect(Rect2(0, 0, world_width, SCREEN.y), ground)
	draw_rect(Rect2(0, 310, world_width, 185), Color("6c7253"))
	draw_rect(Rect2(0, 322, world_width, 5), Color("8a8c65"))
	draw_rect(Rect2(0, 490, world_width, 4), Color("4d573f"))
	for i in 1300:
		var x := float((i * 191 + 81) % int(world_width))
		var y := float((i * 137 + 61) % 650 + 36)
		var path := y > 315.0 and y < 500.0
		draw_rect(Rect2(x, y, 4 + i % 3, 3), Color("777b59") if path else Color("476f51"))
		if not path and i % 5 == 0:
			draw_rect(Rect2(x + 4, y - 5, 3, 9), Color("78a66e"))
		if not path and i % 13 == 0:
			draw_rect(Rect2(x - 3, y + 2, 10, 5), Color("253c36"))
			draw_rect(Rect2(x, y - 1, 7, 3), Color("63725a"))
		if path and i % 17 == 0:
			draw_rect(Rect2(x - 7, y, 19, 6), Color("858368"))
			draw_rect(Rect2(x - 7, y + 6, 16, 3), Color("555b48"))
		if not path and i % 29 == 0:
			draw_rect(Rect2(x - 8, y - 7, 24, 18), Color("273c34"))
			draw_rect(Rect2(x - 6, y - 9, 19, 14), Color("4d7954"))
			draw_rect(Rect2(x + 1, y - 7, 6, 4), Color("80a669"))
	if stage_number > 1:
		draw_rect(Rect2(1110, 310, 78, 185), Color("5a5d48"))
		draw_rect(Rect2(1110, 295, 78, 15), Color("7d7756"))
	for item in pickups:
		var p: Vector2 = item["pos"]
		if item["kind"] == "gem":
			draw_colored_polygon(PackedVector2Array([p + Vector2(0,-11), p + Vector2(9,0), p + Vector2(0,11), p + Vector2(-9,0)]), Color("192d48"))
			draw_colored_polygon(PackedVector2Array([p + Vector2(0,-8), p + Vector2(6,0), p + Vector2(0,8), p + Vector2(-6,0)]), Color("64e5f6"))
			draw_rect(Rect2(p.x - 2, p.y - 6, 3, 5), Color("e7fcff"))
		elif item["kind"] == "chest":
			draw_rect(Rect2(p.x - 14, p.y - 8, 28, 21), Color("291e31"))
			draw_rect(Rect2(p.x - 11, p.y - 6, 22, 16), Color("986039"))
			draw_rect(Rect2(p.x - 11, p.y - 6, 22, 5), Color("e4b75b"))
			draw_rect(Rect2(p.x - 2, p.y - 4, 5, 10), Color("fff0a5"))
		else:
			draw_circle(p, 11, Color("d68bd9") if item["kind"] == "charm" else Color("e8784d"))
	if state == "intro" or state == "card" or state == "tutorial":
		draw_intro_cast()
	else:
		for ally in allies:
			if ally["downed"]:
				draw_downed_character(ally["pos"], ally["kind"])
				continue
			if ally["hp"] <= 0.0: continue
			draw_character(ally["pos"], ally["kind"], elapsed)
			if ally["controlled"]: draw_circle(ally["pos"] + Vector2(0, 23), 4, Color("f8d36a"))
			if ally["kind"] == "friend": text_line("말록", ally["pos"] + Vector2(-20, -35), 14)
			if ally["kind"] == "commander": text_line("바츠", ally["pos"] + Vector2(-21, -67), 14, Color("f4d58b"))
		for fallen in fallen_heroes:
			draw_downed_character(fallen["pos"], "hero")
		for hero in heroes:
			if hero["hp"] <= 0.0: continue
			draw_character(hero["pos"], "hero_" + hero["weapon"], elapsed)
			if hero["shield"] > 0:
				draw_arc(hero["pos"] + Vector2(0, -9), 29.0, 0.0, TAU, 24, Color("9bdcf5"), 3.0)
			bar(hero["pos"] + Vector2(-36, -45), 72.0, hero["hp"] / hero["max_hp"], Color("e96e66"))
			var equipment := "Lv%d 검%d" % [hero["level"], hero["weapon_levels"]["blade"]] if stage_number == 1 else "Lv%d %s" % [hero["level"], weapon_name(hero["weapon"])]
			text_line("%s%s%s" % [equipment, " · 매혹구%d" % hero["weapon_levels"]["charm"] if stage_number == 1 and hero["charm"] else (" · 매혹구" if hero["charm"] else ""), " · 폭탄%d" % hero["weapon_levels"]["bomb"] if stage_number == 1 and hero["bomb"] else (" · 폭탄" if hero["bomb"] else "")], hero["pos"] + Vector2(-52, -57), 13)
			if hero["charm"]:
				var orb_count: int = hero["weapon_levels"]["charm"] if stage_number == 1 else 1
				for orb in orb_count:
					var angle: float = elapsed * 3.5 + TAU * float(orb) / float(orb_count)
					var orb_p: Vector2 = hero["pos"] + Vector2(cos(angle), sin(angle)) * 35.0
					draw_circle(orb_p, 8, Color("452653"))
					draw_circle(orb_p, 5, Color("f1a7e5"))
			bar(hero["pos"] + Vector2(-28, -38), 56.0, float(hero["exp"]) / float(hero["exp_goal"]), Color("5ddcf0"))
		for fx in hit_fx:
			if fx.get("kind", "") == "slash":
				draw_arc(fx["pos"], 31.0, -1.25, 1.55, 18, fx["color"], 6.0)
			elif fx.get("kind", "") == "bomb":
				draw_circle(fx["pos"], 18.0 + fx["time"] * 120.0, fx["color"])
				draw_circle(fx["pos"], 8.0 + fx["time"] * 32.0, Color("ffe0a1"))
			else:
				draw_circle(fx["pos"], 12.0 + fx["time"] * 50.0, fx["color"])
		for shot in slime_shots:
			var p: Vector2 = shot["pos"]
			draw_line(p - shot["vel"].normalized() * 18.0, p, Color("3c9c72"), 7.0)
			draw_circle(p, 10.0, Color("20493e"))
			draw_circle(p, 7.0, Color("7ee6a2"))
			draw_circle(p + Vector2(-2, -3), 2.0, Color("d3ffd4"))
		if player_downed: draw_downed_character(player_pos, "slime")
		else:
			draw_character(player_pos, "slime", elapsed)
			draw_player_health()
	draw_set_transform(Vector2.ZERO)

func draw_intro_cast() -> void:
	for ally in allies:
		draw_character(ally["pos"], "defender", phase_time)
	draw_character(player_pos, "slime", phase_time)
	draw_character(friend_pos, "friend", phase_time)
	draw_character(commander_pos, "commander", phase_time)
	if intro_phase >= 6:
		draw_character(runner_pos, "runner", phase_time)
	if intro_phase >= 7:
		draw_character(Vector2(2040, 390), "hero", phase_time)
	if intro_phase >= 5 and intro_phase <= 6:
		for ally in allies:
			draw_line(ally["pos"] + Vector2(-9, -22), ally["pos"] + Vector2(-6, -34), Color("d3c1a1"), 3)

func draw_downed_character(pos: Vector2, kind: String) -> void:
	var outline := Color("283039")
	var body := Color("78bb8a") if kind == "slime" else (Color("d9d3c3") if kind == "friend" else (Color("4f7080") if kind == "commander" else Color("bd7768")))
	draw_rect(Rect2(pos.x - 28, pos.y + 3, 57, 8), Color(0.10, 0.14, 0.15, 0.65))
	draw_rect(Rect2(pos.x - 24, pos.y - 3, 49, 13), outline)
	draw_rect(Rect2(pos.x - 20, pos.y - 4, 40, 10), body)
	draw_rect(Rect2(pos.x + 12, pos.y - 7, 9, 9), body.lightened(0.2))
	if kind == "commander": draw_rect(Rect2(pos.x - 28, pos.y - 4, 15, 7), Color("b6964e"))

func draw_character(pos: Vector2, kind: String, animation_time: float) -> void:
	var sway := sin(animation_time * 9.0 + pos.x * 0.02) * 2.0
	draw_rect(Rect2(pos.x - 17, pos.y + 15, 36, 6), Color(0.10, 0.16, 0.15, 0.55))
	if kind == "slime":
		draw_rect(Rect2(pos.x - 19, pos.y - 14 + sway, 38, 31), Color("203b3b"))
		draw_rect(Rect2(pos.x - 17, pos.y - 13 + sway, 34, 29), Color("76d48b"))
		draw_rect(Rect2(pos.x - 11, pos.y - 18 + sway, 23, 9), Color("a3edaa"))
		draw_rect(Rect2(pos.x - 13, pos.y - 9 + sway, 8, 5), Color("c4f8bf"))
		draw_rect(Rect2(pos.x + 11, pos.y + 3 + sway, 5, 9), Color("48a978"))
		draw_rect(Rect2(pos.x - 8, pos.y - 3 + sway, 4, 5), Color("182b29"))
		draw_rect(Rect2(pos.x + 5, pos.y - 3 + sway, 4, 5), Color("182b29"))
		if stage_number >= 4: draw_rect(Rect2(pos.x - 7, pos.y - 25 + sway, 14, 5), Color("eac768"))
	elif kind == "friend" or kind == "skeleton" or kind == "captain":
		var bone := Color("f0e6d0") if kind != "captain" else Color("e5cc8f")
		draw_rect(Rect2(pos.x - 14, pos.y - 27 + sway, 29, 25), Color("3b3b3c"))
		draw_rect(Rect2(pos.x - 12, pos.y - 25 + sway, 25, 21), bone)
		draw_rect(Rect2(pos.x - 8, pos.y - 3 + sway, 17, 18), bone)
		draw_rect(Rect2(pos.x - 5, pos.y, 11, 4), Color("585158"))
		draw_rect(Rect2(pos.x - 14, pos.y + 11 + sway, 9, 5), Color("d7cbbb"))
		draw_rect(Rect2(pos.x + 7, pos.y + 11 + sway, 9, 5), Color("d7cbbb"))
		draw_rect(Rect2(pos.x - 7, pos.y - 18 + sway, 4, 5), Color("28303c"))
		draw_rect(Rect2(pos.x + 4, pos.y - 18 + sway, 4, 5), Color("28303c"))
		if kind == "captain":
			draw_rect(Rect2(pos.x - 16, pos.y - 31 + sway, 33, 7), Color("bd9d52"))
			draw_rect(Rect2(pos.x + 14, pos.y - 8 + sway, 8, 20), Color("a07543"))
		elif kind == "friend":
			draw_rect(Rect2(pos.x - 15, pos.y - 29 + sway, 30, 7), Color("526889"))
			draw_rect(Rect2(pos.x + 10, pos.y - 5 + sway, 6, 14), Color("526889"))
		else:
			draw_rect(Rect2(pos.x - 4, pos.y - 4 + sway, 8, 14), Color("8d8278"))
	elif kind.begins_with("hero"):
		var armor := Color("b7795f") if kind == "hero_fire" else (Color("778a70") if kind == "hero_arrow" else Color("ce6b59"))
		draw_rect(Rect2(pos.x - 18, pos.y + 7 + sway, 37, 7), Color("202b2d"))
		draw_rect(Rect2(pos.x - 19, pos.y - 29 + sway, 38, 12), Color("5c4a68"))
		draw_rect(Rect2(pos.x - 13, pos.y - 25 + sway, 26, 35), armor)
		draw_rect(Rect2(pos.x - 9, pos.y - 34 + sway, 19, 14), Color("efc9a0"))
		draw_rect(Rect2(pos.x - 10, pos.y - 38 + sway, 20, 7), Color("594344"))
		draw_rect(Rect2(pos.x - 8, pos.y - 18 + sway, 5, 4), Color("dce3ef"))
		draw_rect(Rect2(pos.x + 4, pos.y - 18 + sway, 5, 4), Color("dce3ef"))
		draw_rect(Rect2(pos.x - 16, pos.y + 6 + sway, 10, 7), Color("433b48"))
		draw_rect(Rect2(pos.x + 6, pos.y + 6 + sway, 10, 7), Color("433b48"))
		if kind == "hero_fire":
			draw_line(pos + Vector2(18, -31), pos + Vector2(22, 15), Color("8e603f"), 5)
			draw_circle(pos + Vector2(18, -32), 7, Color("f3a45e"))
		elif kind == "hero_arrow":
			draw_arc(pos + Vector2(19, -13), 22, -1.7, 1.7, 15, Color("dbc58d"), 3)
		else:
			draw_line(pos + Vector2(18, -30), pos + Vector2(25, 12), Color("f0e2b0"), 4)
	elif kind == "brute":
		draw_rect(Rect2(pos.x - 23, pos.y - 25 + sway, 46, 40), Color("3e2d46"))
		draw_rect(Rect2(pos.x - 20, pos.y - 31 + sway, 40, 41), Color("9e6aab"))
		draw_rect(Rect2(pos.x - 24, pos.y - 39 + sway, 13, 13), Color("ead8bb"))
		draw_rect(Rect2(pos.x + 11, pos.y - 39 + sway, 13, 13), Color("ead8bb"))
		draw_rect(Rect2(pos.x - 10, pos.y - 16 + sway, 6, 6), Color("f7da74"))
		draw_rect(Rect2(pos.x + 4, pos.y - 16 + sway, 6, 6), Color("f7da74"))
	elif kind == "runner":
		draw_rect(Rect2(pos.x - 13, pos.y - 10 + sway, 26, 17), Color("a484c0"))
		draw_line(pos + Vector2(-13, -7), pos + Vector2(-27, -20), Color("a484c0"), 5)
		draw_line(pos + Vector2(13, -7), pos + Vector2(27, -20), Color("a484c0"), 5)
	elif kind == "frost":
		draw_rect(Rect2(pos.x - 16, pos.y - 20 + sway, 32, 33), Color("285770"))
		draw_rect(Rect2(pos.x - 14, pos.y - 19 + sway, 28, 31), Color("80d9ed"))
		draw_rect(Rect2(pos.x - 7, pos.y - 26 + sway, 15, 9), Color("c9f6fa"))
		draw_rect(Rect2(pos.x - 10, pos.y - 8 + sway, 7, 5), Color("eefaff"))
		draw_rect(Rect2(pos.x + 5, pos.y + 5 + sway, 7, 5), Color("5caecf"))
	elif kind == "commander":
		draw_rect(Rect2(pos.x - 29, pos.y - 39 + sway, 59, 58), Color("263445"))
		draw_rect(Rect2(pos.x - 25, pos.y - 44 + sway, 50, 54), Color("4c6670"))
		draw_rect(Rect2(pos.x - 32, pos.y - 35 + sway, 19, 30), Color("75858b"))
		draw_rect(Rect2(pos.x + 13, pos.y - 35 + sway, 19, 30), Color("75858b"))
		draw_rect(Rect2(pos.x - 22, pos.y - 48 + sway, 44, 22), Color("3b704d"))
		draw_rect(Rect2(pos.x - 27, pos.y - 53 + sway, 54, 10), Color("b69751"))
		draw_rect(Rect2(pos.x - 13, pos.y - 41 + sway, 8, 7), Color("f3dd9f"))
		draw_rect(Rect2(pos.x + 6, pos.y - 41 + sway, 8, 7), Color("f3dd9f"))
		draw_rect(Rect2(pos.x - 14, pos.y - 12 + sway, 29, 9), Color("a69057"))
		draw_rect(Rect2(pos.x - 27, pos.y + 4 + sway, 20, 15), Color("34454e"))
		draw_rect(Rect2(pos.x + 8, pos.y + 4 + sway, 20, 15), Color("34454e"))
		draw_rect(Rect2(pos.x + 32, pos.y - 47 + sway, 6, 68), Color("c7c0a1"))
		draw_rect(Rect2(pos.x + 25, pos.y - 49 + sway, 20, 8), Color("e0b968"))
	else:
		var variant := int(pos.x / 31.0) % 3
		var fill := Color("8cc26e") if variant == 0 else (Color("73ae84") if variant == 1 else Color("b1bb79"))
		draw_rect(Rect2(pos.x - 14, pos.y - 23 + sway, 28, 36), Color("29463a"))
		draw_rect(Rect2(pos.x - 12, pos.y - 21 + sway, 24, 32), fill)
		draw_rect(Rect2(pos.x - 16, pos.y - 29 + sway, 32, 9), Color("3b6149"))
		draw_rect(Rect2(pos.x - 9, pos.y + 7 + sway, 7, 5), Color("527755"))
		draw_rect(Rect2(pos.x + 5, pos.y + 7 + sway, 7, 5), Color("527755"))
		draw_rect(Rect2(pos.x - 7, pos.y - 13 + sway, 4, 4), Color("1d2b23"))
		draw_rect(Rect2(pos.x + 4, pos.y - 13 + sway, 4, 4), Color("1d2b23"))
		draw_rect(Rect2(pos.x - 18, pos.y - 22 + sway, 6, 10), fill.darkened(0.25))
		draw_rect(Rect2(pos.x + 12, pos.y - 22 + sway, 6, 10), fill.darkened(0.25))

func draw_player_health() -> void:
	bar(player_pos + Vector2(-23, -39), 46.0, player_hp / player_max_hp, Color("75e3a4"))

func bar(pos: Vector2, width: float, ratio: float, tint: Color) -> void:
	draw_rect(Rect2(pos, Vector2(width, 6)), Color("222732"))
	draw_rect(Rect2(pos, Vector2(width * clampf(ratio, 0.0, 1.0), 6)), tint)

func draw_portrait(kind: String, pos: Vector2) -> void:
	box(Rect2(pos, Vector2(86, 86)), Color("38465a"))
	draw_character(pos + Vector2(43, 58), kind, 0.0)

func dialogue(speaker: String, line: String, portrait: String, hint: String = "") -> void:
	box(Rect2(145, 545, 990, 135), Color(0.12, 0.16, 0.22, 0.96))
	draw_portrait(portrait, Vector2(162, 566))
	text_line(speaker, Vector2(270, 586), 18, Color("f5d58a"))
	text_line(line, Vector2(270, 623), 21)
	if not hint.is_empty(): text_line(hint, Vector2(922, 654), 14, Color("c5d4d5"))

func draw_intro_overlay() -> void:
	if intro_phase == 1:
		draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0, 0, 0, clampf(1.0 - phase_time / 1.8, 0.0, 1.0)))
		dialogue("말록", "야, 아쿠마! 일어나. 바츠 지휘관이 널 찾고 있어.", "friend")
	elif intro_phase == 2:
		dialogue("아쿠마", "정문 근무는 아니겠지? ...왜 대답을 안 해?", "slime")
	elif intro_phase == 3:
		dialogue("바츠", "영웅이 이 길로 온다. 앞에서 시선을 끌고 옆을 포위한다.", "commander")
	elif intro_phase == 4:
		dialogue("바츠", "오늘은 꼭 이겨야 한다! 다들 준비해!", "commander")
	elif intro_phase == 5:
		dialogue("말록", "방패선이 움직인다. 아쿠마, 내 뒤를 따라와.", "friend")
	elif intro_phase == 6:
		dialogue("정찰 박쥐", "지휘관님! 영웅이 오고 있습니다!", "runner")
	elif intro_phase == 7:
		dialogue("바츠", "전원, 앞으로!", "commander")

func draw_card() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.02, 0.04, 0.07, 0.75))
	box(Rect2(260, 122, 760, 460), Color("303b4c"))
	var title := ""
	var lines: Array[String] = []
	var portrait := "slime"
	match card_kind:
		"slime":
			title = "아쿠마 | 말단 슬라임"
			lines = ["직책: 정문 근처의 신입 부하", "특기: 점액탄으로 적의 접근을 끊는다.", "목표: 말록과 함께 영웅을 저지한다."]
		"friend":
			title = "말록 | 해골 병사"
			lines = ["아쿠마의 친구이자 선배 해골 병사.", "정문 방어선을 지켜 온 숙련된 전투원.", "친구가 쓰러지면 가장 먼저 그 자리를 지킨다."]
			portrait = "friend"
		"commander":
			title = "바츠 | 전선 지휘관"
			lines = ["중갑을 입은 정문 방어선의 지휘관.", "긴 창으로 전열의 앞을 직접 지킨다.", "영웅의 30분 생존을 반드시 저지하려 한다."]
			portrait = "commander"
	draw_portrait(portrait, Vector2(316, 168))
	text_line(title, Vector2(425, 205), 28, Color("f5d58a"))
	for i in lines.size():
		text_line(lines[i], Vector2(322, 315 + i * 57), 22)
	text_line("Enter  계속", Vector2(831, 537), 18, Color("c8dfca"))

func draw_tutorial() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.02, 0.04, 0.07, 0.72))
	box(Rect2(250, 140, 780, 435), Color("303b4c"))
	text_line("첫 전투: 친구들과 함께 영웅을 막아라", Vector2(305, 209), 27, Color("f5d58a"))
	text_line("WASD  이동", Vector2(328, 284), 23)
	text_line("좌클릭  커서 방향으로 점액탄 발사", Vector2(328, 337), 23)
	text_line("Space  짧은 회피", Vector2(328, 390), 23)
	text_line("영웅은 도망친다. 몸으로 막아도 피해를 준다.", Vector2(328, 447), 19)
	text_line("말록과 바츠도 함께 싸운다.", Vector2(328, 481), 18)
	text_line("Enter  전투 시작", Vector2(815, 528), 18, Color("c8dfca"))

func draw_battle_end() -> void:
	box(Rect2(180, 545, 920, 130), Color(0.11, 0.16, 0.22, 0.95))
	text_line("전투 종료" if end_victory else "전선 철수", Vector2(210, 579), 21, Color("f5d58a"))
	text_line(end_reason, Vector2(210, 617), 20)
	if phase_time < 1.2: text_line("쓰러진 대원들을 확인하는 중...", Vector2(710, 650), 15)
	else: text_line("아쿠마·말록·바츠가 다시 일어났다.  Enter 계속", Vector2(622, 650), 15, Color("b9d9c8"))

func draw_promotion() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.03, 0.04, 0.08, 0.7))
	box(Rect2(280, 175, 720, 360), Color("303b4c"))
	text_line("3스테이지 승리! 지휘관으로 승진", Vector2(355, 246), 30, Color("f5d58a"))
	text_line("바츠: 세 전선을 지켰다. 이제 네 분대를 맡아라.", Vector2(326, 329), 21)
	text_line("아쿠마: 명령 확인했습니다.", Vector2(415, 384), 22)
	text_line("먼저 진영 길드에서 분대 계약을 확인한다.", Vector2(337, 448), 18, Color("c8dfca"))
	text_line("Enter  진영으로", Vector2(777, 497), 18)

func draw_hud() -> void:
	box(Rect2(18, 15, 417, 96), Color(0.10, 0.15, 0.18, 0.9))
	text_line("%s   시간 %02d:%02d" % [("프롤로그" if stage_number == 0 else "%d스테이지" % stage_number), int(elapsed) / 60, int(elapsed) % 60], Vector2(35, 47), 18, Color("f5d58a"))
	text_line("아쿠마 %s   금화 %d" % ["쓰러짐" if player_downed else "%d/%d" % [int(player_hp), int(player_max_hp)], gold], Vector2(35, 79), 18)
	box(Rect2(827, 15, 433, 87), Color(0.10, 0.15, 0.18, 0.9))
	text_line("영웅 목표: 30분 생존  |  남은 영웅 %d" % (heroes.size() + pending_heroes.size()), Vector2(844, 47), 17, Color("f3cf91"))
	text_line("아쿠마: %s  |  Space 회피" % ("지휘관" if stage_number == 4 else "부하"), Vector2(844, 79), 17)
	if stage_number == 4: draw_command_panel()
	elif stage_number > 0:
		text_line("아쿠마 쓰러짐: 동료들이 전투를 이어가는 중" if player_downed else "WASD 이동  ·  좌클릭 점액탄  ·  Space 회피", Vector2(31, 611), 17, Color("dcebd5"))
	if stage_number == 1 and not heroes.is_empty():
		var levels: Dictionary = heroes[0]["weapon_levels"]
		text_line("영웅 무장  검 %d  |  매혹구 %d  |  폭탄 %d" % [levels["blade"], levels["charm"], levels["bomb"]], Vector2(835, 137), 16, Color("f3d7ab"))
	if message_time > 0.0:
		box(Rect2(193, 536 if stage_number == 4 else 637, 895, 58), Color(0.10, 0.14, 0.20, 0.92))
		text_line(message, Vector2(210, 573 if stage_number == 4 else 674), 19)

func draw_command_panel() -> void:
	box(Rect2(0, 605, 1280, 115), Color("182c37"))
	box(Rect2(15, 617, 170, 88), Color("1d3536"))
	text_line("전장", Vector2(26, 640), 14, Color("d2d9b1"))
	for hero in heroes:
		var mini_x: float = 27.0 + hero["pos"].x / world_width * 145.0
		draw_rect(Rect2(mini_x, 653 + hero["lane"] * 21, 7, 7), Color("f18771"))
	for ally in allies:
		if int(ally["pos"].x) % 3 == 0:
			draw_rect(Rect2(27 + ally["pos"].x / world_width * 145.0, 653 + ally["lane"] * 21, 3, 3), Color("95d695"))
	text_line("마력 %d" % int(mana), Vector2(205, 646), 17, Color("d3beee"))
	text_line("지휘 %d/%d" % [controlled_count(), command_cap()], Vector2(205, 676), 17)
	var ids := ["goblin", "frost", "captain"]
	for i in ids.size():
		var id: String = ids[i]
		var owned: bool = id == "goblin" or (id == "frost" and frost_hired) or (id == "captain" and captain_hired)
		var p := Vector2(470 + i * 125, 617)
		box(Rect2(p, Vector2(113, 87)), Color("526b5e") if equipped_squad == id else Color("283c45"))
		draw_character(p + Vector2(26, 48), "goblin" if id == "goblin" else ("frost" if id == "frost" else "captain"), 0.0)
		text_line("%d %s" % [i + 1, "고블린" if id == "goblin" else ("냉동" if id == "frost" else "해골")], p + Vector2(51, 36), 14, Color.WHITE if owned else Color("777f82"))
		text_line("%d마력" % int(SQUADS[id]["cost"]), p + Vector2(51, 62), 13)
	box(Rect2(867, 617, 398, 87), Color("243842"))
	text_line("선택: %s" % SQUADS[equipped_squad]["name"], Vector2(883, 646), 16, Color("f6db96"))
	text_line("클릭/1~3 선택   R 전선 진입   Space 회피", Vector2(883, 676), 15)

func draw_title() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("182a2c"))
	draw_character(Vector2(640, 310), "slime", 0.0)
	text_line("아쿠마의 마왕 출세기", Vector2(423, 178), 35, Color("f5d58a"))
	text_line("Enter  이어하기", Vector2(515, 450), 25)
	text_line("N  새 이야기", Vector2(530, 505), 23)
	text_line("기존 저장은 보존됩니다.", Vector2(510, 606), 17, Color("b8c9c6"))

func draw_shop() -> void:
	box(Rect2(205, 107, 870, 510), Color("293a43"))
	text_line("진영 장비점   금화 %d" % gold, Vector2(420, 172), 29, Color("f5d58a"))
	var offers := shop_offers()
	for i in offers.size():
		var offer: Dictionary = offers[i]
		box(Rect2(265, 226 + i * 100, 750, 82), Color("435363"))
		var owned: bool = (offer["id"] == "hp" and hp_upgrade) or (offer["id"] == "slime_power" and slime_power_upgrade)
		text_line("%d  %s   %d금화%s" % [i + 1, offer["name"], offer["price"], " [보유]" if owned else ""], Vector2(292, 262 + i * 100), 20)
		text_line(offer["detail"], Vector2(292, 289 + i * 100), 16)
	text_line("분대 계약서는 길드에서만 취급한다.", Vector2(303, 496), 18)
	text_line("1/2 구매   Enter 닫기", Vector2(740, 565), 18, Color("f5d58a"))
	if message_time > 0.0: text_line(message, Vector2(285, 600), 16)

func draw_lost() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color(0.16, 0.04, 0.05, 0.72))
	box(Rect2(310, 230, 660, 280), Color("402d38"))
	text_line("방어 실패", Vector2(543, 301), 35, Color("f3aaa4"))
	text_line(message, Vector2(385, 369), 20)
	text_line("Enter  전투 재도전", Vector2(690, 464), 18)

func draw_ending() -> void:
	draw_rect(Rect2(Vector2.ZERO, SCREEN), Color("1a3032"))
	text_line("지휘관 전투 클리어!", Vector2(445, 202), 35, Color("f5d58a"))
	text_line("말록: 아쿠마, 다음 전선도 함께 간다.", Vector2(360, 317), 22)
	text_line("아쿠마: 모두 살아 돌아오게 할 거야.", Vector2(390, 372), 22)
	text_line("Enter  제목으로", Vector2(540, 543), 19)
