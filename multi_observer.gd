extends Node2D

const FONT = preload("res://fonts/NanumGothic-Regular.ttf")
const HISTORY_SCENE = preload("res://history_prologue.gd")
const ARENA_SCENE = preload("res://observer.tscn")
const SAVE_PATH := "user://save_chapter_v1.cfg"
const LEGACY_MULTI_SAVE := "user://save_observer_multi_v1.cfg"
const OLD_SAVE := "user://save_observer_v1.cfg"
const META_PATH := "user://save_observer_meta_v1.cfg"
const ARENA_SIZE := Vector2i(860,720)
const SNAP_KEYS := ["state","elapsed","automatic_clock","monsters","gems","hero_chests","effects","traps","next_trap_at","hero","boss","boss_kind","boss_time","boss_attack_cd","boss_dash_cd","boss_dash_time","boss_special_cd","arena_radius","demon_hp_bonus","demon_damage_bonus","elite_unlocked","uid_counter","obstacles","pending_evolutions","evolved","counter_due","counter_opened","last_result","bat_clock","total_damage","rng_state","terrain_seed","biome_id","hero_chest_show","monster_shots","hero_class","monster_level"]
const NAMES := ["그늘진 경계","뼈의 협곡","잿빛 벌판","붉은 관문"]
const REWARD_IDS := ["mana_refill","mana_max","mana_regen","reserve","demon_hp","demon_damage","elite","mini"]
const WEAPON_SHORT := ["검","매혹구","폭탄","번개","화염띠","성광"]
const ITEM_SHORT := ["숫돌","자석","점화핵","축전","망토","렌즈"]
const HERO_CLASSES := ["수호기사","추적 궁수","화염 마도사","성역 사제"]
const HERO_TRAITS := ["튼튼한 체력·방어 / 검","빠른 이동 / 성광 화살","화염·번개 동시 사용","보호막·체력 재생 / 매혹구"]
const REWARD_NAMES := {"mana_refill":"마력 회복","mana_max":"최대 마력","mana_regen":"마력 재생","reserve":"대기열 확장","demon_hp":"악마 체력","demon_damage":"악마 공격","elite":"근위병 해금","mini":"중간보스 출전"}
const CHAPTER_COUNTS := [1,1,2,2,3,3,4,4,4,4]
const CHAPTER_NAMES := ["후손의 첫 전선","박쥐 군단 재건","두 영웅의 동맹","성문 방어선","잊힌 악마의 기록","유산의 문","네 왕국의 반격","악마성 포위","조상의 진실","다블라의 결전"]
const CHAPTER_STORIES := ["조상의 이름은 전장에서 아무 힘도 되지 않는다.","흩어진 박쥐 군단을 다시 모은다.","두 영웅이 서로를 지키기 시작했다.","성문 앞에서 방패와 화살이 맞물린다.","디아블라 시대의 기록이 발견되었다.","오래 봉인된 유산이 영웅의 무장과 반응한다.","네 왕국이 공동 전선을 꾸렸다.","영웅들이 악마성의 사방을 포위한다.","디아블라의 승리에는 알려지지 않은 대가가 있었다.","다블라는 조상의 그림자를 벗어나 자신의 결전을 치른다."]
const CHAPTER_DIALOGUE := [
	["정찰병: 영웅 한 명이 경계에 들어왔습니다.","다블라: 이름만 믿고 나서진 않겠다. 병력을 살펴보자."],
	["정찰병: 박쥐들이 다시 모이고 있습니다.","다블라: 약한 날개도 방향을 맞추면 전선이 된다."],
	["정찰병: 영웅 둘이 서로 신호를 주고받습니다.","다블라: 한쪽만 보면 다른 쪽이 무너진다."],
	["정찰병: 성문에 방패와 궁수가 배치됐습니다.","다블라: 사선을 끊고 방패를 우회하라."],
	["기록관: 디아블라의 시대를 적은 장부입니다.","다블라: 승리의 기록 뒤에 지운 이름들이 있군."],
	["기록관: 봉인이 영웅의 무장에 반응합니다.","다블라: 조상의 힘을 빌리되 그대로 따르진 않겠다."],
	["정찰병: 네 왕국의 깃발이 한꺼번에 보입니다.","다블라: 네 전선을 모두 보고 병력을 나눠라."],
	["정찰병: 악마성의 사방이 포위됐습니다.","다블라: 가장 약한 틈부터 끊는다."],
	["기록관: 디아블라는 승리 뒤 힘을 봉인했습니다.","다블라: 내가 들은 전설에는 그 대가가 없었다."],
	["정찰병: 영웅들이 마지막 공격을 준비합니다.","다블라: 디아블라가 아니라 다블라의 방식으로 끝내겠다."]
]
var arenas: Array = [null,null,null,null]
var views: Array = [null,null,null,null]
var launched: Array[bool] = [false,false,false,false]
var focus := -1
var overview := false
var operation_elapsed := 0.0
var launch_times: Array[float] = [0.0,0.0,0.0,0.0]
var operation_started := false
var operation_complete := false
var mana := 100.0
var mana_max := 100.0
var mana_regen := 2.0
var demon_level := 1
var demon_xp := 0.0
var monster_level := 1
var current_chapter := 1
var selected_chapter := 1
var screen_mode := "history"
var tutorial_page := 0
var tutorial_return := "chapter_select"
var chapter_success := false
var reserve_limit := 3
var unlocked: Array[String] = ["zombie"]
var reserves: Array[Dictionary] = []
var reserve_clock := 0.0
var checkpoint := 0.0
var max_clock := 0.0
var time_marks: Array[int] = []
var hp_marks: Array[int] = []
var events: Array[Dictionary] = []
var current_event: Dictionary = {}
var options: Array[String] = []
var roulette: Dictionary = {}
var pity_normals := 0
var reward_serial := 0
var awarded: Array[String] = []
var meta: Dictionary = {}
var rng := RandomNumberGenerator.new()
var notice := ""
var notice_time := 0.0
var run_id := ""
var payout_done := false
var particle_clock := 0.0
var reward_audio: AudioStreamPlayer
var roster_page := 0
var history_prologue: Node2D

func _ready() -> void:
	rng.randomize()
	reward_audio = AudioStreamPlayer.new()
	add_child(reward_audio)
	var c := ConfigFile.new()
	if c.load(META_PATH) == OK:
		for key in c.get_section_keys("meta"): meta[key] = c.get_value("meta",key)
	if meta.is_empty(): meta = {"hero_hp":0,"hero_armor":0,"hero_weapon":0,"demon_mana":0,"demon_regen":0,"demon_reserve":0,"demon_final":0,"codex":["bat","zombie","rat","crawler","mudling"]}
	meta["unlocked_chapter"] = clampi(int(meta.get("unlocked_chapter",1)),1,10)
	meta["demon_power_xp"] = int(meta.get("demon_power_xp",0))
	meta["demon_currency"] = int(meta.get("demon_currency",0))
	demon_level = calculate_demon_level()
	begin_new_game()
	queue_redraw()

func begin_new_game() -> void:
	if is_instance_valid(history_prologue): return
	operation_started = false
	screen_mode = "history"
	history_prologue = HISTORY_SCENE.new()
	add_child(history_prologue)
	history_prologue.finished.connect(_on_history_finished)
	queue_redraw()

func _on_history_finished() -> void:
	if not is_instance_valid(history_prologue): return
	history_prologue.queue_free()
	history_prologue = null
	selected_chapter = clampi(int(meta.get("selected_chapter",1)),1,int(meta["unlocked_chapter"]))
	if not bool(meta.get("tutorial_seen",false)): open_tutorial("chapter_select")
	else: screen_mode = "chapter_select"
	queue_redraw()

func open_tutorial(return_to: String) -> void:
	tutorial_return = return_to
	tutorial_page = 0
	screen_mode = "tutorial"
	queue_redraw()

func close_tutorial() -> void:
	meta["tutorial_seen"] = true
	save_meta_progress()
	screen_mode = tutorial_return
	queue_redraw()

func save_meta_progress() -> void:
	var c := ConfigFile.new()
	for key in meta.keys(): c.set_value("meta",key,meta[key])
	c.save(META_PATH)

func calculate_demon_level() -> int:
	var score: int = int(meta.get("demon_power_xp",0))
	for key in ["demon_mana","demon_regen","demon_reserve","demon_final"]:
		score += int(meta.get(key,0))*8
	var level := 1
	while level < 99 and score >= 20+10*(level-1):
		score -= 20+10*(level-1)
		level += 1
	return level

func chapter_arena_count() -> int:
	return CHAPTER_COUNTS[clampi(current_chapter-1,0,9)]

func buy_permanent_upgrade(index: int) -> bool:
	var keys := ["demon_mana","demon_regen","demon_reserve","demon_final"]
	if index < 0 or index >= keys.size(): return false
	var key: String = keys[index]
	var level := int(meta.get(key,0))
	var cost := 25+level*20
	if level >= 5 or int(meta["demon_currency"]) < cost: return false
	meta["demon_currency"] = int(meta["demon_currency"])-cost
	meta[key] = level+1
	demon_level = calculate_demon_level()
	save_meta_progress()
	return true

func start_operation(use_schedule: bool = true) -> void:
	current_chapter = selected_chapter
	screen_mode = "battle"
	for i in 4:
		if is_instance_valid(views[i]): views[i].queue_free()
		arenas[i] = null
		views[i] = null
		launched[i] = false
	operation_started = true
	operation_complete = false
	chapter_success = false
	payout_done = false
	run_id = "%d_%d" % [int(Time.get_unix_time_from_system()),rng.randi()]
	operation_elapsed = 0.0
	focus = -1
	overview = false
	mana_max = 100.0+float(meta.get("demon_mana",0))*8.0
	mana = mana_max
	mana_regen = 2.0+float(meta.get("demon_regen",0))*0.18
	reserve_limit = 3+int(meta.get("demon_reserve",0))
	roster_page = 0
	demon_level = calculate_demon_level()
	demon_xp = 0.0
	monster_level = 1
	unlocked = ["zombie"]
	reserves.clear()
	reserve_clock = 0.0
	events.clear()
	current_event.clear()
	roulette.clear()
	awarded.clear()
	time_marks.clear()
	hp_marks.clear()
	pity_normals = 0
	max_clock = 0.0
	if use_schedule:
		make_launch_schedule()
		for i in 4:
			if launch_times[i] <= 0.0:
				launch_arena(i)
	else:
		launch_times = [0.0,1000000000.0,1000000000.0,1000000000.0]
		launch_arena(0)
	save_game()

func make_launch_schedule() -> void:
	var order := [0,1,2,3]
	for i in range(chapter_arena_count()-1,0,-1):
		var j := rng.randi_range(0,i)
		var previous: int = order[i]
		order[i] = order[j]
		order[j] = previous
	launch_times = [1000000000.0,1000000000.0,1000000000.0,1000000000.0]
	launch_times[order[0]] = 0.0
	if chapter_arena_count() >= 2: launch_times[order[1]] = rng.randf_range(0.1,0.9)
	if chapter_arena_count() >= 3: launch_times[order[2]] = rng.randf_range(30.0,120.0)
	if chapter_arena_count() >= 4: launch_times[order[3]] = rng.randf_range(30.0,120.0)

func reference_arena():
	for arena in arenas:
		if arena != null: return arena
	return null

func roster_page_count() -> int:
	return maxi(1,int(ceil(float(unlocked.size())/12.0)))

func squad_card_rect(local_index: int) -> Rect2:
	return Rect2(1212.0+float(local_index%2)*190.0,510.0+float(local_index/2)*54.0,184.0,52.0)

func active_indices() -> Array[int]:
	var result: Array[int] = []
	for i in 4:
		if launched[i]: result.append(i)
	return result

func arena_rect(index: int) -> Rect2:
	var indices := active_indices()
	var slot := indices.find(index)
	if slot < 0: return Rect2()
	match indices.size():
		1: return Rect2(0,0,1200,900)
		2: return Rect2(float(slot)*600.0,0,600,900)
		3:
			if slot == 0: return Rect2(0,0,600,900)
			return Rect2(600,float(slot-1)*450.0,600,450)
	return Rect2(float(slot%2)*600.0,float(slot/2)*450.0,600,450)

func roll_reward_count() -> int:
	var value := rng.randi_range(0,99)
	return 1 if value < 72 else (3 if value < 95 else 5)

func reward_name(id: String) -> String:
	if id.begins_with("counter_"):
		var weapon := id.trim_prefix("counter_")
		var idx: int = reference_arena().WEAPONS.find(weapon)
		return "%s 대응 정예" % reference_arena().TYPES[reference_arena().COUNTERS[idx]]["name"] if idx >= 0 else "대응 정예"
	return String(REWARD_NAMES.get(id,"보급품"))

func reward_color(id: String) -> Color:
	if id == "mini" or id.begins_with("counter_"): return Color("ffdc78")
	if id in ["reserve","demon_hp","demon_damage","elite"]: return Color("91c9f7")
	return Color("b6bbc0")

func change_roster_page(direction: int) -> void:
	roster_page = clampi(roster_page+direction,0,roster_page_count()-1)
	save_game()

func squad_block_reason(id: String) -> String:
	if not operation_started or operation_complete: return "작전이 진행 중이 아닙니다."
	if focus < 0 or focus >= 4: return "먼저 전장 칸을 선택하십시오."
	if not launched[focus]: return "선택한 전장의 영웅이 아직 입장하지 않았습니다."
	if arenas[focus].state not in ["observe","mini","final"]: return "종료된 전장에는 투입할 수 없습니다."
	if not unlocked.has(id) or id == "bat" or not reference_arena().TYPES.has(id): return "이 부대는 예약할 수 없습니다."
	if reserves.size() >= reserve_limit: return "예약 대기열이 가득 찼습니다."
	if mana < float(reference_arena().TYPES[id]["cost"]): return "마력이 부족합니다."
	return ""

func launch_arena(index: int) -> void:
	if index < 0 or index > 3 or launched[index]: return
	var view := SubViewport.new()
	view.size = ARENA_SIZE
	view.disable_3d = true
	view.transparent_bg = false
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(view)
	var arena = ARENA_SCENE.instantiate()
	arena.embedded_mode = true
	arena.manual_control = index == focus
	arena.embedded_monster_cap = 70
	arena.experience_sink = Callable(self,"gain_shared_xp")
	view.add_child(arena)
	arena.meta = meta.duplicate(true)
	if index > 0:
		var profile: Dictionary = meta.get("hero_profiles",{}).get(str(index),{})
		for key in ["hero_hp","hero_armor","hero_weapon"]: arena.meta[key] = profile.get(key,0)
	arena.fresh_run()
	arena.state = "observe"
	arena.hero_class = index
	arena.hero["class"] = index
	arena.biome_id = index
	arena.terrain_seed = rng.randi()
	arena.create_seeded_obstacles(arena.terrain_seed,index)
	arena.hero["max_hp"] *= 1.0+0.055*float(current_chapter-1)
	arena.hero["hp"] = arena.hero["max_hp"]
	arena.hero["level"] = 1+index+int((current_chapter-1)/3)
	arena.hero["xp_goal"] = 6+3*(int(arena.hero["level"])-1)
	arena.monster_level = monster_level
	match index:
		0: arena.hero["max_hp"] *= 1.20; arena.hero["hp"] = arena.hero["max_hp"]; arena.hero["armor_meta"] = int(arena.hero["armor_meta"])+1
		1: arena.hero["blade"] = 0; arena.hero["arrow"] = 1; arena.hero["speed_factor"] = 1.12
		2: arena.hero["blade"] = 0; arena.hero["fire"] = 1; arena.hero["lightning"] = 1; arena.hero["max_hp"] *= 0.88; arena.hero["hp"] = arena.hero["max_hp"]
		3: arena.hero["blade"] = 0; arena.hero["orb"] = 1; arena.hero["shield"] = 2; arena.hero["regen"] = 0.35
	arenas[index] = arena
	views[index] = view
	launched[index] = true
	set_notice("%s 전장 개시" % NAMES[index])

func active_count() -> int:
	var count := 0
	for i in 4:
		if launched[i] and arenas[i].state in ["observe","mini","final"]: count += 1
	return count

func gain_shared_xp(amount: float) -> void:
	var factor: float = [1.0,1.0,1.08,1.14,1.20][active_count()]
	demon_xp += amount*factor
	while monster_level < 30 and demon_xp >= monster_xp_goal():
		demon_xp -= monster_xp_goal()
		monster_level += 1
		mana_max += 5.0
		mana = minf(mana_max,mana+5.0)
		events.append({"kind":"chest","arena":first_active_index(),"id":"monster_level_%d" % monster_level})
		set_notice("군단 레벨 %d · 전리품 룰렛 확보" % monster_level)
	if monster_level >= 30: demon_xp = 0.0

func monster_xp_goal() -> float:
	return 18.0+12.0*float(monster_level-1)+2.0*float((monster_level-1)*(monster_level-1))

func first_active_index() -> int:
	if focus >= 0 and launched[focus]: return focus
	for i in 4:
		if launched[i]: return i
	return 0

func reserve(id: String) -> bool:
	var reason := squad_block_reason(id)
	if not reason.is_empty():
		set_notice(reason)
		return false
	var cost: float = arenas[focus].TYPES[id]["cost"]
	mana -= cost
	reserves.append({"arena":focus,"type":id})
	set_notice("%s 전장: %s 투입 준비" % [NAMES[focus],arenas[focus].TYPES[id]["name"]])
	save_game()
	return true

func _process(delta: float) -> void:
	if history_prologue != null: return
	var dt := minf(delta,0.05)
	particle_clock += dt
	if notice_time > 0.0: notice_time = maxf(0.0,notice_time-dt)
	if operation_started and not operation_complete:
		operation_elapsed += delta
		for i in 4:
			if not launched[i] and operation_elapsed >= launch_times[i]: launch_arena(i)
		mana = minf(mana_max,mana+mana_regen*dt)
		reserve_clock += dt
		if reserve_clock >= 2.4 and not reserves.is_empty():
			reserve_clock = 0.0
			var entry: Dictionary = reserves.pop_front()
			var index: int = entry["arena"]
			if launched[index] and arenas[index].state in ["observe","mini","final"]: arenas[index].spawn_squad(entry["type"])
		for i in 4:
			if not launched[i]: continue
			var arena = arenas[i]
			arena.manual_control = i == focus
			arena.mana = mana
			arena.mana_max = mana_max
			arena.demon_level = monster_level
			arena.demon_xp = demon_xp
			arena.monster_level = monster_level
			if arena.state in ["observe","mini","final"]: arena.update_simulation(dt)
			arena.queue_redraw()
			max_clock = maxf(max_clock,arena.elapsed)
			if not arena.counter_due.is_empty(): collect_counter_due(i)
		check_global_events()
		advance_event(dt)
		if current_event.get("kind","") == "unlock":
			var event_arena: int = int(current_event.get("arena",-1))
			if event_arena >= 0 and launched[event_arena] and arenas[event_arena].state in ["victory","defeat"]:
				while current_event.get("kind","") == "unlock" and not options.is_empty(): choose_unlock(0)
		if all_finished():
			while not current_event.is_empty() or not events.is_empty():
				if current_event.is_empty(): advance_event(0.0)
				if current_event.get("kind","") == "unlock":
					if options.is_empty(): current_event.clear()
					else: choose_unlock(0)
				else:
					finish_roulette()
					close_reward()
			finish_operation()
		checkpoint += dt
		if checkpoint >= 30.0: checkpoint = 0.0; save_game()
	queue_redraw()

func collect_counter_due(index: int) -> void:
	var arena = arenas[index]
	for j in range(arena.counter_due.size()-1,-1,-1):
		var due: Dictionary = arena.counter_due[j]
		if arena.elapsed < float(due["at"]): continue
		arena.counter_due.remove_at(j)
		var weapon: String = due["weapon"]
		if not arena.counter_opened.has(weapon):
			arena.counter_opened.append(weapon)
			var counter_index: int = arena.WEAPONS.find(weapon)
			if counter_index >= 0:
				var elite_id: String = arena.COUNTERS[counter_index]
				if not unlocked.has(elite_id): unlocked.append(elite_id)
				arena.spawn_squad(elite_id)
				set_notice("정찰: %s 등장 · %s" % [arena.TYPES[elite_id]["name"],arena.monster_role(elite_id)])
				save_game()

func check_global_events() -> void:
	for minute in [300,600,900,1200,1500]:
		if max_clock >= minute and not time_marks.has(minute):
			time_marks.append(minute)
			var target := focus
			if target < 0 or not launched[target]:
				for i in 4:
					if launched[i]: target = i; break
			events.append({"kind":"unlock","arena":target,"id":"time_%d" % minute,"picks":1})
			if minute in [600,1200]: events.append({"kind":"chest","arena":target,"id":"time_chest_%d" % minute})
	for threshold in [75,50,25]:
		if hp_marks.has(threshold): continue
		for i in 4:
			if launched[i] and not arenas[i].hero.is_empty() and float(arenas[i].hero["hp"]) <= float(arenas[i].hero["max_hp"])*float(threshold)/100.0:
				hp_marks.append(threshold)
				events.append({"kind":"unlock","arena":i,"id":"hp_%d" % threshold,"picks":2})
				events.append({"kind":"chest","arena":i,"id":"hp_chest_%d" % threshold})
				break

func advance_event(dt: float) -> void:
	if current_event.is_empty() and not events.is_empty():
		current_event = events.pop_front()
		if current_event["kind"] == "unlock":
			options.clear()
			refresh_codex()
			var pool: Array = meta.get("codex",[])
			for id in pool:
				if id != "bat" and not unlocked.has(id) and reference_arena().TYPES.has(id): options.append(id)
			options.shuffle()
			options = options.slice(0,3)
			if options.is_empty(): current_event.clear()
		else: begin_roulette()
		save_game()
	if not roulette.is_empty() and not bool(roulette.get("done",false)):
		roulette["time"] = minf(3.0,float(roulette["time"])+dt)
		if roulette["time"] >= 3.0: finish_roulette()
	elif not roulette.is_empty() and bool(roulette.get("done",false)):
		roulette["hold"] = float(roulette.get("hold",0.0))+dt
		if float(roulette["hold"]) >= 2.5: close_reward()

func begin_roulette() -> void:
	var counter: bool = current_event["kind"] == "counter"
	var count := roll_reward_count()
	var rewards: Array[String] = []
	var special_given := false
	for n in count:
		var id := ""
		if counter and n == 0:
			id = "counter_"+String(current_event["weapon"])
			special_given = true
		else:
			var roll := rng.randi_range(0,99)
			if roll >= 90 and not special_given:
				id = "mini"
				special_given = true
			elif roll >= 55 or pity_normals >= 2:
				id = pick_available(["reserve","demon_hp","demon_damage","elite"])
				pity_normals = 0
			else:
				id = pick_available(["mana_refill","mana_max","mana_regen"])
				pity_normals += 1
		rewards.append(id)
	reward_serial += 1
	roulette = {"rewards":rewards,"reward":rewards[0],"time":0.0,"done":false,"serial":reward_serial,"hold":0.0}
	play_reward_tone(false)

func pick_available(candidates: Array[String]) -> String:
	var valid: Array[String] = []
	for id in candidates:
		if id == "mana_max" and mana_max >= 300.0: continue
		if id == "mana_regen" and mana_regen >= 8.0: continue
		if id == "reserve" and reserve_limit >= 8: continue
		if id == "elite" and reference_arena().elite_unlocked: continue
		if id == "demon_hp" and reference_arena().demon_hp_bonus >= 600.0: continue
		if id == "demon_damage" and reference_arena().demon_damage_bonus >= 80.0: continue
		valid.append(id)
	return valid[rng.randi_range(0,valid.size()-1)] if not valid.is_empty() else "mana_refill"

func refresh_codex() -> void:
	if reference_arena() == null: return
	var found: Array = meta.get("codex",[])
	var seconds: float = float(meta.get("total_seconds",0.0))+max_clock
	var damage: float = float(meta.get("total_damage",0.0))
	for arena in arenas:
		if arena != null: damage += arena.total_damage
	for tier in reference_arena().META_TIERS.size():
		if seconds < float(reference_arena().TIER_MINUTES[tier])*60.0 and damage < float(reference_arena().TIER_DAMAGE[tier]): continue
		for id in reference_arena().META_TIERS[tier]:
			if not found.has(id): found.append(id)
	meta["codex"] = found

func finish_roulette() -> void:
	if roulette.is_empty() or bool(roulette.get("done",false)): return
	var key := "%s_%d" % [run_id,int(roulette["serial"])]
	if not awarded.has(key):
		awarded.append(key)
		var drawn: Array = roulette.get("rewards",[roulette.get("reward","mana_refill")])
		for item in drawn: apply_reward(String(item))
	roulette["done"] = true
	play_reward_tone(true)
	save_game()

func play_reward_tone(finish: bool) -> void:
	if reward_audio == null: return
	var sample_rate := 22050
	var count: int = roulette.get("rewards",[]).size()
	var duration := (0.5+float(count)*0.1) if finish else 3.0
	var bytes := PackedByteArray()
	bytes.resize(int(duration*sample_rate)*2)
	for i in int(duration*sample_rate):
		var t := float(i)/float(sample_rate)
		var pulse := floorf(t*(13.0+12.0*t/3.0))
		var phase := fmod(t*(13.0+12.0*t/3.0),1.0)
		var frequency := (440.0+float(int(pulse)%5)*90.0) if not finish else (523.0+float(count)*35.0+floorf(t*5.0)*95.0)
		var envelope := maxf(0.0,1.0-t/duration) if finish else maxf(0.0,1.0-phase*5.0)
		var value := int(clampf(sin(TAU*frequency*t)*envelope*10000.0,-32767.0,32767.0))
		bytes[i*2] = value & 255
		bytes[i*2+1] = (value >> 8) & 255
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = sample_rate
	sound.data = bytes
	reward_audio.stream = sound
	reward_audio.play()

func apply_reward(id: String) -> void:
	match id:
		"mana_refill": mana = mana_max
		"mana_max": mana_max += 20.0; mana += 20.0
		"mana_regen": mana_regen += 0.3
		"reserve": reserve_limit += 1
		"demon_hp":
			for a in arenas:
				if a != null: a.demon_hp_bonus += 150.0
		"demon_damage":
			for a in arenas:
				if a != null: a.demon_damage_bonus += 15.0
		"elite":
			for a in arenas:
				if a != null: a.elite_unlocked = true
		"mini":
			var a = arenas[int(current_event["arena"])]
			if a != null and a.state == "observe": a.start_boss("mini")
		_:
			if id.begins_with("counter_"):
				var weapon := id.trim_prefix("counter_")
				var counter_index: int = reference_arena().WEAPONS.find(weapon)
				if counter_index >= 0:
					var cid: String = reference_arena().COUNTERS[counter_index]
					if not unlocked.has(cid): unlocked.append(cid)

func choose_unlock(index: int) -> void:
	if current_event.is_empty() or current_event["kind"] != "unlock" or index < 0 or index >= options.size(): return
	var id := options[index]
	if not unlocked.has(id): unlocked.append(id)
	current_event["picks"] = int(current_event["picks"])-1
	options.erase(id)
	if int(current_event["picks"]) <= 0 or options.is_empty(): current_event.clear()
	save_game()

func close_reward() -> void:
	if roulette.is_empty() or not bool(roulette["done"]): return
	current_event.clear()
	roulette.clear()
	save_game()

func all_finished() -> bool:
	for i in 4:
		if launch_times[i] >= 100000000.0: continue
		if not launched[i] or arenas[i].state not in ["victory","defeat"]: return false
	return true

func finish_operation() -> void:
	operation_complete = true
	screen_mode = "result"
	if not payout_done:
		payout_done = true
		var wins := 0
		for arena in arenas:
			if arena != null and arena.state == "victory": wins += 1
		chapter_success = wins >= int(ceil(float(chapter_arena_count())*0.5))
		var best := 0.0
		var others := 0.0
		for i in 4:
			if launched[i]:
				var score := minf(arenas[i].elapsed,1800.0)
				if score > best: others += best; best = score
				else: others += score
		meta["hero_xp"] = int(meta.get("hero_xp",0))+maxi(1,int(ceil((best+others*0.25)/240.0)))
		for key in ["hero_hp","hero_armor","hero_weapon"]:
			var level: int = int(meta.get(key,0))
			var cost: int = 18+level*15
			if int(meta["hero_xp"]) >= cost and level < 6:
				meta["hero_xp"] = int(meta["hero_xp"])-cost
				meta[key] = level+1
				break
		var profiles: Dictionary = meta.get("hero_profiles",{})
		for i in range(1,4):
			if not launched[i]: continue
			var profile: Dictionary = profiles.get(str(i),{"xp":0,"hero_hp":0,"hero_armor":0,"hero_weapon":0})
			profile["xp"] = int(profile.get("xp",0))+maxi(1,int(ceil(arenas[i].elapsed/240.0)))
			for key in ["hero_hp","hero_armor","hero_weapon"]:
				var level: int = int(profile.get(key,0))
				var cost: int = 18+level*15
				if int(profile["xp"]) >= cost and level < 6:
					profile["xp"] = int(profile["xp"])-cost
					profile[key] = level+1
					break
			profiles[str(i)] = profile
		meta["hero_profiles"] = profiles
		meta["total_seconds"] = float(meta.get("total_seconds",0.0))+best+others*0.25
		var damage_total := 0.0
		for arena in arenas:
			if arena != null: damage_total += arena.total_damage
		meta["total_damage"] = float(meta.get("total_damage",0.0))+damage_total
		refresh_codex()
		var best_currency := 0
		var other_currency := 0
		for arena in arenas:
			if arena == null: continue
			var earned := 0
			if arena.elapsed < 1800.0 and float(arena.hero["hp"]) <= 0.0:
				earned = 75+int((1800.0-arena.elapsed)/60.0)*3+mini(60,int(arena.total_damage/80.0))
			else:
				earned = mini(65,15+int(arena.total_damage/150.0))
			if earned > best_currency: other_currency += best_currency; best_currency = earned
			else: other_currency += earned
		meta["demon_currency"] = int(meta.get("demon_currency",0))+best_currency+int(other_currency*0.25)
		meta["demon_power_xp"] = int(meta.get("demon_power_xp",0))+wins*5+mini(12,int(damage_total/2500.0))
		if chapter_success: meta["unlocked_chapter"] = maxi(int(meta["unlocked_chapter"]),mini(10,current_chapter+1))
		selected_chapter = mini(10,current_chapter+1) if chapter_success else current_chapter
		meta["selected_chapter"] = selected_chapter
		demon_level = calculate_demon_level()
		save_meta_progress()
	save_game()

func import_single_run() -> void:
	if not FileAccess.file_exists(OLD_SAVE): return
	start_operation(false)
	var arena = arenas[0]
	arena.load_run()
	if arena.state not in ["observe","mini","final","victory","defeat"]: arena.state = "observe"
	mana = arena.mana
	mana_max = arena.mana_max
	mana_regen = arena.mana_regen
	demon_level = arena.demon_level
	demon_xp = arena.demon_xp
	reserve_limit = arena.reserve_limit
	unlocked.assign(arena.unlocked)
	for id in arena.reserves: reserves.append({"arena":0,"type":id})
	arena.reserves.clear()
	max_clock = arena.elapsed
	time_marks.assign(arena.time_marks)
	hp_marks.assign(arena.hp_marks)
	set_notice("기존 한 판을 첫 전장으로 가져왔다. 원본 저장은 그대로다.")
	save_game()

func set_notice(message: String) -> void:
	notice = message
	notice_time = 3.0

func _unhandled_input(event: InputEvent) -> void:
	if history_prologue != null: return
	if event is InputEventKey and event.pressed and not event.echo:
		if screen_mode == "tutorial":
			if event.keycode == KEY_ESCAPE: close_tutorial()
			elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				tutorial_page += 1
				if tutorial_page >= 5: close_tutorial()
			return
		if event.keycode == KEY_H:
			open_tutorial(screen_mode)
			return
		if screen_mode == "chapter_select":
			if event.keycode == KEY_UP: selected_chapter = maxi(1,selected_chapter-1)
			elif event.keycode == KEY_DOWN: selected_chapter = mini(int(meta["unlocked_chapter"]),selected_chapter+1)
			elif event.keycode >= KEY_1 and event.keycode <= KEY_4: buy_permanent_upgrade(event.keycode-KEY_1)
			elif event.keycode == KEY_ENTER: start_operation()
			elif event.keycode == KEY_L: load_game()
			elif event.keycode == KEY_N: begin_new_game()
			return
		if screen_mode == "result":
			if event.keycode == KEY_ENTER: screen_mode = "chapter_select"; operation_started = false; queue_redraw()
			elif event.keycode == KEY_R: selected_chapter = current_chapter; start_operation()
			return
		if not operation_started:
			if event.keycode == KEY_ENTER: begin_new_game()
			if event.keycode == KEY_I: import_single_run()
			return
		if event.keycode >= KEY_F1 and event.keycode <= KEY_F4:
			focus = event.keycode-KEY_F1
			save_game()
			return
		if event.keycode == KEY_N and operation_complete: begin_new_game(); return
		if event.keycode == KEY_ENTER and not roulette.is_empty():
			if not bool(roulette["done"]): roulette["time"] = 3.0; finish_roulette()
			else: close_reward()
			return
		if not current_event.is_empty() and current_event["kind"] == "unlock":
			if event.keycode in [KEY_1,KEY_2,KEY_3]: choose_unlock(event.keycode-KEY_1)
			return
		if event.keycode == KEY_Q: change_roster_page(-1); return
		if event.keycode == KEY_E: change_roster_page(1); return
		if focus >= 0 and launched[focus] and arenas[focus].state in ["mini","final"]:
			if event.keycode == KEY_J: arenas[focus].boss_attack()
			if event.keycode == KEY_K: arenas[focus].boss_special()
			if event.keycode == KEY_SPACE: arenas[focus].boss_dash()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = event.position
		if screen_mode == "tutorial":
			tutorial_page += 1
			if tutorial_page >= 5: close_tutorial()
			return
		if screen_mode == "chapter_select":
			if p.x < 840.0 and p.y >= 228.0 and p.y < 728.0:
				var candidate := int((p.y-228.0)/50.0)+1
				if candidate <= int(meta["unlocked_chapter"]): selected_chapter = candidate
			elif Rect2(1010,610,420,65).has_point(p): start_operation()
			return
		if screen_mode == "result":
			screen_mode = "chapter_select"
			operation_started = false
			return
		if p.x < 1200.0:
			var next_focus := -1
			for i in active_indices():
				if arena_rect(i).has_point(p): next_focus = i; break
			if next_focus < 0: return
			if next_focus == focus and launched[focus] and arenas[focus].state in ["mini","final"]:
				arenas[focus].boss_attack()
			else:
				focus = next_focus
				save_game()
		elif p.x >= 1200.0 and current_event.get("kind","") == "unlock" and p.y >= 322.0 and p.y < 470.0:
			choose_unlock(int((p.y-330.0)/45.0))
		elif p.x >= 1200.0:
			if Rect2(1212,845,80,34).has_point(p): change_roster_page(-1)
			elif Rect2(1508,845,80,34).has_point(p): change_roster_page(1)
			else:
				for local_index in 12:
					var index := roster_page*12+local_index
					if index < unlocked.size() and squad_card_rect(local_index).has_point(p):
						reserve(unlocked[index])
						break

func snapshot(arena) -> Dictionary:
	var data := {}
	for key in SNAP_KEYS:
		data[key] = arena.rng.state if key == "rng_state" else arena.get(key)
	return data

func restore(arena, data: Dictionary) -> void:
	for key in SNAP_KEYS:
		if not data.has(key): continue
		if key == "rng_state": arena.rng.state = int(data[key])
		else: arena.set(key,data[key])
	arena.rebuild_solid_cells()
	arena.navigation_flow.clear()
	arena.navigation_cell = Vector2i(-1,-1)

func save_game() -> void:
	if not operation_started: return
	var c := ConfigFile.new()
	for key in ["launched","focus","overview","operation_started","operation_complete","operation_elapsed","launch_times","mana","mana_max","mana_regen","demon_level","demon_xp","monster_level","current_chapter","selected_chapter","screen_mode","chapter_success","reserve_limit","unlocked","reserves","reserve_clock","max_clock","time_marks","hp_marks","events","current_event","options","roulette","pity_normals","reward_serial","awarded","run_id","payout_done","roster_page"]:
		c.set_value("operation",key,get(key))
	c.set_value("operation","rng_state",rng.state)
	for i in 4:
		if launched[i]: c.set_value("arena_%d" % i,"snapshot",snapshot(arenas[i]))
	c.save(SAVE_PATH)

func load_game() -> void:
	var c := ConfigFile.new()
	var legacy := c.load(SAVE_PATH) != OK
	if legacy and c.load(LEGACY_MULTI_SAVE) != OK: return
	for i in 4:
		if is_instance_valid(views[i]): views[i].queue_free()
		views[i] = null
		arenas[i] = null
		launched[i] = false
	operation_started = true
	for key in ["focus","overview","operation_complete","mana","mana_max","mana_regen","demon_xp","monster_level","current_chapter","selected_chapter","screen_mode","chapter_success","reserve_limit","unlocked","reserves","reserve_clock","max_clock","time_marks","hp_marks","events","current_event","options","roulette","pity_normals","reward_serial","awarded","run_id","payout_done","roster_page"]:
		if c.has_section_key("operation",key): set(key,c.get_value("operation",key))
	if not c.has_section_key("operation","monster_level"): monster_level = int(c.get_value("operation","demon_level",1))
	demon_level = calculate_demon_level()
	if screen_mode not in ["battle","result"]: screen_mode = "result" if operation_complete else "battle"
	if c.has_section_key("operation","operation_elapsed"):
		operation_elapsed = float(c.get_value("operation","operation_elapsed"))
	else: operation_elapsed = max_clock
	var saved: Array = c.get_value("operation","launched",[true,false,false,false])
	if c.has_section_key("operation","launch_times"):
		launch_times.assign(c.get_value("operation","launch_times"))
	else:
		for i in 4:
			launch_times[i] = 0.0 if i < saved.size() and bool(saved[i]) else operation_elapsed+rng.randf_range(30.0,120.0)
	if legacy:
		var scheduled_count := 0
		for value in launch_times:
			if float(value) < 100000000.0: scheduled_count += 1
		current_chapter = 7 if scheduled_count >= 4 else (5 if scheduled_count >= 3 else (3 if scheduled_count >= 2 else 1))
	overview = false
	rng.state = int(c.get_value("operation","rng_state",rng.state))
	for i in 4:
		if i < saved.size() and saved[i]:
			launch_arena(i)
			restore(arenas[i],c.get_value("arena_%d" % i,"snapshot",{}))
	roster_page = clampi(roster_page,0,roster_page_count()-1)
	queue_redraw()

func label(s: String,p: Vector2,size: int = 15,color: Color = Color.WHITE) -> void:
	draw_string(FONT,p,s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func draw_chapter_select() -> void:
	draw_rect(Rect2(0,0,1600,900),Color("121b27"))
	label("서바이버 등골 브레이커 · 다블라의 연대기",Vector2(82,88),35,Color("f4d492"))
	label("다블라 Lv.%d   영구 성장 점수 %d   보유 재화 %d" % [demon_level,int(meta.get("demon_power_xp",0)),int(meta.get("demon_currency",0))],Vector2(85,137),20,Color("a9dcd5"))
	label("챕터 선택 · 위/아래 방향키 또는 클릭",Vector2(84,199),19)
	for i in 10:
		var y := 228.0+float(i)*50.0
		var available := i+1 <= int(meta.get("unlocked_chapter",1))
		draw_rect(Rect2(82,y,740,46),Color("4b413c") if selected_chapter == i+1 else Color("273641") if available else Color("1b2830"))
		label("%02d  %s  · 전장 %d개%s" % [i+1,CHAPTER_NAMES[i],CHAPTER_COUNTS[i],"" if available else " · 잠김"],Vector2(96,y+30),18,Color("ffe2ae") if selected_chapter == i+1 else Color("d4dfdf") if available else Color("75848a"))
	draw_rect(Rect2(920,217,620,330),Color("202f3b"))
	label("제%d장 · %s" % [selected_chapter,CHAPTER_NAMES[selected_chapter-1]],Vector2(955,266),28,Color("f3d49b"))
	label(CHAPTER_STORIES[selected_chapter-1],Vector2(955,325),18)
	label(CHAPTER_DIALOGUE[selected_chapter-1][0],Vector2(955,355),15,Color("d7d9e2"))
	label(CHAPTER_DIALOGUE[selected_chapter-1][1],Vector2(955,377),15,Color("e7cba2"))
	label("30분 생존 영웅을 막아라 · %d개 전장" % CHAPTER_COUNTS[selected_chapter-1],Vector2(955,417),17,Color("a6d4d1"))
	label("영구 강화 · 1~4 구매",Vector2(955,466),20,Color("f3d49b"))
	var keys := ["demon_mana","demon_regen","demon_reserve","demon_final"]
	var names := ["시작 마력","마력 재생","대기열","최종 악마"]
	for i in 4:
		var level := int(meta.get(keys[i],0))
		label("%d %s Lv.%d/5 · %d 재화" % [i+1,names[i],level,25+level*20],Vector2(955,500+i*28),15)
	draw_rect(Rect2(1010,610,420,65),Color("71553f"))
	label("Enter / 클릭  챕터 출전",Vector2(1040,651),24,Color("ffe0a0"))
	label("H 설명서   L 저장된 챕터 이어하기",Vector2(955,750),17,Color("b7c8d2"))

func draw_tutorial() -> void:
	draw_rect(Rect2(0,0,1600,900),Color("080d15",0.94))
	var headings := ["01  전투는 자동으로 진행된다","02  전장을 지정한다","03  부대를 투입한다","04  마력과 몬스터 경험치","05  30분 결전"]
	var lines := ["왼쪽에서 영웅이 이동하고 공격한다. 박쥐는 자동으로 계속 투입된다.","전장 칸을 클릭하거나 F1~F4를 눌러 투입 대상을 정한다.","오른쪽 부대 카드를 클릭하면 선택한 전장에 한 분대를 예약한다.","마력은 투입에 쓰고 회복된다. 모든 전장의 실제 피해가 군단 경험치가 된다.","영웅이 30분을 버티면 다블라가 출전한다. 몬스터 레벨업 때마다 룰렛이 열린다."]
	label("다블라 전투 설명서",Vector2(190,170),42,Color("f3d397"))
	label(headings[tutorial_page],Vector2(190,310),32,Color("a9e0d6"))
	label(lines[tutorial_page],Vector2(190,385),23)
	label("설명 %d/5",Vector2(190,650),19,Color("f3d397"))
	label("Enter / 클릭 다음    Esc 닫기",Vector2(190,708),20,Color("b9cbd1"))

func draw_chapter_result() -> void:
	draw_rect(Rect2(0,0,1600,900),Color("101a26"))
	label("제%d장 · %s" % [current_chapter,CHAPTER_NAMES[current_chapter-1]],Vector2(130,175),38,Color("f3d397"))
	label("전선 유지 · 다음 챕터 개방" if chapter_success else "영웅이 전선을 지켰다 · 재도전 가능",Vector2(130,252),31,Color("9ce0c6") if chapter_success else Color("e5acac"))
	label(CHAPTER_STORIES[current_chapter-1],Vector2(130,335),23)
	label(CHAPTER_DIALOGUE[current_chapter-1][1],Vector2(130,371),19,Color("dcc49f"))
	label("다블라 Lv.%d · 영구 성장 유지     군단 Lv.%d 달성" % [demon_level,monster_level],Vector2(130,425),23)
	label("Enter 챕터 선택    R 현재 챕터 재도전    H 설명서",Vector2(130,585),21,Color("f4d799"))

func draw_meter(rect: Rect2, ratio: float, color: Color) -> void:
	draw_rect(rect,Color("11191f"))
	draw_rect(Rect2(rect.position,Vector2(rect.size.x*clampf(ratio,0.0,1.0),rect.size.y)),color)
	draw_rect(rect,Color("62717b"),false,1.0)

func draw_card_gear(index: int, origin: Vector2) -> void:
	var arena = arenas[index]
	for j in 6:
		var x := origin.x+float(j%3)*193.0
		var y := origin.y+float(j/3)*30.0
		var evolved: bool = arena.evolved.has(arena.WEAPONS[j])
		var box := Rect2(x,y,187,27)
		draw_rect(box,Color("625026") if evolved else Color("263a43"))
		draw_rect(box,Color("e3c174") if evolved else Color("657f89"),false,1.0)
		var name: String = arena.ULTIMATE_NAMES[j].substr(0,3) if evolved else WEAPON_SHORT[j]
		var line := "%s %d/5 · %s %d/3%s" % [name,int(arena.hero[arena.WEAPONS[j]]),ITEM_SHORT[j],arena.item_level(arena.ITEMS[j])," ★" if evolved else ""]
		label(line,Vector2(x+5,y+19),12,Color("ffe49f") if evolved else Color("e0eeee"))

func draw_arena_card(index: int) -> void:
	var card := arena_rect(index)
	var origin := card.position
	draw_rect(card,Color("192932"))
	draw_rect(Rect2(origin,Vector2(card.size.x,54)),Color("243942"))
	if launched[index]:
		var arena = arenas[index]
		var hp_percent := int(100.0*float(arena.hero["hp"])/maxf(1.0,float(arena.hero["max_hp"])))
		var status := " · 종료" if arena.state in ["victory","defeat"] else ""
		label("F%d %s · %s  %02d:%02d  레벨%d  체력 %d%%%s" % [index+1,NAMES[index],HERO_CLASSES[index],int(arena.elapsed)/60,int(arena.elapsed)%60,int(arena.hero["level"]),hp_percent,status],origin+Vector2(12,21),13,Color("f5d492") if focus == index else Color("e4eeee"))
		label("특성: %s" % HERO_TRAITS[index],origin+Vector2(12,44),12,Color("bcdad4"))
		var battle_rect := Rect2(origin+Vector2(42,55),Vector2(card.size.x-84,card.size.y-125))
		var ratio := battle_rect.size.x/battle_rect.size.y
		var source := Rect2(0,110,860,580)
		if ratio < 860.0/580.0:
			source.size.x = 580.0*ratio
			source.position.x = clampf(float(arena.hero["pos"].x)-source.size.x*0.5,0.0,860.0-source.size.x)
		else:
			source.size.y = 860.0/ratio
			source.position.y = clampf(float(arena.hero["pos"].y)-source.size.y*0.5,110.0,690.0-source.size.y)
		draw_texture_rect_region(views[index].get_texture(),battle_rect,source)
		draw_rect(battle_rect,Color("587277"),false,1.0)
		draw_rect(Rect2(origin+Vector2(0,card.size.y-68),Vector2(card.size.x,68)),Color("14242e"))
		draw_card_gear(index,origin+Vector2(11,card.size.y-64))
	draw_rect(card,Color("f0c46e") if focus == index else Color("547680"),false,3.0 if focus == index else 2.0)

func _draw() -> void:
	if history_prologue != null: return
	if screen_mode == "chapter_select": draw_chapter_select(); return
	if screen_mode == "result": draw_chapter_result(); return
	if screen_mode == "tutorial" and tutorial_return != "battle": draw_tutorial(); return
	draw_rect(Rect2(0,0,1600,900),Color("101a25"))
	if not operation_started:
		label("서바이버 등골 브레이커",Vector2(210,210),48,Color("f0d498"))
		label("네 전장을 동시에 관찰하고 악마의 투입을 지휘하십시오.",Vector2(215,280),22)
		label("Enter 새 작전 시작",Vector2(215,370),26)
		if FileAccess.file_exists(OLD_SAVE): label("I 기존 한 판을 첫 전장으로 가져오기 · 원본 저장 보존",Vector2(215,415),17)
		return
	for i in active_indices(): draw_arena_card(i)
	draw_rect(Rect2(1200,0,400,900),Color("1b2932"))
	draw_rect(Rect2(1200,0,400,900),Color("6e8990"),false,2.0)
	label("다블라 Lv.%d · 제%d장" % [demon_level,current_chapter],Vector2(1220,38),24,Color("f2d296"))
	label("마력 %.0f/%.0f  +%.1f/초" % [mana,mana_max,mana_regen],Vector2(1220,72),15)
	draw_meter(Rect2(1220,80,360,13),mana/maxf(1.0,mana_max),Color("aa7be4"))
	var xp_goal := monster_xp_goal()
	label("공용 군단 Lv.%d · 경험치 %.0f/%.0f" % [monster_level,demon_xp,xp_goal],Vector2(1220,122),15)
	draw_meter(Rect2(1220,130,360,13),demon_xp/xp_goal,Color("69cfc2"))
	label("대기열 %d/%d · 전투 중 %d/%d" % [reserves.size(),reserve_limit,active_count(),chapter_arena_count()],Vector2(1220,169),15)
	label("전장 클릭 / F1~F4 선택 · H 설명",Vector2(1220,194),14,Color("bdd0d1"))
	if focus < 0:
		label("투입 대상 미선택",Vector2(1220,229),20,Color("f0cf89"))
		label("전장 칸을 클릭하여 대상을 지정하십시오.",Vector2(1220,258),14,Color("c8d4d2"))
	elif launched[focus]:
		var arena = arenas[focus]
		label("대상: %s" % NAMES[focus],Vector2(1220,229),20,Color("f0cf89"))
		label("영웅 레벨%d · 체력 %d/%d" % [int(arena.hero["level"]),maxi(0,int(arena.hero["hp"])),int(arena.hero["max_hp"])],Vector2(1220,258),15)
		if arena.state in ["mini","final"]:
			label("분신 조작: WASD · 클릭/J · K · Space",Vector2(1220,278),11,Color("ecc797"))
	else:
		label("대상: %s (입장 대기)" % NAMES[focus],Vector2(1220,229),18,Color("d4c395"))
	if not current_event.is_empty():
		draw_rect(Rect2(1208,286,384,194),Color("283542"))
		if current_event["kind"] == "unlock":
			label("몬스터 해금 · 전투 계속 진행",Vector2(1220,312),17,Color("f6d186"))
			for j in options.size():
				var id: String = options[j]
				label("%d. %s · %s" % [j+1,reference_arena().TYPES[id]["name"],reference_arena().monster_role(id)],Vector2(1220,349+43*j),13)
			label("숫자 1~3 또는 클릭",Vector2(1220,475),12)
		else:
			var drawn: Array = roulette.get("rewards",[roulette.get("reward","mana_refill")])
			label("전리품 상자 · %d개" % drawn.size(),Vector2(1220,312),18,Color("f6d186"))
			var spinning: bool = not bool(roulette.get("done",false))
			var spin_time: float = float(roulette.get("time",0.0))
			for j in drawn.size():
				var id: String = drawn[j]
				var display_id: String = REWARD_IDS[posmod(int(spin_time*24.0)+j,REWARD_IDS.size())] if spinning else id
				var x := 1228.0+float(j%3)*119.0
				var y := 350.0+float(j/3)*55.0
				draw_line(Vector2(1390,464),Vector2(x+42,y-10),reward_color(id).lightened(0.25),3.0)
				label("◆ %s" % reward_name(display_id),Vector2(x,y),12,reward_color(id) if not spinning else Color("dce5e9"))
			if not spinning:
				for k in 18:
					var angle := TAU*float(k)/18.0+particle_clock
					draw_circle(Vector2(1390,385)+Vector2(cos(angle),sin(angle))*43.0,2.0,Color.from_hsv(float(k)/18.0,0.6,1.0))
	label("부대 카드 · 선택 전장에 1분대 예약",Vector2(1220,497),14,Color("efd397"))
	for local_index in 12:
			var index := roster_page*12+local_index
			if index >= unlocked.size(): break
			var id: String = unlocked[index]
			var data: Dictionary = reference_arena().TYPES[id]
			var card := squad_card_rect(local_index)
			var reason := squad_block_reason(id)
			var available := reason.is_empty()
			draw_rect(card,Color("315b4e") if available else Color("39454b"))
			draw_rect(card,Color("d6bd77") if available and card.has_point(get_global_mouse_position()) else Color("77978d") if available else Color("536169"),false,1.0)
			label(String(data["name"]),card.position+Vector2(7,17),13,Color("f2f0db") if available else Color("adb8ba"))
			label("%d마력 · %d기" % [int(data["cost"]),int(data["count"])],card.position+Vector2(7,31),11,Color("d0e4d5") if available else Color("9aa9ab"))
			label(reference_arena().monster_role(id),card.position+Vector2(7,45),10,Color("d0e4d5") if available else Color("9aa9ab"))
	label("‹ 이전",Vector2(1220,866),16,Color("ebd493") if roster_page > 0 else Color("718388"))
	label("%d/%d" % [roster_page+1,roster_page_count()],Vector2(1390,866),15,Color("c8d7d7"))
	label("다음 ›",Vector2(1516,866),16,Color("ebd493") if roster_page < roster_page_count()-1 else Color("718388"))
	if operation_complete:
		label("작전 종료 · N 새 작전",Vector2(1220,465),18,Color("f6d18d"))
	elif notice_time > 0.0:
		label(notice,Vector2(1220,465),13,Color("f4d58f"))
	elif current_event.is_empty() and focus < 0:
		label("전장을 먼저 선택하십시오.",Vector2(1220,465),14,Color("f4d58f"))
	elif current_event.is_empty() and focus >= 0 and not launched[focus]:
		label("영웅 입장 후 부대를 투입할 수 있습니다.",Vector2(1220,465),13,Color("f4d58f"))
	elif current_event.is_empty() and focus >= 0 and arenas[focus].state in ["victory","defeat"]:
		label("종료된 전장에는 투입할 수 없습니다.",Vector2(1220,465),13,Color("f4d58f"))
	if screen_mode == "tutorial": draw_tutorial()
