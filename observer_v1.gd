extends Node2D

const FONT = preload("res://fonts/NanumGothic-Regular.ttf")
const SCREEN := Vector2(1280, 720)
const SAVE_PATH := "user://save_observer_v1.cfg"
const META_PATH := "user://save_observer_meta_v1.cfg"
const BATTLE_TIME := 1800.0
const BAT_INTERVAL := 1.12
const RANGED_TYPES := ["archer","ember_cultist","banshee","cultist","blood_mage","lantern_wisp","web_spinner","crystal_archer","void_tether","imp","frost"]
const RESERVE_INTERVAL := 2.4
const MAX_MONSTERS := 180
const TYPES := {
	"bat": {"name":"박쥐", "hp":42.0, "damage":0.03, "speed":175.0, "cost":0.0, "count":6, "color":Color("8f80c1")},
	"zombie": {"name":"좀비", "hp":63.0, "damage":5.0, "speed":105.0, "cost":18.0, "count":5, "color":Color("80aa76")},
	"skeleton": {"name":"해골", "hp":45.0, "damage":3.4, "speed":95.0, "cost":22.0, "count":6, "color":Color("d6d2b7")},
	"crawler": {"name":"기어오는 것", "hp":32.0, "damage":2.8, "speed":145.0, "cost":20.0, "count":7, "color":Color("ae8b7b")},
	"archer": {"name":"해골 궁수", "hp":38.0, "damage":4.4, "speed":78.0, "cost":29.0, "count":4, "color":Color("cabfa9")},
	"armored_zombie": {"name":"갑옷 좀비", "hp":118.0, "damage":5.8, "speed":56.0, "cost":34.0, "count":4, "color":Color("718d77")},
	"imp": {"name":"화염 임프", "hp":39.0, "damage":4.8, "speed":111.0, "cost":30.0, "count":5, "color":Color("d78864")},
	"ghost": {"name":"유령", "hp":52.0, "damage":4.3, "speed":120.0, "cost":35.0, "count":5, "color":Color("b2d5d1")},
	"frost": {"name":"냉동 망령", "hp":75.0, "damage":5.4, "speed":85.0, "cost":42.0, "count":4, "color":Color("82c7d3")},
	"leech": {"name":"흡혈귀", "hp":58.0, "damage":6.0, "speed":106.0, "cost":40.0, "count":5, "color":Color("a86b83")},
	"swarm": {"name":"박쥐 떼", "hp":23.0, "damage":2.1, "speed":155.0, "cost":38.0, "count":13, "color":Color("786aa0")},
	"hound": {"name":"악마 사냥개", "hp":101.0, "damage":7.1, "speed":138.0, "cost":51.0, "count":4, "color":Color("b87064")},
	"cultist": {"name":"어둠 사제", "hp":91.0, "damage":6.4, "speed":70.0, "cost":55.0, "count":4, "color":Color("9b78ad")},
	"giant": {"name":"거대 해골", "hp":220.0, "damage":10.0, "speed":48.0, "cost":65.0, "count":2, "color":Color("d5c9a3")},
	"plague": {"name":"역병 운반자", "hp":150.0, "damage":8.5, "speed":59.0, "cost":64.0, "count":3, "color":Color("8ca665")},
	"blood_mage": {"name":"피의 마도사", "hp":125.0, "damage":9.2, "speed":69.0, "cost":70.0, "count":3, "color":Color("bd718b")},
	"demon_guard": {"name":"악마 근위병", "hp":190.0, "damage":10.6, "speed":80.0, "cost":74.0, "count":3, "color":Color("a77d73")},
	"rat": {"name":"굴쥐", "hp":28.0, "damage":2.2, "speed":165.0, "cost":14.0, "count":8, "color":Color("998477"), "role":"무리 돌진 · 검에 약함"},
	"mudling": {"name":"진흙괴물", "hp":92.0, "damage":3.8, "speed":65.0, "cost":23.0, "count":4, "color":Color("857c65"), "role":"접촉 둔화 · 폭탄에 약함"},
	"bone_runner": {"name":"뼈 질주병", "hp":42.0, "damage":4.2, "speed":125.0, "cost":26.0, "count":5, "color":Color("c2b9a5"), "role":"주기적 돌진 · 매혹구에 약함"},
	"sporeling": {"name":"포자병", "hp":48.0, "damage":3.2, "speed":92.0, "cost":28.0, "count":5, "color":Color("a8a16a"), "role":"독 포자 · 폭탄에 약함"},
	"shield_goblin": {"name":"방패 고블린", "hp":110.0, "damage":4.1, "speed":73.0, "cost":31.0, "count":4, "color":Color("76977d"), "role":"검 피해 감소 · 폭탄에 약함"},
	"venom_moth": {"name":"독나방", "hp":40.0, "damage":3.6, "speed":136.0, "cost":36.0, "count":6, "color":Color("a18bb5"), "role":"접촉 독 · 검에 약함"},
	"bone_spearman": {"name":"해골 창병", "hp":68.0, "damage":5.3, "speed":85.0, "cost":39.0, "count":4, "color":Color("d3c5a8"), "role":"긴 사거리 · 폭탄에 약함"},
	"grave_digger": {"name":"묘지꾼", "hp":130.0, "damage":5.9, "speed":67.0, "cost":44.0, "count":3, "color":Color("8c8d77"), "role":"동료 가속 · 매혹구에 약함"},
	"ember_cultist": {"name":"잿불 신도", "hp":72.0, "damage":5.0, "speed":80.0, "cost":48.0, "count":4, "color":Color("bd806c"), "role":"원거리 화염 · 검에 약함"},
	"wraith": {"name":"그림자 망령", "hp":80.0, "damage":6.3, "speed":115.0, "cost":53.0, "count":3, "color":Color("8ca5ae"), "role":"순간 이동 · 매혹구에 약함"},
	"banshee": {"name":"밴시", "hp":94.0, "damage":6.5, "speed":94.0, "cost":59.0, "count":3, "color":Color("bda7ca"), "role":"원거리 둔화 · 폭탄에 약함"},
	"stone_golem": {"name":"석상 골렘", "hp":260.0, "damage":8.5, "speed":42.0, "cost":69.0, "count":2, "color":Color("a6a198"), "role":"검 피해 감소 · 폭탄에 약함"},
	"abyss_knight": {"name":"심연 기사", "hp":210.0, "damage":11.0, "speed":83.0, "cost":78.0, "count":2, "color":Color("745d91"), "role":"돌진·방패 · 폭탄에 약함"},
	"thornling": {"name":"가시병", "hp":72.0, "damage":4.2, "speed":80.0, "cost":30.0, "count":5, "color":Color("628f64"), "role":"근접 가시 · 화염에 약함", "family":"plant"},
	"rock_crab": {"name":"바위게", "hp":150.0, "damage":5.0, "speed":58.0, "cost":38.0, "count":3, "color":Color("9f9690"), "role":"측면 방패 · 폭탄에 약함", "family":"beast"},
	"lantern_wisp": {"name":"등불 도깨비", "hp":48.0, "damage":4.8, "speed":122.0, "cost":35.0, "count":4, "color":Color("e1b675"), "role":"부유 원거리 · 매혹구에 약함", "family":"spirit"},
	"burrow_mole": {"name":"굴파기 두더지", "hp":76.0, "damage":5.4, "speed":105.0, "cost":39.0, "count":4, "color":Color("8a7969"), "role":"굴파기 돌진 · 폭탄에 약함", "family":"beast"},
	"bone_drummer": {"name":"뼈 북잡이", "hp":65.0, "damage":3.0, "speed":78.0, "cost":42.0, "count":3, "color":Color("d5caa9"), "role":"동료 가속 · 검에 약함", "family":"bone"},
	"carrion_crow": {"name":"썩은 까마귀", "hp":44.0, "damage":4.5, "speed":148.0, "cost":40.0, "count":5, "color":Color("555b70"), "role":"날개 돌진 · 번개에 약함", "family":"wing"},
	"split_slime": {"name":"분열 슬라임", "hp":100.0, "damage":4.0, "speed":69.0, "cost":43.0, "count":3, "color":Color("6dbb9d"), "role":"사망 시 작은 개체 분열", "family":"slime"},
	"iron_boar": {"name":"철갑 멧돼지", "hp":165.0, "damage":7.8, "speed":121.0, "cost":55.0, "count":3, "color":Color("a2786b"), "role":"정면 돌진 · 화염에 약함", "family":"beast"},
	"mist_stalker": {"name":"안개 추적자", "hp":82.0, "damage":6.2, "speed":114.0, "cost":52.0, "count":3, "color":Color("86a4af"), "role":"순간 이동 · 매혹구에 약함", "family":"spirit"},
	"ember_beetle": {"name":"잿불 딱정벌레", "hp":118.0, "damage":6.0, "speed":79.0, "cost":51.0, "count":3, "color":Color("c76b4d"), "role":"사망 시 폭발 · 폭탄에 약함", "family":"beast"},
	"web_spinner": {"name":"거미줄 사냥꾼", "hp":74.0, "damage":5.5, "speed":99.0, "cost":49.0, "count":4, "color":Color("9e879f"), "role":"원거리 둔화 · 화염에 약함", "family":"beast"},
	"crystal_archer": {"name":"수정 궁수", "hp":68.0, "damage":7.0, "speed":76.0, "cost":57.0, "count":3, "color":Color("81c5d6"), "role":"긴 사거리 · 검에 약함", "family":"bone"},
	"grave_sentinel": {"name":"묘지 파수꾼", "hp":195.0, "damage":7.2, "speed":54.0, "cost":63.0, "count":2, "color":Color("958f89"), "role":"중장 방어 · 폭탄에 약함", "family":"armor"},
	"void_tether": {"name":"공허 속박자", "hp":105.0, "damage":6.6, "speed":72.0, "cost":62.0, "count":3, "color":Color("836ba5"), "role":"원거리 속박 · 성광에 약함", "family":"spirit"},
	"living_armor": {"name":"살아 있는 갑옷", "hp":245.0, "damage":8.2, "speed":70.0, "cost":76.0, "count":2, "color":Color("8fa0a5"), "role":"파쇄검 저항 · 검격 반격", "family":"armor", "counter":"blade"},
	"mirror_eye": {"name":"거울눈", "hp":130.0, "damage":7.4, "speed":103.0, "cost":73.0, "count":2, "color":Color("d2a1d5"), "role":"군주구 저항 · 구체 교란", "family":"spirit", "counter":"orb"},
	"blast_shell": {"name":"폭식 갑각", "hp":215.0, "damage":8.1, "speed":63.0, "cost":77.0, "count":2, "color":Color("b88763"), "role":"유성탄 저항 · 폭발 흡수", "family":"beast", "counter":"bomb"},
	"ground_golem": {"name":"접지 골렘", "hp":260.0, "damage":8.7, "speed":53.0, "cost":79.0, "count":2, "color":Color("92a9a1"), "role":"천뢰 저항 · 전기 접지", "family":"armor", "counter":"lightning"},
	"ash_phoenix": {"name":"잿빛 불사조", "hp":125.0, "damage":8.8, "speed":142.0, "cost":82.0, "count":2, "color":Color("c78866"), "role":"불사 장막 저항 · 재 점화", "family":"wing", "counter":"fire"},
	"eclipse_guard": {"name":"일식 수호자", "hp":205.0, "damage":8.0, "speed":71.0, "cost":80.0, "count":2, "color":Color("777696"), "role":"별빛 화살 저항 · 방벽", "family":"armor", "counter":"arrow"},
	"trap_elite": {"name":"함정 정예", "hp":175.0, "damage":9.0, "speed":118.0, "cost":0.0, "count":4, "color":Color("c47766")}
}
const WEAPONS := ["blade","orb","bomb","lightning","fire","arrow"]
const ITEMS := ["whetstone","magnet","ignition","coil","glass_cloak","lens"]
const WEAPON_NAMES := ["검","매혹구","폭탄","번개 인장","화염 띠","성광 화살"]
const ITEM_NAMES := ["숫돌","자석 심장","점화 핵","축전 고리","유리 망토","사냥꾼의 렌즈"]
const ULTIMATE_NAMES := ["파쇄검","군주구","유성탄","천뢰 인장","불사 장막","별빛 화살비"]
const COUNTERS := ["living_armor","mirror_eye","blast_shell","ground_golem","ash_phoenix","eclipse_guard"]
const TIME_CARDS := {
	300:["skeleton","crawler","archer"],
	600:["armored_zombie","imp","ghost"],
	900:["frost","leech","swarm"],
	1200:["hound","cultist","giant"],
	1500:["plague","blood_mage","demon_guard"]
}
const HP_CARDS := ["skeleton","crawler","archer","armored_zombie","imp","ghost","frost","leech","swarm","hound","cultist","giant","plague","blood_mage","demon_guard","rat","mudling","bone_runner","sporeling","shield_goblin","venom_moth","bone_spearman","grave_digger","ember_cultist","wraith","banshee","stone_golem","abyss_knight","thornling","rock_crab","lantern_wisp","burrow_mole","bone_drummer","carrion_crow","split_slime","iron_boar","mist_stalker","ember_beetle","web_spinner","crystal_archer","grave_sentinel","void_tether"]
const META_TIERS := [
	["bat","zombie","rat","crawler","mudling"],
	["skeleton","archer","bone_runner","sporeling","shield_goblin"],
	["armored_zombie","imp","ghost","venom_moth","bone_spearman"],
	["frost","leech","swarm","grave_digger","ember_cultist"],
	["hound","cultist","giant","wraith","banshee"],
	["plague","blood_mage","demon_guard","stone_golem","abyss_knight"],
	["thornling","rock_crab","lantern_wisp","burrow_mole","bone_drummer"],
	["carrion_crow","split_slime","iron_boar","mist_stalker","ember_beetle"],
	["web_spinner","crystal_archer","grave_sentinel","void_tether"]
]
const TIER_MINUTES := [0,10,25,50,90,140,200,270,350]
const TIER_DAMAGE := [0,3000,7000,15000,30000,50000,75000,110000,160000]
const OLD_ROLES := {
	"bat":"빠른 추격 · 검에 약함", "zombie":"느린 전열 · 폭탄에 약함", "skeleton":"균형 전열 · 검에 약함",
	"crawler":"무리 추격 · 매혹구에 약함", "archer":"원거리 견제 · 검에 약함", "armored_zombie":"튼튼한 전열 · 폭탄에 약함",
	"imp":"원거리 화염 · 검에 약함", "ghost":"순간 이동 · 매혹구에 약함", "frost":"둔화 공격 · 폭탄에 약함",
	"leech":"흡혈 전열 · 매혹구에 약함", "swarm":"대규모 압박 · 매혹구에 약함", "hound":"빠른 돌진 · 검에 약함",
	"cultist":"원거리 저주 · 검에 약함", "giant":"중장 전열 · 폭탄에 약함", "plague":"독 공격 · 폭탄에 약함",
	"blood_mage":"원거리 흡혈 · 검에 약함", "demon_guard":"정예 방패 · 폭탄에 약함"
}

var state := "title"
var elapsed := 0.0
var mana := 60.0
var mana_max := 100.0
var mana_regen := 2.0
var demon_level := 1
var monster_level := 1
var demon_xp := 0.0
var reserve_limit := 3
var unlocked: Array[String] = ["zombie"]
var reserves: Array[String] = []
var monsters: Array[Dictionary] = []
var gems: Array[Dictionary] = []
var hero_chests: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var traps: Array[Dictionary] = []
var next_trap_at := 180.0
var events: Array[Dictionary] = []
var event_serial := 0
var reward_ids: Array[String] = []
var time_marks: Array[int] = []
var hp_marks: Array[int] = []
var chest_marks: Array[String] = []
var current_event: Dictionary = {}
var current_options: Array[String] = []
var chosen_count := 0
var last_result := ""
var bat_clock := 0.0
var reserve_clock := 0.0
var checkpoint_clock := 0.0
var hero: Dictionary = {}
var boss: Dictionary = {}
var boss_kind := ""
var boss_time := 0.0
var boss_attack_cd := 0.0
var boss_dash_cd := 0.0
var boss_dash_time := 0.0
var boss_special_cd := 0.0
var arena_radius := 330.0
var demon_hp_bonus := 0.0
var demon_damage_bonus := 0.0
var elite_unlocked := false
var notice := ""
var notice_time := 0.0
var rng := RandomNumberGenerator.new()
var uid_counter := 0
var meta: Dictionary = {}
var run_id := ""
var total_damage := 0.0
var payout_done := false
var automatic_clock := 0.0
var roster_page := 0
var codex_open := false
var obstacles: Array[Dictionary] = []
var pending_evolutions: Array[String] = []
var evolved: Array[String] = []
var counter_due: Array[Dictionary] = []
var counter_opened: Array[String] = []
var return_state := "observe"
var navigation_flow: Array[int] = []
var navigation_solid: Array[bool] = []
var navigation_cell := Vector2i(-1,-1)
var embedded_mode := false
var manual_control := true
var experience_sink: Callable
var embedded_monster_cap := 90
var terrain_seed := 0
var biome_id := 0
var hero_class := 0
var hero_chest_show: Dictionary = {}
var monster_shots: Array[Dictionary] = []
var hero_chest_audio: AudioStreamPlayer
const GRID_ORIGIN := Vector2(20,120)
const GRID_CELL := 28.0
const GRID_WIDTH := 30
const GRID_HEIGHT := 20

func _ready() -> void:
	rng.randomize()
	hero_chest_audio = AudioStreamPlayer.new()
	add_child(hero_chest_audio)
	if embedded_mode: return
	load_meta()
	if FileAccess.file_exists(SAVE_PATH): state = "title"
	else: state = "prepare"
	queue_redraw()

func default_meta() -> Dictionary:
	return {"hero_xp":0,"hero_hp":0,"hero_armor":0,"hero_weapon":0,"demon_currency":0,"demon_mana":0,"demon_regen":0,"demon_reserve":0,"demon_final":0,"total_seconds":0.0,"total_damage":0.0,"completed":[],"codex":["bat","zombie","rat","crawler","mudling"]}

func load_meta() -> void:
	meta = default_meta()
	var c := ConfigFile.new()
	if c.load(META_PATH) == OK:
		for key in meta.keys(): meta[key] = c.get_value("meta",key,meta[key])
	refresh_codex()

func save_meta() -> void:
	var c := ConfigFile.new()
	for key in meta.keys(): c.set_value("meta",key,meta[key])
	c.save(META_PATH)

func refresh_codex() -> void:
	var found: Array = meta.get("codex",[])
	for tier in META_TIERS.size():
		if float(meta.get("total_seconds",0.0)) < float(TIER_MINUTES[tier])*60.0 and float(meta.get("total_damage",0.0)) < float(TIER_DAMAGE[tier]): continue
		for id in META_TIERS[tier]:
			if not found.has(id): found.append(id)
	meta["codex"] = found

func monster_role(id: String) -> String:
	return String(TYPES[id].get("role",OLD_ROLES.get(id,"추격형 · 검에 약함")))

func create_obstacles() -> void:
	obstacles.clear()
	for p in [Vector2(105,204),Vector2(249,204),Vector2(597,194),Vector2(754,218),Vector2(104,544),Vector2(276,552),Vector2(599,552),Vector2(760,538)]:
		obstacles.append({"kind":"tree","pos":p,"radius":25.0})
	for p in [Vector2(351,193),Vector2(491,202),Vector2(175,363),Vector2(688,367),Vector2(433,544)]:
		obstacles.append({"kind":"rock","pos":p,"radius":27.0})
	rebuild_solid_cells()

func create_seeded_obstacles(seed_value: int, biome: int = 0) -> void:
	terrain_seed = seed_value
	biome_id = biome
	var terrain_rng := RandomNumberGenerator.new()
	terrain_rng.seed = seed_value
	var biome_kinds := [["tree","rock"],["bone","rock"],["ruin","rock"],["pillar","rubble"]]
	var kinds: Array = biome_kinds[clampi(biome,0,3)]
	for layout_attempt in 8:
		obstacles.clear()
		for attempt in 240:
			if obstacles.size() >= 13: break
			var pos := Vector2(terrain_rng.randf_range(55.0,805.0),terrain_rng.randf_range(155.0,650.0))
			if pos.distance_to(Vector2(410,365)) < 135.0: continue
			if absf(pos.y-390.0) < 48.0: continue
			var valid := true
			for obstacle in obstacles:
				if pos.distance_to(obstacle["pos"]) < 75.0: valid = false; break
			if valid: obstacles.append({"kind":kinds[(obstacles.size()+biome)%2],"pos":pos,"radius":25.0 if obstacles.size()%2 == 0 else 27.0})
		if obstacles.size() >= 9 and terrain_connected():
			rebuild_solid_cells()
			return
	create_obstacles()
	for n in obstacles.size(): obstacles[n]["kind"] = kinds[n%2]

func terrain_connected() -> bool:
	var origin := Vector2i(15,11)
	var gates := [Vector2i(1,11),Vector2i(29,11),Vector2i(15,2),Vector2i(15,23)]
	var visited := {}
	var open: Array[Vector2i] = [origin]
	visited[origin] = true
	var head := 0
	while head < open.size():
		var cell: Vector2i = open[head]
		head += 1
		for step in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+step
			if next.x < 1 or next.x > 29 or next.y < 2 or next.y > 23 or visited.has(next): continue
			var point := Vector2(float(next.x)*28.0+8.0,float(next.y)*24.0+110.0)
			if blocked_at(point,14.0): continue
			visited[next] = true
			open.append(next)
	for gate in gates:
		if not visited.has(gate): return false
	return true

func rebuild_solid_cells() -> void:
	navigation_solid.resize(GRID_WIDTH*GRID_HEIGHT)
	for y in GRID_HEIGHT:
		for x in GRID_WIDTH:
			var cell := Vector2i(x,y)
			navigation_solid[flow_index(cell)] = blocked_at(cell_center(cell),13.0)

func blocked_at(pos: Vector2, padding: float = 0.0) -> bool:
	for obstacle in obstacles:
		if pos.distance_to(obstacle["pos"]) < float(obstacle["radius"])+padding: return true
	return false

func clear_line(a: Vector2, b: Vector2) -> bool:
	var segment := b-a
	var length_sq := segment.length_squared()
	if length_sq < 0.01: return true
	for obstacle in obstacles:
		var t := clampf((obstacle["pos"]-a).dot(segment)/length_sq,0.0,1.0)
		if (a+segment*t).distance_to(obstacle["pos"]) < float(obstacle["radius"])+3.0: return false
	return true

func move_clear(pos: Vector2, movement: Vector2, padding: float = 8.0) -> Vector2:
	var next := pos+movement
	if not blocked_at(next,padding): return next
	for obstacle in obstacles:
		if next.distance_to(obstacle["pos"]) >= float(obstacle["radius"])+padding: continue
		var normal: Vector2 = (pos-obstacle["pos"]).normalized()
		if normal.length_squared() < 0.01: normal = Vector2.RIGHT
		var tangent := Vector2(-normal.y,normal.x)
		var slide := tangent*movement.dot(tangent)
		if slide.length() > 0.1 and not blocked_at(pos+slide,padding): return pos+slide
		for side in [1.0,-1.0]:
			var detour: Vector2 = tangent*side*movement.length()
			if not blocked_at(pos+detour,padding): return pos+detour
	return pos

func grid_of(pos: Vector2) -> Vector2i:
	return Vector2i(clampi(int((pos.x-GRID_ORIGIN.x)/GRID_CELL),0,GRID_WIDTH-1),clampi(int((pos.y-GRID_ORIGIN.y)/GRID_CELL),0,GRID_HEIGHT-1))

func cell_center(cell: Vector2i) -> Vector2:
	return GRID_ORIGIN+Vector2(float(cell.x)+0.5,float(cell.y)+0.5)*GRID_CELL

func flow_index(cell: Vector2i) -> int:
	return cell.y*GRID_WIDTH+cell.x

func rebuild_navigation() -> void:
	var target := grid_of(hero["pos"])
	if target == navigation_cell and not navigation_flow.is_empty(): return
	navigation_cell = target
	navigation_flow.resize(GRID_WIDTH*GRID_HEIGHT)
	navigation_flow.fill(9999)
	var queue: Array[Vector2i] = [target]
	navigation_flow[flow_index(target)] = 0
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+delta
			if next.x < 0 or next.y < 0 or next.x >= GRID_WIDTH or next.y >= GRID_HEIGHT: continue
			if navigation_solid[flow_index(next)] or navigation_flow[flow_index(next)] < 9999: continue
			navigation_flow[flow_index(next)] = navigation_flow[flow_index(cell)]+1
			queue.append(next)

func route_direction(pos: Vector2, target: Vector2) -> Vector2:
	if clear_line(pos,target): return (target-pos).normalized()
	rebuild_navigation()
	var cell := grid_of(pos)
	var best := cell
	var best_cost := navigation_flow[flow_index(cell)] if not navigation_flow.is_empty() else 9999
	for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
		var next: Vector2i = cell+delta
		if next.x < 0 or next.y < 0 or next.x >= GRID_WIDTH or next.y >= GRID_HEIGHT: continue
		var cost := navigation_flow[flow_index(next)]
		if cost < best_cost: best = next; best_cost = cost
	return (cell_center(best)-pos).normalized() if best != cell else (target-pos).normalized()

func hero_meta_goal() -> int:
	return 2+int(meta["hero_hp"])+int(meta["hero_armor"])+int(meta["hero_weapon"])

func upgrade_cost(key: String) -> int:
	return 20+int(meta[key])*20

func buy_upgrade(index: int) -> bool:
	var keys := ["demon_mana","demon_regen","demon_reserve","demon_final"]
	if index < 0 or index >= keys.size(): return false
	var key: String = keys[index]
	if int(meta[key]) >= 5 or int(meta["demon_currency"]) < upgrade_cost(key): return false
	meta["demon_currency"] = int(meta["demon_currency"])-upgrade_cost(key)
	meta[key] = int(meta[key])+1
	save_meta()
	return true

func fresh_run() -> void:
	rng.randomize()
	if meta.is_empty(): load_meta()
	run_id = "%d_%d" % [int(Time.get_unix_time_from_system()),rng.randi()]
	total_damage = 0.0
	payout_done = false
	automatic_clock = 0.0
	roster_page = 0
	codex_open = false
	pending_evolutions.clear()
	evolved.clear()
	counter_due.clear()
	counter_opened.clear()
	return_state = "observe"
	create_obstacles()
	navigation_flow.clear()
	navigation_cell = Vector2i(-1,-1)
	elapsed = 0.0
	mana = 60.0+float(meta["demon_mana"])*8.0
	mana_max = 100.0+float(meta["demon_mana"])*8.0
	mana_regen = 2.0+float(meta["demon_regen"])*0.18
	demon_level = 1
	demon_xp = 0.0
	reserve_limit = 3+int(meta["demon_reserve"])
	unlocked = ["zombie"]
	reserves.clear()
	monsters.clear()
	gems.clear()
	hero_chests.clear()
	effects.clear()
	traps.clear()
	monster_shots.clear()
	hero_chest_show.clear()
	hero_class = 0
	next_trap_at = 180.0
	events.clear()
	reward_ids.clear()
	time_marks.clear()
	hp_marks.clear()
	chest_marks.clear()
	current_event.clear()
	current_options.clear()
	chosen_count = 0
	last_result = ""
	bat_clock = 0.0
	reserve_clock = 0.0
	checkpoint_clock = 0.0
	boss.clear()
	boss_kind = ""
	boss_time = 0.0
	boss_attack_cd = 0.0
	boss_dash_cd = 0.0
	boss_dash_time = 0.0
	boss_special_cd = 0.0
	arena_radius = 330.0
	demon_hp_bonus = 0.0
	demon_damage_bonus = 0.0
	elite_unlocked = false
	uid_counter = 0
	var initial_hp := 700.0+float(meta["hero_hp"])*300.0
	hero = {"pos":Vector2(410,365),"hp":initial_hp,"max_hp":initial_hp,"level":1,"xp":0,"xp_goal":6,"kills":0,"blade":1+int(meta["hero_weapon"])/2,"orb":0,"bomb":0,"lightning":0,"fire":0,"arrow":0,"items":{},"shield":0,"attack_cd":0.0,"orb_cd":0.0,"bomb_cd":0.0,"lightning_cd":0.0,"fire_cd":0.0,"arrow_cd":0.0,"boss_hit_cd":0.0,"phase":0.0,"invuln":0.0,"slow_time":0.0,"motion":Vector2.RIGHT,"armor_meta":int(meta["hero_armor"])}
	state = "opening"
	save_run()

func save_run() -> void:
	if embedded_mode: return
	if state == "title": return
	var c := ConfigFile.new()
	c.set_value("run","version",1)
	c.set_value("run","run_id",run_id)
	c.set_value("run","total_damage",total_damage)
	c.set_value("run","payout_done",payout_done)
	c.set_value("run","automatic_clock",automatic_clock)
	c.set_value("run","obstacles",obstacles)
	c.set_value("run","pending_evolutions",pending_evolutions)
	c.set_value("run","evolved",evolved)
	c.set_value("run","counter_due",counter_due)
	c.set_value("run","counter_opened",counter_opened)
	c.set_value("run","return_state",return_state)
	c.set_value("run","state",state)
	c.set_value("run","elapsed",elapsed)
	c.set_value("run","mana",mana)
	c.set_value("run","mana_max",mana_max)
	c.set_value("run","mana_regen",mana_regen)
	c.set_value("run","demon_level",demon_level)
	c.set_value("run","demon_xp",demon_xp)
	c.set_value("run","reserve_limit",reserve_limit)
	c.set_value("run","unlocked",unlocked)
	c.set_value("run","reserves",reserves)
	c.set_value("run","monsters",monsters)
	c.set_value("run","gems",gems)
	c.set_value("run","hero_chests",hero_chests)
	c.set_value("run","effects",effects)
	c.set_value("run","traps",traps)
	c.set_value("run","next_trap_at",next_trap_at)
	c.set_value("run","events",events)
	c.set_value("run","event_serial",event_serial)
	c.set_value("run","reward_ids",reward_ids)
	c.set_value("run","time_marks",time_marks)
	c.set_value("run","hp_marks",hp_marks)
	c.set_value("run","chest_marks",chest_marks)
	c.set_value("run","current_event",current_event)
	c.set_value("run","current_options",current_options)
	c.set_value("run","chosen_count",chosen_count)
	c.set_value("run","last_result",last_result)
	c.set_value("run","bat_clock",bat_clock)
	c.set_value("run","reserve_clock",reserve_clock)
	c.set_value("run","hero",hero)
	c.set_value("run","boss",boss)
	c.set_value("run","boss_kind",boss_kind)
	c.set_value("run","boss_time",boss_time)
	c.set_value("run","boss_attack_cd",boss_attack_cd)
	c.set_value("run","boss_dash_cd",boss_dash_cd)
	c.set_value("run","boss_dash_time",boss_dash_time)
	c.set_value("run","boss_special_cd",boss_special_cd)
	c.set_value("run","arena_radius",arena_radius)
	c.set_value("run","demon_hp_bonus",demon_hp_bonus)
	c.set_value("run","demon_damage_bonus",demon_damage_bonus)
	c.set_value("run","elite_unlocked",elite_unlocked)
	c.set_value("run","uid_counter",uid_counter)
	c.set_value("run","rng_state",rng.state)
	c.save(SAVE_PATH)

func load_run() -> void:
	var c := ConfigFile.new()
	if c.load(SAVE_PATH) != OK:
		fresh_run()
		return
	if int(c.get_value("run","version",0)) != 1:
		fresh_run()
		return
	state = String(c.get_value("run","state","opening"))
	run_id = String(c.get_value("run","run_id","legacy_%d" % int(c.get_value("run","rng_state",0))))
	total_damage = float(c.get_value("run","total_damage",0.0))
	payout_done = bool(c.get_value("run","payout_done",false))
	automatic_clock = float(c.get_value("run","automatic_clock",0.0))
	obstacles.assign(c.get_value("run","obstacles",[]))
	if obstacles.is_empty(): create_obstacles()
	else: rebuild_solid_cells()
	pending_evolutions.assign(c.get_value("run","pending_evolutions",[]))
	evolved.assign(c.get_value("run","evolved",[]))
	counter_due.assign(c.get_value("run","counter_due",[]))
	counter_opened.assign(c.get_value("run","counter_opened",[]))
	return_state = String(c.get_value("run","return_state","observe"))
	navigation_flow.clear()
	navigation_cell = Vector2i(-1,-1)
	elapsed = float(c.get_value("run","elapsed",0.0))
	mana = float(c.get_value("run","mana",60.0))
	mana_max = float(c.get_value("run","mana_max",100.0))
	mana_regen = float(c.get_value("run","mana_regen",2.0))
	demon_level = maxi(1,int(c.get_value("run","demon_level",1)))
	demon_xp = maxf(0.0,float(c.get_value("run","demon_xp",0.0)))
	reserve_limit = int(c.get_value("run","reserve_limit",3))
	unlocked.assign(c.get_value("run","unlocked",["zombie"]))
	var known: Array = meta.get("codex",[])
	for id in unlocked:
		if not known.has(id): known.append(id)
	meta["codex"] = known
	save_meta()
	reserves.assign(c.get_value("run","reserves",[]))
	monsters.assign(c.get_value("run","monsters",[]))
	gems.assign(c.get_value("run","gems",[]))
	hero_chests.assign(c.get_value("run","hero_chests",[]))
	effects.assign(c.get_value("run","effects",[]))
	traps.assign(c.get_value("run","traps",[]))
	next_trap_at = float(c.get_value("run","next_trap_at",(floorf(elapsed/180.0)+1.0)*180.0))
	events.assign(c.get_value("run","events",[]))
	event_serial = int(c.get_value("run","event_serial",0))
	reward_ids.assign(c.get_value("run","reward_ids",[]))
	time_marks.assign(c.get_value("run","time_marks",[]))
	hp_marks.assign(c.get_value("run","hp_marks",[]))
	chest_marks.assign(c.get_value("run","chest_marks",[]))
	current_event = c.get_value("run","current_event",{})
	current_options.assign(c.get_value("run","current_options",[]))
	chosen_count = int(c.get_value("run","chosen_count",0))
	last_result = String(c.get_value("run","last_result",""))
	bat_clock = float(c.get_value("run","bat_clock",0.0))
	reserve_clock = float(c.get_value("run","reserve_clock",0.0))
	hero = c.get_value("run","hero",{})
	if not hero.has("slow_time"): hero["slow_time"] = 0.0
	if not hero.has("motion"): hero["motion"] = Vector2.RIGHT
	if not hero.has("armor_meta"): hero["armor_meta"] = 0
	if not hero.has("items"): hero["items"] = {}
	for id in WEAPONS:
		if not hero.has(id): hero[id] = 0
	for id in ["lightning_cd","fire_cd","arrow_cd"]:
		if not hero.has(id): hero[id] = 0.0
	boss = c.get_value("run","boss",{})
	boss_kind = String(c.get_value("run","boss_kind",""))
	boss_time = float(c.get_value("run","boss_time",0.0))
	boss_attack_cd = float(c.get_value("run","boss_attack_cd",0.0))
	boss_dash_cd = float(c.get_value("run","boss_dash_cd",0.0))
	boss_dash_time = float(c.get_value("run","boss_dash_time",0.0))
	boss_special_cd = float(c.get_value("run","boss_special_cd",0.0))
	arena_radius = float(c.get_value("run","arena_radius",330.0))
	demon_hp_bonus = float(c.get_value("run","demon_hp_bonus",0.0))
	demon_damage_bonus = float(c.get_value("run","demon_damage_bonus",0.0))
	elite_unlocked = bool(c.get_value("run","elite_unlocked",false))
	uid_counter = int(c.get_value("run","uid_counter",0))
	rng.state = int(c.get_value("run","rng_state",rng.state))
	if state == "title": state = "opening"

func _unhandled_input(event: InputEvent) -> void:
	if embedded_mode: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = event.position
		if state == "final" and p.x >= 1040.0 and p.y >= 475.0:
			var counter_index := int((p.y-475.0)/31.0)
			var available: Array[String] = []
			for id in COUNTERS:
				if unlocked.has(id): available.append(id)
			if counter_index >= 0 and counter_index < available.size(): reserve_squad(available[counter_index])
			queue_redraw()
			return
		if state == "observe" and p.x >= 875.0:
			if p.y >= 670.0:
				roster_page = (roster_page+1) % maxi(1,int(ceil(float(unlocked.size())/14.0)))
				queue_redraw()
				return
			var row := int((p.y - 251.0) / 56.0)
			var col := 0 if p.x < 1073.0 else 1
			var index := roster_page*14+row*2+col
			if p.y >= 251.0 and p.y < 643.0 and row >= 0 and index < unlocked.size(): reserve_squad(unlocked[index])
		elif state == "unlock" and p.x >= 230 and p.x < 1050 and p.y >= 298 and p.y < 488:
			var card_index := int((p.x - 230.0) / 275.0)
			choose_unlock(card_index)
		elif state == "chest" and p.y >= 325 and p.y <= 520: open_chest()
		elif state == "mini" or state == "final": boss_attack()
		queue_redraw()
		return
	if not (event is InputEventKey and event.pressed and not event.echo): return
	var key: int = event.keycode
	if state == "title":
		if key == KEY_ENTER: load_run()
		elif key == KEY_N or key == KEY_P: state = "prepare"
	elif state == "prepare":
		if key == KEY_C: codex_open = not codex_open
		elif codex_open and (key == KEY_ESCAPE or key == KEY_ENTER): codex_open = false
		elif not codex_open and key == KEY_ENTER: fresh_run()
		elif not codex_open and key >= KEY_1 and key <= KEY_4: buy_upgrade(key-KEY_1)
	elif state == "opening" and key == KEY_ENTER:
		state = "observe"
		notice = "박쥐는 자동 투입된다. 오른쪽 좀비를 클릭해 추가 분대를 예약하라."
		notice_time = 6.0
		save_run()
	elif state == "unlock" and key >= KEY_1 and key <= KEY_3:
		choose_unlock(key - KEY_1)
	elif state == "chest" and key == KEY_ENTER:
		open_chest()
	elif state == "chest_result" and key == KEY_ENTER:
		finish_event()
	elif state == "observe" and key >= KEY_1 and key <= KEY_9:
		var index := roster_page*14+key-KEY_1
		if index < unlocked.size(): reserve_squad(unlocked[index])
	elif state == "observe" and (key == KEY_Q or key == KEY_E):
		var pages := maxi(1,int(ceil(float(unlocked.size())/14.0)))
		roster_page = posmod(roster_page+(1 if key == KEY_E else -1),pages)
	elif state == "mini" or state == "final":
		if key == KEY_SPACE: boss_dash()
		elif key == KEY_Q: boss_special()
	elif state == "victory" or state == "defeat":
		if key == KEY_N: state = "prepare"
		elif key == KEY_ENTER: state = "title"
	queue_redraw()

func _process(delta: float) -> void:
	if embedded_mode: return
	var dt := minf(delta,0.05)
	if state == "observe" or state == "mini" or state == "final": update_simulation(dt)
	if notice_time > 0.0: notice_time = maxf(0.0,notice_time-dt)
	queue_redraw()

func set_notice(s: String) -> void:
	notice = s
	notice_time = 3.0

func reserve_squad(id: String) -> bool:
	if (state != "observe" and not (state == "final" and COUNTERS.has(id))) or not unlocked.has(id) or id == "bat": return false
	if reserves.size() >= reserve_limit:
		set_notice("예약 대기열이 가득 찼다.")
		return false
	var cost: float = TYPES[id]["cost"]
	if mana < cost:
		set_notice("마력이 부족하다.")
		return false
	mana -= cost
	reserves.append(id)
	set_notice("%s 분대 투입 준비." % TYPES[id]["name"])
	save_run()
	return true

func update_simulation(dt: float) -> void:
	elapsed += dt
	if not embedded_mode: mana = minf(mana_max,mana+mana_regen*dt)
	bat_clock += dt
	automatic_clock += dt
	reserve_clock += dt
	while bat_clock >= BAT_INTERVAL:
		bat_clock -= BAT_INTERVAL
		spawn_squad("bat")
	if automatic_clock >= 7.5:
		automatic_clock -= 7.5
		var auto_pool: Array[String] = ["rat"]
		if elapsed >= 180.0: auto_pool.append("crawler")
		if elapsed >= 360.0: auto_pool.append("mudling")
		var available: Array[String] = []
		for id in auto_pool:
			if meta.get("codex",[]).has(id): available.append(id)
		if not available.is_empty(): spawn_squad(available[rng.randi_range(0,available.size()-1)])
	if not embedded_mode and reserve_clock >= RESERVE_INTERVAL and not reserves.is_empty():
		reserve_clock -= RESERVE_INTERVAL
		spawn_squad(reserves.pop_front())
	update_monsters(dt)
	update_hero(dt)
	update_traps(dt)
	update_drops(dt)
	if state == "mini" or state == "final": update_boss(dt)
	if hero["hp"] <= 0.0:
		end_run(true,"영웅 격퇴. 악마의 영역을 지켰다.")
		return
	if state == "final" and boss["hp"] <= 0.0:
		end_run(false,"악마 대빵이 쓰러졌다. 영웅이 살아남았다.")
		return
	if not embedded_mode: check_events()
	if state == "mini" and elapsed >= BATTLE_TIME:
		boss.clear()
		boss_kind = ""
		state = "observe"
		if not events.is_empty(): show_next_event()
	if state == "observe" and elapsed >= BATTLE_TIME and events.is_empty(): start_boss("final")
	checkpoint_clock += dt
	if checkpoint_clock >= 30.0:
		checkpoint_clock = 0.0
		save_run()

func spawn_squad(id: String) -> void:
	var data: Dictionary = TYPES[id]
	var count: int = int(data["count"])+(int(elapsed/600.0)*2 if id == "bat" else 0)
	for i in count:
		if monsters.size() >= (embedded_monster_cap if embedded_mode else MAX_MONSTERS): break
		var a := rng.randf_range(0.0,TAU)
		var radius := rng.randf_range(190.0,290.0)
		var pos: Vector2 = hero["pos"] + Vector2(cos(a),sin(a))*radius
		pos.x = clampf(pos.x,20.0,838.0)
		pos.y = clampf(pos.y,112.0,680.0)
		if blocked_at(pos,12.0):
			pos = hero["pos"]+Vector2(cos(a+0.65),sin(a+0.65))*155.0
			pos.x = clampf(pos.x,20.0,838.0)
			pos.y = clampf(pos.y,112.0,680.0)
		if blocked_at(pos,12.0): continue
		var elite: bool = (uid_counter+1) % 38 == 0 or id == "giant" or id == "demon_guard"
		monsters.append(make_monster(id,pos,elite))

func monster_hp_multiplier(level: int) -> float:
	return 1.0+0.09*sqrt(float(maxi(0,level-1)))

func monster_damage_multiplier(level: int) -> float:
	return 1.0+0.06*sqrt(float(maxi(0,level-1)))

func make_monster(id: String, pos: Vector2, elite: bool = false) -> Dictionary:
	var data: Dictionary = TYPES[id]
	var level: int = maxi(1,monster_level) if embedded_mode else maxi(1,int(hero.get("level",1)))
	var power := 1.35 if float(data["cost"]) >= 60.0 else (1.12 if float(data["cost"]) >= 40.0 else 1.0)
	if COUNTERS.has(id): power = 1.55
	var hp: float = float(data["hp"])*monster_hp_multiplier(level)*(2.2 if elite else 1.0)*power
	var pacing := (0.30 if power > 1.0 else 0.18)+0.82*clampf(elapsed/1200.0,0.0,1.0)
	uid_counter += 1
	return {"id":uid_counter,"type":id,"pos":pos,"hp":hp,"max_hp":hp,"damage":float(data["damage"])*monster_damage_multiplier(level)*pacing*power*(1.25 if elite else 1.0),"level":level,"attack_cd":rng.randf_range(0.0,0.3),"skill_cd":rng.randf_range(0.0,2.0),"poison":0.0,"elite":elite}

func update_monsters(dt: float) -> void:
	for m in monsters:
		var data: Dictionary = TYPES[m["type"]]
		m["attack_cd"] = maxf(0.0,m["attack_cd"]-dt)
		m["skill_cd"] = maxf(0.0,float(m.get("skill_cd",0.0))-dt)
		var diff: Vector2 = hero["pos"]-m["pos"]
		var kind: String = m["type"]
		var speed: float = float(data["speed"])
		if kind in ["rat","bone_runner","abyss_knight","hound","carrion_crow","iron_boar"] and m["skill_cd"] <= 0.0:
			speed *= 2.5
			m["skill_cd"] = 2.8
		elif kind != "grave_digger":
			for ally in monsters:
				if ally["type"] in ["grave_digger","bone_drummer"] and ally["pos"].distance_to(m["pos"]) < 90.0: speed *= 1.18; break
		if kind in ["wraith","ghost","mist_stalker","burrow_mole"] and m["skill_cd"] <= 0.0 and diff.length() > 110.0:
			var jump: Vector2 = m["pos"]+diff.normalized()*minf(95.0,diff.length()-50.0)
			if not blocked_at(jump,8.0): m["pos"] = jump
			m["skill_cd"] = 5.0
		var attack_range := 105.0 if kind in ["ember_cultist","banshee","archer","cultist","blood_mage","lantern_wisp","web_spinner","crystal_archer","void_tether"] else (80.0 if kind in ["imp","frost"] else (55.0 if kind in ["bone_spearman","giant"] else 24.0))
		if diff.length() > attack_range: m["pos"] = move_clear(m["pos"],route_direction(m["pos"],hero["pos"])*speed*dt,7.0)
		elif m["attack_cd"] <= 0.0 and (attack_range < 50.0 or clear_line(m["pos"],hero["pos"])):
			var dealt := 0.0
			if kind in RANGED_TYPES:
				var velocity: Vector2 = diff.normalized()*235.0
				monster_shots.append({"pos":m["pos"],"velocity":velocity,"damage":m["damage"],"kind":kind,"life":1.1})
			else: dealt = damage_hero(float(m.get("damage",data["damage"])))
			if dealt > 0.0 and kind in ["mudling","banshee","frost","web_spinner","void_tether"]: hero["slow_time"] = maxf(float(hero["slow_time"]),0.55)
			if dealt > 0.0 and kind in ["sporeling","venom_moth","plague"]: hero["poison_time"] = maxf(float(hero.get("poison_time",0.0)),2.0)
			if dealt > 0.0 and kind in ["leech","blood_mage"]: m["hp"] = minf(float(m["max_hp"]),float(m["hp"])+dealt*0.6)
			m["attack_cd"] = 1.4 if kind in ["ember_cultist","banshee","archer","cultist","blood_mage"] else 0.62
	for i in range(monsters.size()-1,-1,-1):
		if monsters[i]["hp"] > 0.0: continue
		var fallen: Dictionary = monsters[i]
		hero["kills"] += 1
		gems.append({"pos":fallen["pos"],"value":2 if fallen["elite"] else 1})
		if fallen["elite"]: hero_chests.append({"pos":fallen["pos"]})
		if fallen["type"] == "split_slime" and not fallen.get("split_child",false) and monsters.size() < MAX_MONSTERS-2:
			for side in [-1,1]:
				var child: Dictionary = make_monster("split_slime",fallen["pos"]+Vector2(side*19,0))
				child["hp"] *= 0.25
				child["max_hp"] *= 0.25
				child["split_child"] = true
				monsters.append(child)
		if fallen["type"] == "ember_beetle" and hero["pos"].distance_to(fallen["pos"]) < 65.0: damage_hero(12.0)
		monsters.remove_at(i)
	update_monster_shots(dt)

func update_monster_shots(dt: float) -> void:
	for i in range(monster_shots.size()-1,-1,-1):
		var shot: Dictionary = monster_shots[i]
		shot["pos"] += shot["velocity"]*dt
		shot["life"] = float(shot["life"])-dt
		if float(shot["life"]) <= 0.0 or blocked_at(shot["pos"],3.0):
			monster_shots.remove_at(i)
		elif hero["pos"].distance_to(shot["pos"]) < 17.0:
			var dealt := damage_hero(float(shot["damage"]))
			if dealt > 0.0 and String(shot["kind"]) in ["banshee","frost","web_spinner","void_tether"]: hero["slow_time"] = maxf(float(hero["slow_time"]),0.55)
			monster_shots.remove_at(i)

func demon_xp_goal() -> float:
	return 100.0+75.0*float(demon_level-1)

func gain_demon_xp(amount: float) -> void:
	if embedded_mode and experience_sink.is_valid():
		experience_sink.call(amount)
		return
	demon_xp += amount
	while demon_xp >= demon_xp_goal():
		demon_xp -= demon_xp_goal()
		demon_level += 1
		mana_max += 5.0
		mana = minf(mana_max,mana+5.0)
		set_notice("악마 레벨 %d · 최대 마력과 현재 마력 +5" % demon_level)

func damage_hero(amount: float) -> float:
	if hero["invuln"] > 0.0 or hero["hp"] <= 0.0: return 0.0
	if hero["shield"] > 0:
		hero["shield"] -= 1
		return 0.0
	var cloak: float = float(hero.get("items",{}).get("glass_cloak",0))*0.04
	var dealt: float = minf(maxf(0.0,amount)*(1.0-0.07*float(hero.get("armor_meta",0))-cloak),float(hero["hp"]))
	hero["hp"] -= dealt
	total_damage += dealt
	gain_demon_xp(dealt)
	return dealt

func hit_monster(m: Dictionary, amount: float, source: String) -> void:
	if source == "blade" and m["type"] in ["shield_goblin","stone_golem","abyss_knight","rock_crab","grave_sentinel"]: amount *= 0.55
	if source == "blade" and m["type"] == "thornling": damage_hero(1.0)
	if String(TYPES[m["type"]].get("counter","")) == source and evolved.has(source):
		amount *= 0.58
		match String(m["type"]):
			"living_armor": damage_hero(1.0)
			"mirror_eye": hero["orb_cd"] = float(hero["orb_cd"])+0.12
			"blast_shell": m["hp"] = minf(float(m["max_hp"]),float(m["hp"])+6.0)
			"ground_golem": hero["lightning_cd"] = float(hero["lightning_cd"])+0.18
			"ash_phoenix": m["hp"] = minf(float(m["max_hp"]),float(m["hp"])+4.0)
			"eclipse_guard": hero["arrow_cd"] = float(hero["arrow_cd"])+0.18
	m["hp"] -= amount

func item_level(id: String) -> int:
	return int(hero.get("items",{}).get(id,0))

func update_traps(dt: float) -> void:
	while elapsed >= next_trap_at:
		next_trap_at += 180.0
		if traps.size() >= 2: continue
		var motion: Vector2 = hero.get("motion",Vector2.RIGHT)
		if motion.length_squared() < 0.01: motion = Vector2.RIGHT
		var pos: Vector2 = hero["pos"]+motion.normalized()*135.0
		pos.x = clampf(pos.x,55.0,800.0)
		pos.y = clampf(pos.y,140.0,645.0)
		if pos.distance_to(hero["pos"]) < 65.0:
			pos = hero["pos"]+Vector2(-motion.y,motion.x).normalized()*110.0
			pos.x = clampf(pos.x,55.0,800.0)
			pos.y = clampf(pos.y,140.0,645.0)
		if blocked_at(pos,28.0): continue
		traps.append({"pos":pos,"ttl":35.0})
		set_notice("정찰 보고: 전장에 악마 함정이 나타났다.")
	for i in range(traps.size()-1,-1,-1):
		var trap: Dictionary = traps[i]
		trap["ttl"] -= dt
		if hero["pos"].distance_to(trap["pos"]) <= 23.0:
			trigger_trap(trap["pos"])
			traps.remove_at(i)
		elif trap["ttl"] <= 0.0: traps.remove_at(i)

func trigger_trap(pos: Vector2) -> void:
	hero["slow_time"] = maxf(float(hero.get("slow_time",0.0)),1.25)
	for i in 4:
		if monsters.size() >= MAX_MONSTERS: break
		var angle := TAU*float(i)/4.0
		var spawn_pos: Vector2 = hero["pos"]+Vector2(cos(angle),sin(angle))*112.0
		spawn_pos.x = clampf(spawn_pos.x,30.0,830.0)
		spawn_pos.y = clampf(spawn_pos.y,122.0,666.0)
		if blocked_at(spawn_pos,10.0): continue
		monsters.append(make_monster("trap_elite",spawn_pos,true))
	effects.append({"pos":pos,"life":0.6,"kind":"trap"})
	set_notice("함정 발동. 정예 부대가 영웅을 포위한다!")
	save_run()

func update_hero(dt: float) -> void:
	if float(hero.get("regen",0.0)) > 0.0: hero["hp"] = minf(float(hero["max_hp"]),float(hero["hp"])+float(hero["regen"])*dt)
	for cd in ["lightning_cd","fire_cd","arrow_cd"]: hero[cd] = maxf(0.0,float(hero[cd])-dt)
	hero["poison_time"] = maxf(0.0,float(hero.get("poison_time",0.0))-dt)
	if hero["poison_time"] > 0.0: damage_hero(2.0*dt)
	hero["attack_cd"] = maxf(0.0,hero["attack_cd"]-dt)
	hero["orb_cd"] = maxf(0.0,hero["orb_cd"]-dt)
	hero["bomb_cd"] = maxf(0.0,hero["bomb_cd"]-dt)
	hero["invuln"] = maxf(0.0,hero["invuln"]-dt)
	hero["slow_time"] = maxf(0.0,float(hero.get("slow_time",0.0))-dt)
	hero["boss_hit_cd"] = maxf(0.0,hero.get("boss_hit_cd",0.0)-dt)
	hero["phase"] += dt*0.77
	var nearest: Dictionary = {}
	var nearest_d := INF
	for m in monsters:
		var d: float = hero["pos"].distance_to(m["pos"])
		if d < nearest_d:
			nearest_d = d
			nearest = m
	var threat_pos: Vector2 = nearest["pos"] if not nearest.is_empty() else Vector2.ZERO
	var threat_d: float = nearest_d
	if not boss.is_empty() and boss["hp"] > 0.0:
		var boss_d: float = hero["pos"].distance_to(boss["pos"])
		if boss_d < threat_d:
			threat_pos = boss["pos"]
			threat_d = boss_d
	var wander := Vector2(cos(hero["phase"]),sin(hero["phase"]*0.81)).normalized()
	var direction := wander
	if threat_d < 200.0:
		var away: Vector2 = (hero["pos"]-threat_pos).normalized()
		direction = (away*0.7+wander*0.3).normalized()
	elif not gems.is_empty() or not hero_chests.is_empty():
		var closest: Dictionary = hero_chests[0] if not hero_chests.is_empty() else gems[0]
		for gem in gems:
			if hero["pos"].distance_to(gem["pos"]) < hero["pos"].distance_to(closest["pos"]): closest = gem
		for chest in hero_chests:
			if hero["pos"].distance_to(chest["pos"]) < hero["pos"].distance_to(closest["pos"]): closest = chest
		if hero["pos"].distance_to(closest["pos"]) < 220.0: direction = (closest["pos"]-hero["pos"]).normalized()
	if direction.length_squared() < 0.01: direction = Vector2.RIGHT
	if hero["pos"].x < 75.0 and direction.x < 0.0: direction.x = absf(direction.x)
	if hero["pos"].x > 790.0 and direction.x > 0.0: direction.x = -absf(direction.x)
	if hero["pos"].y < 160.0 and direction.y < 0.0: direction.y = absf(direction.y)
	if hero["pos"].y > 620.0 and direction.y > 0.0: direction.y = -absf(direction.y)
	hero["motion"] = direction.normalized()
	hero["pos"] = move_clear(hero["pos"],direction.normalized()*(83.0+hero["level"]*1.1)*float(hero.get("speed_factor",1.0))*(0.52 if hero["slow_time"] > 0.0 else 1.0)*dt,12.0)
	hero["pos"].x = clampf(hero["pos"].x,42.0,814.0)
	hero["pos"].y = clampf(hero["pos"].y,124.0,664.0)
	if hero["attack_cd"] <= 0.0 and not nearest.is_empty() and nearest_d < 110.0 and clear_line(hero["pos"],nearest["pos"]):
		var hits := 0
		for m in monsters:
			if m["pos"].distance_to(nearest["pos"]) < 32.0:
				hit_monster(m,(21.0+hero["blade"]*6.0)*(1.0+float(meta.get("hero_weapon",0))*0.08+float(item_level("whetstone"))*0.05)*(1.55 if evolved.has("blade") else 1.0),"blade")
				hits += 1
				if hits >= 3: break
		effects.append({"pos":nearest["pos"],"life":0.22,"kind":"slash"})
		hero["attack_cd"] = maxf(0.38,0.9-hero["level"]*0.018)
	if hero["orb"] > 0 and hero["orb_cd"] <= 0.0:
		for m in monsters:
			if m["pos"].distance_to(hero["pos"]) < 92.0+hero["orb"]*12.0+item_level("magnet")*8.0 and clear_line(hero["pos"],m["pos"]): hit_monster(m,(10.0+hero["orb"]*5.0)*(1.6 if evolved.has("orb") else 1.0),"orb")
		hero["orb_cd"] = 1.65
		effects.append({"pos":hero["pos"],"life":0.28,"kind":"orb"})
	if hero["bomb"] > 0 and hero["bomb_cd"] <= 0.0 and not nearest.is_empty():
		for m in monsters:
			if m["pos"].distance_to(nearest["pos"]) < 95.0+(25.0 if evolved.has("bomb") else 0.0): hit_monster(m,(22.0+hero["bomb"]*9.0)*(1.0+item_level("ignition")*0.08),"bomb")
		hero["bomb_cd"] = 4.2
		effects.append({"pos":nearest["pos"],"life":0.43,"kind":"bomb"})
	if int(hero["lightning"]) > 0 and hero["lightning_cd"] <= 0.0:
		var struck := 0
		for m in monsters:
			if hero["pos"].distance_to(m["pos"]) < 190.0+item_level("coil")*14.0 and clear_line(hero["pos"],m["pos"]):
				hit_monster(m,14.0+int(hero["lightning"])*6.0,"lightning")
				struck += 1
				if struck >= (5 if evolved.has("lightning") else 2): break
		if struck > 0: effects.append({"pos":hero["pos"],"life":0.28,"kind":"lightning"})
		hero["lightning_cd"] = 2.2
	if int(hero["fire"]) > 0 and hero["fire_cd"] <= 0.0:
		for m in monsters:
			if hero["pos"].distance_to(m["pos"]) < 75.0+int(hero["fire"])*8.0 and clear_line(hero["pos"],m["pos"]): hit_monster(m,(12.0+int(hero["fire"])*5.0)*(1.7 if evolved.has("fire") else 1.0),"fire")
		effects.append({"pos":hero["pos"],"life":0.3,"kind":"fire"})
		hero["fire_cd"] = 1.1
	if int(hero["arrow"]) > 0 and hero["arrow_cd"] <= 0.0 and not nearest.is_empty() and nearest_d < 240.0+item_level("lens")*20.0 and clear_line(hero["pos"],nearest["pos"]):
		hit_monster(nearest,(16.0+int(hero["arrow"])*7.0)*(1.7 if evolved.has("arrow") else 1.0),"arrow")
		effects.append({"pos":nearest["pos"],"life":0.25,"kind":"arrow"})
		hero["arrow_cd"] = 1.0
	if not boss.is_empty() and boss["hp"] > 0.0 and hero["pos"].distance_to(boss["pos"]) < 155.0 and hero["boss_hit_cd"] <= 0.0:
		boss["hp"] -= 13.0+6.0*sqrt(float(maxi(0,int(hero["level"])-1)))
		if hero["orb"] > 0: boss["hp"] -= 2.0*hero["orb"]
		hero["boss_hit_cd"] = 0.65
	for fx in effects: fx["life"] -= dt
	for i in range(effects.size()-1,-1,-1):
		if effects[i]["life"] <= 0.0: effects.remove_at(i)

func update_drops(_dt: float) -> void:
	for i in range(gems.size()-1,-1,-1):
		if hero["pos"].distance_to(gems[i]["pos"]) > 29.0+item_level("magnet")*9.0: continue
		hero["xp"] += gems[i]["value"]
		gems.remove_at(i)
		while hero["xp"] >= hero["xp_goal"]:
			hero["xp"] -= hero["xp_goal"]
			hero_level_up()
	for i in range(hero_chests.size()-1,-1,-1):
		if not hero_chest_show.is_empty(): break
		if hero["pos"].distance_to(hero_chests[i]["pos"]) > 30.0: continue
		var count := roll_hero_chest_count()
		var granted: Array[String] = []
		var ids: Array[String] = []
		var grades: Array[int] = []
		var levels := {}
		for n in count:
			var candidates: Array[String] = []
			for weapon in WEAPONS:
				if int(hero[weapon])+int(levels.get(weapon,0)) < 5: candidates.append(weapon)
			for item in ITEMS:
				if item_level(item)+int(levels.get(item,0)) < 3: candidates.append(item)
			var id := candidates[rng.randi_range(0,candidates.size()-1)] if not candidates.is_empty() else "shield"
			ids.append(id)
			levels[id] = int(levels.get(id,0))+1
			granted.append(WEAPON_NAMES[WEAPONS.find(id)] if WEAPONS.has(id) else (ITEM_NAMES[ITEMS.find(id)] if ITEMS.has(id) else "방패"))
			var new_level := int(hero[id])+int(levels[id]) if WEAPONS.has(id) else (item_level(id)+int(levels[id]) if ITEMS.has(id) else 1)
			grades.append(2 if (WEAPONS.has(id) and new_level >= 5) or (ITEMS.has(id) and new_level >= 3) else (1 if new_level >= 3 else 0))
		hero_chest_show = {"time":2.6,"count":count,"rewards":granted,"ids":ids,"grades":grades,"pos":hero["pos"]}
		play_hero_chest_tone(count)
		hero_chests.remove_at(i)
		if embedded_mode and get_parent() != null and get_parent().get_parent() != null: get_parent().get_parent().save_game()
	if not hero_chest_show.is_empty():
		hero_chest_show["time"] = float(hero_chest_show["time"])-_dt
		if float(hero_chest_show["time"]) <= 0.0:
			for id in hero_chest_show.get("ids",[]): give_hero_weapon(String(id))
			hero_chest_show.clear()
			if embedded_mode and get_parent() != null and get_parent().get_parent() != null: get_parent().get_parent().save_game()

func roll_hero_chest_count() -> int:
	var value := rng.randi_range(0,99)
	return 1 if value < 72 else (3 if value < 95 else 5)

func play_hero_chest_tone(count: int) -> void:
	if hero_chest_audio == null: return
	var rate := 22050
	var duration := 0.28+float(count)*0.09
	var bytes := PackedByteArray()
	bytes.resize(int(duration*rate)*2)
	for i in int(duration*rate):
		var t := float(i)/float(rate)
		var freq := 440.0+float(count)*60.0+floorf(t*10.0)*55.0
		var volume := maxf(0.0,1.0-t/duration)
		var value := int(sin(TAU*freq*t)*volume*7500.0)
		bytes[i*2] = value & 255
		bytes[i*2+1] = (value >> 8) & 255
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = rate
	sound.data = bytes
	hero_chest_audio.stream = sound
	hero_chest_audio.play()

func hero_level_up() -> void:
	hero["level"] += 1
	hero["xp_goal"] += 3
	hero["max_hp"] += 5.0
	hero["hp"] = minf(hero["max_hp"],hero["hp"]+4.0)
	if not pending_evolutions.is_empty():
		var weapon: String = pending_evolutions.pop_front()
		if not evolved.has(weapon):
			evolved.append(weapon)
			counter_due.append({"weapon":weapon,"at":elapsed+120.0})
			set_notice("정찰 보고: 영웅이 %s을 완성했다." % ULTIMATE_NAMES[WEAPONS.find(weapon)])
	give_hero_weapon()
	if notice_time <= 0.0: set_notice("정찰 보고: 영웅 레벨 %d, 무장 강화." % hero["level"])

func give_hero_weapon(forced_id: String = "") -> String:
	var choices: Array[String] = []
	for weapon in WEAPONS:
		if int(hero[weapon]) < 5: choices.append(weapon)
	for item in ITEMS:
		if item_level(item) < 3: choices.append(item)
	if choices.is_empty():
		if int(hero["shield"]) < 8:
			hero["shield"] += 1
			return "방패"
		hero["hp"] = minf(float(hero["max_hp"]),float(hero["hp"])+10.0)
		return "치유"
	var id: String = forced_id if choices.has(forced_id) else choices[rng.randi_range(0,choices.size()-1)]
	if WEAPONS.has(id): hero[id] = int(hero[id])+1
	else:
		var items: Dictionary = hero["items"]
		items[id] = item_level(id)+1
		hero["items"] = items
	queue_ready_evolutions()
	return WEAPON_NAMES[WEAPONS.find(id)] if WEAPONS.has(id) else ITEM_NAMES[ITEMS.find(id)]

func queue_ready_evolutions() -> void:
	for index in WEAPONS.size():
		var weapon: String = WEAPONS[index]
		if int(hero[weapon]) >= 5 and item_level(ITEMS[index]) > 0 and not evolved.has(weapon) and not pending_evolutions.has(weapon): pending_evolutions.append(weapon)

func queue_event(kind: String, id: String, picks: int = 1) -> void:
	event_serial += 1
	events.append({"kind":kind,"id":id,"picks":picks,"serial":event_serial})

func check_events() -> void:
	for i in range(counter_due.size()-1,-1,-1):
		var due: Dictionary = counter_due[i]
		if elapsed < float(due["at"]): continue
		var weapon: String = due["weapon"]
		counter_due.remove_at(i)
		if not counter_opened.has(weapon): queue_event("counter_chest","counter_%s" % weapon)
	for minute in [300,600,900,1200,1500]:
		if elapsed >= minute and not time_marks.has(minute):
			time_marks.append(minute)
			queue_event("unlock","time_%d" % minute)
			if minute == 600 or minute == 1200: queue_event("chest","time_%d" % minute)
	for threshold in [75,50,25]:
		if hero["hp"] <= hero["max_hp"]*float(threshold)/100.0 and not hp_marks.has(threshold):
			hp_marks.append(threshold)
			queue_event("unlock","hp_%d" % threshold,2)
			queue_event("chest","hp_%d" % threshold)
	if state in ["observe","final","mini"] and not events.is_empty(): show_next_event()

func show_next_event() -> void:
	if events.is_empty(): return
	return_state = state
	current_event = events.pop_front()
	chosen_count = 0
	if current_event["kind"] == "unlock":
		state = "unlock"
		build_unlock_options()
	else: state = "chest"
	save_run()

func build_unlock_options() -> void:
	current_options.clear()
	var pool: Array[String] = []
	if String(current_event["id"]).begins_with("time_"):
		var moment := int(String(current_event["id"]).trim_prefix("time_"))
		for id in TIME_CARDS[moment]:
			if meta.get("codex",[]).has(id) and not unlocked.has(id): pool.append(id)
		for id in HP_CARDS:
			if meta.get("codex",[]).has(id) and not unlocked.has(id) and not pool.has(id): pool.append(id)
	else:
		for id in HP_CARDS:
			if meta.get("codex",[]).has(id) and not unlocked.has(id): pool.append(id)
	while current_options.size() < 3 and not pool.is_empty():
		var index := rng.randi_range(0,pool.size()-1)
		current_options.append(pool.pop_at(index))
	if current_options.is_empty(): current_options.append("mana_refill")

func choose_unlock(index: int) -> void:
	if state != "unlock" or index < 0 or index >= current_options.size(): return
	var id: String = current_options[index]
	if id == "mana_refill": mana = minf(mana_max,mana+40.0)
	elif not unlocked.has(id): unlocked.append(id)
	chosen_count += 1
	if chosen_count < int(current_event["picks"]):
		build_unlock_options()
	else: finish_event()
	save_run()

func open_chest() -> void:
	if state != "chest": return
	if current_event.get("kind","") == "counter_chest":
		var weapon := String(current_event["id"]).trim_prefix("counter_")
		if counter_opened.has(weapon): return
		counter_opened.append(weapon)
		var counter_id: String = COUNTERS[WEAPONS.find(weapon)]
		if not unlocked.has(counter_id): unlocked.append(counter_id)
		if not meta.get("codex",[]).has(counter_id):
			var found: Array = meta["codex"]
			found.append(counter_id)
			meta["codex"] = found
			save_meta()
		last_result = "%s 대응 전력 확보 · %s" % [ULTIMATE_NAMES[WEAPONS.find(weapon)],TYPES[counter_id]["name"]]
		state = "chest_result"
		current_event["reward"] = counter_id
		save_run()
		return
	var pool: Array[String] = ["mana_regen","mana_max","demon_hp","demon_damage","elite","mini_token"]
	if mana_regen >= 4.0: pool.erase("mana_regen")
	if mana_max >= 160.0: pool.erase("mana_max")
	if demon_hp_bonus >= 400.0: pool.erase("demon_hp")
	if demon_damage_bonus >= 40.0: pool.erase("demon_damage")
	if elite_unlocked or unlocked.has("demon_guard"): pool.erase("elite")
	var reward: String = pool[rng.randi_range(0,pool.size()-1)]
	if reward_ids.has(String(current_event["id"])): return
	reward_ids.append(String(current_event["id"]))
	match reward:
		"mana_regen": mana_regen += 0.5; last_result = "마력 회복 속도 +0.5/초"
		"mana_max": mana_max += 20.0; mana += 20.0; last_result = "최대 마력 +20"
		"demon_hp": demon_hp_bonus += 100.0; last_result = "최종 악마 최대 체력 +100"
		"demon_damage": demon_damage_bonus += 10.0; last_result = "최종 악마 공격력 +10"
		"elite": elite_unlocked = true; unlocked.append("demon_guard"); last_result = "악마 근위병 분대 해금"
		"mini_token": last_result = "중간보스 강림 인장 · 즉시 60초 출전"
	chest_marks.append(String(current_event["id"]))
	state = "chest_result"
	current_event["reward"] = reward
	save_run()

func finish_event() -> void:
	if state == "chest_result" and current_event.get("reward","") == "mini_token":
		current_event.clear()
		start_boss("mini")
		return
	current_event.clear()
	state = return_state if return_state in ["observe","mini","final"] else "observe"
	if not events.is_empty(): show_next_event()
	elif elapsed >= BATTLE_TIME and state == "observe": start_boss("final")
	else: save_run()

func start_boss(kind: String) -> void:
	boss_kind = kind
	boss_time = 0.0
	boss_attack_cd = 0.0
	boss_dash_cd = 0.0
	boss_dash_time = 0.0
	boss_special_cd = 0.0
	arena_radius = 330.0
	var level: int = maxi(1,int(hero["level"]))
	var grade := "보통"
	var grade_factor := 1.0
	if kind == "mini":
		match rng.randi_range(0,2):
			0: grade = "약함"; grade_factor = 0.8
			1: grade = "보통"; grade_factor = 1.0
			2: grade = "강함"; grade_factor = 1.2
	var final_rank := float(meta.get("demon_final",0))
	var hp: float = (1200.0 if kind == "mini" else 1100.0+demon_hp_bonus+final_rank*(350.0 if embedded_mode else 90.0))*monster_hp_multiplier(level)*grade_factor
	var spawn_pos: Vector2 = hero["pos"]+Vector2(-180,45)
	if blocked_at(spawn_pos,34.0): spawn_pos = hero["pos"]+Vector2(180,-45)
	boss = {"pos":spawn_pos,"hp":hp,"max_hp":hp,"level":level,"grade":grade,"grade_factor":grade_factor,"damage_mult":monster_damage_multiplier(level)*grade_factor*(1.0+final_rank*0.14 if embedded_mode and kind == "final" else 1.0)}
	state = kind
	set_notice("중간보스 강림 · 전력 %s · 최대 60초" % grade if kind == "mini" else "30분 경과. 악마 대빵이 직접 전장에 선다.")
	save_run()

func update_boss(dt: float) -> void:
	boss_time += dt
	boss_attack_cd = maxf(0.0,boss_attack_cd-dt)
	boss_dash_cd = maxf(0.0,boss_dash_cd-dt)
	boss_dash_time = maxf(0.0,boss_dash_time-dt)
	boss_special_cd = maxf(0.0,boss_special_cd-dt)
	var motion := Vector2.ZERO
	if embedded_mode and not manual_control:
		motion = route_direction(boss["pos"],hero["pos"])
		if boss_attack_cd <= 0.0: boss_attack()
		if boss_special_cd <= 0.0: boss_special()
	else:
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): motion.x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): motion.x += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): motion.y -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): motion.y += 1.0
	if motion.length_squared() > 0.0: boss["pos"] = move_clear(boss["pos"],motion.normalized()*(390.0 if boss_dash_time > 0.0 else (224.0 if state == "mini" else (270.0 if embedded_mode else 205.0)))*dt,15.0 if embedded_mode else 25.0)
	boss["pos"].x = clampf(boss["pos"].x,35.0,820.0)
	boss["pos"].y = clampf(boss["pos"].y,120.0,665.0)
	if embedded_mode and not manual_control and state == "final":
		if boss_attack_cd <= 0.0: boss_attack()
		if boss_special_cd <= 0.0: boss_special()
	if boss["pos"].distance_to(hero["pos"]) < 40.0 and boss_attack_cd <= 0.0 and clear_line(boss["pos"],hero["pos"]):
		damage_hero((13.0 if state == "mini" else 16.0+demon_damage_bonus*0.2)*float(boss.get("damage_mult",1.0)))
		boss_attack_cd = 0.45
	if state == "mini" and (boss_time >= 60.0 or boss["hp"] <= 0.0):
		boss.clear()
		boss_kind = ""
		state = "observe"
		set_notice("중간보스 철수. 투입 관리로 복귀.")
		if not events.is_empty(): show_next_event()
		elif elapsed >= BATTLE_TIME: start_boss("final")
		else: save_run()
	if state == "final":
		arena_radius = maxf(105.0,330.0-boss_time*0.9)
		var center := Vector2(427,390)
		for actor in [hero,boss]:
			if actor["pos"].distance_to(center) > arena_radius:
				actor["pos"] = center+(actor["pos"]-center).normalized()*arena_radius

func boss_attack() -> void:
	if boss.is_empty() or boss_attack_cd > 0.0: return
	if boss["pos"].distance_to(hero["pos"]) > (145.0 if state == "mini" else (140.0 if embedded_mode else 104.0)) or not clear_line(boss["pos"],hero["pos"]): return
	damage_hero((34.0 if state == "mini" else 48.0+demon_damage_bonus)*float(boss.get("damage_mult",1.0)))
	boss_attack_cd = 0.35
	effects.append({"pos":hero["pos"],"life":0.22,"kind":"boss"})

func boss_dash() -> void:
	if boss.is_empty() or boss_dash_cd > 0.0: return
	boss_dash_cd = 3.0
	boss_dash_time = 0.28

func boss_special() -> void:
	if boss.is_empty() or boss_special_cd > 0.0: return
	boss_special_cd = 8.0
	if boss["pos"].distance_to(hero["pos"]) < (245.0 if state == "mini" else (210.0 if embedded_mode else 180.0)) and clear_line(boss["pos"],hero["pos"]):
		damage_hero((70.0 if state == "mini" else 90.0+demon_damage_bonus*1.5)*float(boss.get("damage_mult",1.0)))
		effects.append({"pos":hero["pos"],"life":0.45,"kind":"boss"})

func end_run(won: bool, reason: String) -> void:
	state = "victory" if won else "defeat"
	last_result = reason
	current_event.clear()
	events.clear()
	if not embedded_mode: award_meta()
	save_run()

func award_meta() -> void:
	if payout_done or meta.get("completed",[]).has(run_id): return
	var survived := minf(elapsed,BATTLE_TIME)
	var earned := 0
	if survived < BATTLE_TIME and hero["hp"] <= 0.0:
		earned = 75+int((BATTLE_TIME-survived)/60.0)*3+mini(60,int(total_damage/80.0))
	else:
		earned = mini(65,15+int(total_damage/150.0))
	meta["demon_currency"] = int(meta["demon_currency"])+earned
	meta["total_seconds"] = float(meta["total_seconds"])+survived
	meta["total_damage"] = float(meta["total_damage"])+total_damage
	meta["hero_xp"] = int(meta["hero_xp"])+maxi(1,int(ceil(survived/240.0)))
	var cycle := 0
	while int(meta["hero_xp"]) >= hero_meta_goal() and cycle < 24 and int(meta["hero_hp"])+int(meta["hero_armor"])+int(meta["hero_weapon"]) < 18:
		meta["hero_xp"] = int(meta["hero_xp"])-hero_meta_goal()
		var keys := ["hero_hp","hero_armor","hero_weapon"]
		for offset in 3:
			var key: String = keys[(int(meta["hero_hp"])+int(meta["hero_armor"])+int(meta["hero_weapon"])+offset)%3]
			if int(meta[key]) < 6:
				meta[key] = int(meta[key])+1
				break
		cycle += 1
	refresh_codex()
	var completed: Array = meta["completed"]
	completed.append(run_id)
	meta["completed"] = completed
	payout_done = true
	save_meta()
	last_result += "  ·  악마 재화 +%d" % earned

func text_at(value: String, p: Vector2, size: int = 18, color: Color = Color.WHITE) -> void:
	draw_string(FONT,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func panel(r: Rect2, fill: Color = Color("1e2b2f")) -> void:
	draw_rect(r,fill)
	draw_rect(r,Color("66817b"),false,2.0)

func _draw() -> void:
	if embedded_mode:
		draw_battlefield()
		return
	if state == "title":
		draw_title()
		return
	if state == "prepare":
		draw_prepare()
		return
	if state == "opening":
		draw_opening()
		return
	draw_battlefield()
	draw_side_panel()
	if state == "unlock" or state == "chest" or state == "chest_result": draw_event_modal()
	elif state == "victory" or state == "defeat": draw_result()

func draw_title() -> void:
	draw_rect(Rect2(Vector2.ZERO,SCREEN),Color("111b24"))
	for i in 70:
		var x := float((i*157+33)%1280)
		var y := float((i*91+47)%720)
		draw_circle(Vector2(x,y),1.0 if i%3 else 2.0,Color("566b7a"))
	draw_circle(Vector2(634,257),117,Color("442d3f"))
	draw_circle(Vector2(634,257),88,Color("7e4c5b"))
	draw_colored_polygon(PackedVector2Array([Vector2(565,205),Vector2(534,145),Vector2(619,181),Vector2(670,181),Vector2(746,145),Vector2(711,217)]),Color("a36a68"))
	draw_circle(Vector2(602,250),10,Color("f5d893"))
	draw_circle(Vector2(670,250),10,Color("f5d893"))
	text_at("서바이버 등골 브레이커",Vector2(346,458),47,Color("f4d5a1"))
	text_at("관찰하고, 전선을 뒤집어라.",Vector2(496,508),21,Color("c9d9d4"))
	text_at("Enter  이어하기",Vector2(555,587),21)
	text_at("N  출전 준비",Vector2(572,625),19,Color("bcd6c5"))

func draw_prepare() -> void:
	draw_rect(Rect2(Vector2.ZERO,SCREEN),Color("17232b"))
	text_at("출전 준비 · 영구 전력",Vector2(344,78),36,Color("f4d5a1"))
	panel(Rect2(65,126,544,480),Color("273b3d"))
	panel(Rect2(671,126,544,480),Color("392e3e"))
	text_at("영웅의 성장 · 자동",Vector2(93,174),26,Color("d9e9e5"))
	text_at("최대 체력 +%d" % [int(meta["hero_hp"])*300],Vector2(94,230),20)
	text_at("받는 피해 -%d%%" % [int(meta["hero_armor"])*7],Vector2(94,270),20)
	text_at("검 피해 +%d%% · 시작 검 +%d" % [int(meta["hero_weapon"])*8,int(meta["hero_weapon"])/2],Vector2(94,310),20)
	text_at("성장 경험치 %d/%d" % [int(meta["hero_xp"]),hero_meta_goal()],Vector2(94,365),18)
	text_at("오래 살아남을수록 다음 판에 강해진다.",Vector2(94,420),17,Color("b8d1ca"))
	text_at("악마의 성장 · 선택",Vector2(701,174),26,Color("f4d5a1"))
	text_at("보유 재화 %d" % int(meta["demon_currency"]),Vector2(702,215),19)
	var keys := ["demon_mana","demon_regen","demon_reserve","demon_final"]
	var labels := ["시작·최대 마력", "마력 회복", "예약 대기열", "최종 악마 체력"]
	for i in 4:
		var key: String = keys[i]
		text_at("%d  %s  Lv%d/5 · %d 재화" % [i+1,labels[i],int(meta[key]),upgrade_cost(key)],Vector2(701,267+i*55),17)
	text_at("C  도감 %d/50종  ·  누적 전투 %d분" % [meta.get("codex",[]).size(),int(float(meta["total_seconds"])/60.0)],Vector2(81,649),18)
	text_at("1~4 강화 선택     Enter 출전",Vector2(800,649),18,Color("f4d5a1"))
	if codex_open: draw_codex()

func draw_codex() -> void:
	panel(Rect2(47,48,1186,624),Color("202e33"))
	text_at("몬스터 도감  %d/50" % meta.get("codex",[]).size(),Vector2(80,93),29,Color("f4d5a1"))
	text_at("C · Enter · Esc 닫기",Vector2(985,92),17)
	var all_ids: Array[String] = []
	for tier in META_TIERS:
		for id in tier: all_ids.append(id)
	for id in COUNTERS: all_ids.append(id)
	for index in all_ids.size():
		var id: String = all_ids[index]
		var known: bool = meta.get("codex",[]).has(id)
		var x := 75.0 if index < 25 else 665.0
		var y := 133.0+float(index%25)*20.0
		text_at("%02d  %s" % [index+1,TYPES[id]["name"] if known else "미확인"],Vector2(x,y),13,Color("e5dfca") if known else Color("788c91"))
		if known: text_at(monster_role(id),Vector2(x+170,y),11,Color("b6d0c0"))

func draw_opening() -> void:
	draw_rect(Rect2(Vector2.ZERO,SCREEN),Color("121923"))
	draw_rect(Rect2(0,430,1280,290),Color("24342f"))
	for i in 35:
		var x := float(i*43)
		draw_rect(Rect2(x,429-int(i%3)*8,5,94),Color("3d5047"))
		if i%4 == 0: draw_circle(Vector2(x+2,417),19,Color("405a4d"))
	draw_circle(Vector2(290,379),25,Color("8b79ae"))
	draw_colored_polygon(PackedVector2Array([Vector2(265,377),Vector2(223,353),Vector2(256,392)]),Color("6d658d"))
	draw_colored_polygon(PackedVector2Array([Vector2(315,377),Vector2(353,353),Vector2(324,392)]),Color("6d658d"))
	draw_rect(Rect2(887,241,145,230),Color("4c3640"))
	draw_colored_polygon(PackedVector2Array([Vector2(883,242),Vector2(853,170),Vector2(937,206),Vector2(1021,170),Vector2(1034,242)]),Color("8d6263"))
	draw_circle(Vector2(923,296),11,Color("f3d78c"))
	draw_circle(Vector2(989,296),11,Color("f3d78c"))
	panel(Rect2(118,501,1044,164),Color("1b2730"))
	text_at("정찰 보고",Vector2(155,540),19,Color("f0cd8e"))
	text_at("영웅이 악마의 영역에 진입했습니다.",Vector2(155,578),24)
	text_at("악마 대빵: 박쥐를 보내라. 놈이 얼마나 버티는지 보겠다.",Vector2(155,615),20)
	text_at("Enter  첫 전투 관찰",Vector2(906,649),16,Color("c1d4c8"))

func draw_battlefield() -> void:
	var controlled := state == "mini" or state == "final"
	var scale_x := 1.2 if controlled and not embedded_mode else 1.0
	draw_set_transform(Vector2.ZERO,0.0,Vector2(scale_x,1.0))
	var earth_colors := [Color("2a4038"),Color("38444a"),Color("49392f"),Color("493238")]
	var road_colors := [Color("485444"),Color("555656"),Color("675346"),Color("66484a")]
	draw_rect(Rect2(0,0,860,720),earth_colors[clampi(biome_id,0,3)])
	draw_rect(Rect2(0,279,860,210),road_colors[clampi(biome_id,0,3)])
	draw_rect(Rect2(0,312,860,5),road_colors[clampi(biome_id,0,3)].lightened(0.17))
	for i in 440:
		var x := float((i*109+17)%855)
		var y := float((i*137+71)%710)
		draw_rect(Rect2(x,y,3,2),Color("54745a") if y < 280 or y > 488 else Color("797f5d"))
	for obstacle in obstacles:
		var op: Vector2 = obstacle["pos"]
		if obstacle["kind"] == "tree":
			draw_circle(op+Vector2(4,12),30.0,Color(0.08,0.12,0.1,0.5))
			draw_rect(Rect2(op.x-7,op.y-13,14,35),Color("5b4539"))
			draw_rect(Rect2(op.x-3,op.y-10,4,27),Color("8b6a4d"))
			for offset in [Vector2(-15,-18),Vector2(13,-22),Vector2(0,-35)]:
				draw_circle(op+offset,18.0,Color("274d37"))
				draw_circle(op+offset+Vector2(-4,-4),11.0,Color("3e7051"))
		elif obstacle["kind"] == "bone":
			draw_circle(op+Vector2(4,9),27.0,Color(0.08,0.08,0.09,0.5))
			draw_line(op+Vector2(-18,15),op+Vector2(18,-14),Color("c6c1a9"),9.0)
			draw_circle(op+Vector2(17,-15),8.0,Color("ded9bd"))
		elif obstacle["kind"] in ["ruin","pillar"]:
			var shade := Color("9a897b") if obstacle["kind"] == "ruin" else Color("b16d70")
			draw_rect(Rect2(op-Vector2(23,24),Vector2(46,48)),shade.darkened(0.42))
			draw_rect(Rect2(op-Vector2(19,22),Vector2(37,35)),shade)
			draw_line(op+Vector2(-17,-10),op+Vector2(16,-13),shade.lightened(0.3),4.0)
		else:
			draw_circle(op+Vector2(5,9),28.0,Color(0.08,0.12,0.1,0.5))
			draw_colored_polygon(PackedVector2Array([op+Vector2(-27,11),op+Vector2(-21,-13),op+Vector2(-6,-24),op+Vector2(18,-16),op+Vector2(27,7),op+Vector2(10,21)]),Color("916d70") if obstacle["kind"] == "rubble" else Color("777f79"))
			draw_line(op+Vector2(-9,-16),op+Vector2(9,-18),Color("abb4a8"),4.0)
	for trap in traps:
		var tp: Vector2 = trap["pos"]
		draw_circle(tp,23.0,Color(0.36,0.12,0.17,0.68))
		draw_arc(tp,19.0,0.0,TAU,24,Color("e39772"),3.0)
		draw_line(tp+Vector2(-10,-10),tp+Vector2(10,10),Color("efbb82"),2.0)
		draw_line(tp+Vector2(10,-10),tp+Vector2(-10,10),Color("efbb82"),2.0)
	for g in gems:
		var p: Vector2 = g["pos"]
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-9),p+Vector2(6,0),p+Vector2(0,9),p+Vector2(-6,0)]),Color("79d9ec"))
	for chest in hero_chests:
		var p: Vector2 = chest["pos"]
		draw_rect(Rect2(p-Vector2(12,9),Vector2(24,19)),Color("ab8046"))
		draw_rect(Rect2(p-Vector2(10,12),Vector2(20,7)),Color("dfbe79"))
	for m in monsters:
		draw_monster(m)
	for shot in monster_shots:
		draw_circle(shot["pos"],5.0,Color("f4c48e") if shot["kind"] in ["imp","ember_cultist"] else Color("a9d6ed"))
	for fx in effects:
		var p: Vector2 = fx["pos"]
		var c := Color("f7b677") if fx["kind"] in ["bomb","fire"] else (Color("bca5e7") if fx["kind"] == "orb" else (Color("87cde9") if fx["kind"] == "lightning" else Color("f3e6bd")))
		draw_circle(p,10.0+fx["life"]*45.0,Color(c.r,c.g,c.b,minf(0.8,fx["life"]*2.0)))
	if not hero.is_empty():
		var p: Vector2 = hero["pos"]
		var class_colors := [Color("829ba7"),Color("76a28d"),Color("bd7463"),Color("a7a1ca")]
		draw_rect(Rect2(p.x-17,p.y+14,35,6),Color("15211f"))
		draw_rect(Rect2(p.x-16,p.y-20,32,37),class_colors[clampi(hero_class,0,3)])
		draw_rect(Rect2(p.x-12,p.y-32,24,17),Color("e7bd96"))
		draw_rect(Rect2(p.x-16,p.y-38,32,9),Color("58464d") if hero_class != 2 else Color("b04537"))
		draw_rect(Rect2(p.x-8,p.y-22,5,5),Color("efe6d6"))
		draw_rect(Rect2(p.x+4,p.y-22,5,5),Color("efe6d6"))
		if hero_class == 1:
			draw_arc(p+Vector2(22,-3),21.0,-1.3,1.3,14,Color("c9a87b"),3.0)
		elif hero_class == 2:
			draw_circle(p+Vector2(23,-13),8.0,Color("e7a068"))
		elif hero_class == 3:
			draw_circle(p+Vector2(23,-13),8.0,Color("efdcaf"))
		else:
			draw_line(p+Vector2(16,-23),p+Vector2(26,13),Color("bdc7c5"),4)
		if hero["orb"] > 0:
			for j in mini(3,int(hero["orb"])):
				var angle: float = elapsed*3.0+TAU*float(j)/float(mini(3,int(hero["orb"])))
				draw_circle(p+Vector2(cos(angle),sin(angle))*38.0,6,Color("e8a8dc"))
		bar(Rect2(p.x-33,p.y-48,66,5),float(hero["hp"])/float(hero["max_hp"]),Color("ee8e82"))
	if not hero_chest_show.is_empty():
		var center: Vector2 = hero_chest_show["pos"]
		var count: int = hero_chest_show["count"]
		for j in count:
			var endpoint := center+Vector2((float(j)-float(count-1)*0.5)*55.0,-95.0-14.0*sin(elapsed*8.0+float(j)))
			var grade: int = hero_chest_show.get("grades",[])[j] if hero_chest_show.has("grades") else 0
			var reward_color := Color("f1d486") if grade == 2 else (Color("93c8ef") if grade == 1 else Color("abb4b9"))
			draw_line(center,endpoint,reward_color,4.0)
			text_at(String(hero_chest_show["rewards"][j]),endpoint+Vector2(-19,-8),12,reward_color)
	if not boss.is_empty() and (state == "mini" or state == "final"):
		var bp: Vector2 = boss["pos"]
		if state == "mini":
			var aura := Color("e37d6b") if boss.get("grade","보통") == "강함" else (Color("9b91d4") if boss.get("grade","보통") == "약함" else Color("d0b37b"))
			draw_arc(bp,48.0,0.0,TAU,32,aura,4.0)
		draw_rect(Rect2(bp.x-33,bp.y-38,66,66),Color("3f2d3c"))
		draw_rect(Rect2(bp.x-28,bp.y-35,56,57),Color("92596d" if state == "final" else Color("826ca1")))
		draw_colored_polygon(PackedVector2Array([bp+Vector2(-28,-33),bp+Vector2(-43,-72),bp+Vector2(-8,-48),bp+Vector2(8,-48),bp+Vector2(43,-72),bp+Vector2(28,-33)]),Color("bd7a70"))
		draw_rect(Rect2(bp.x-18,bp.y-20,9,8),Color("f4d58a"))
		draw_rect(Rect2(bp.x+10,bp.y-20,9,8),Color("f4d58a"))
		bar(Rect2(bp.x-38,bp.y-88,76,7),float(boss["hp"])/float(boss["max_hp"]),Color("b17cc4"))
	if state == "final":
		draw_arc(Vector2(427,390),arena_radius,0.0,TAU,80,Color("de8f84"),5.0)
	draw_set_transform(Vector2.ZERO)
	if not embedded_mode:
		panel(Rect2(14,13,520,111),Color(0.09,0.16,0.18,0.94))
		text_at("1스테이지  %02d:%02d / 30:00" % [int(elapsed)/60,int(elapsed)%60],Vector2(31,44),19,Color("f2d89a"))
		text_at("영웅 Lv%d  ·  체력 %d/%d" % [hero.get("level",1),maxi(0,int(hero.get("hp",0))),int(hero.get("max_hp",1))],Vector2(31,78),17)
		text_at("영구 성장  체력 %d  방어 %d  무기 %d" % [int(meta.get("hero_hp",0)),int(meta.get("hero_armor",0)),int(meta.get("hero_weapon",0))],Vector2(31,107),15,Color("bfe3d7"))
		if not hero.is_empty(): draw_hero_gear()
		if notice_time > 0.0:
			panel(Rect2(120,139,620,48),Color(0.11,0.15,0.21,0.94))
			text_at(notice,Vector2(137,170),16)

func draw_hero_gear() -> void:
	for index in WEAPONS.size():
		var weapon: String = WEAPONS[index]
		var col := index%3
		var row := index/3
		var x := 14.0+float(col)*281.0
		var y := 568.0+float(row)*67.0
		var completed := evolved.has(weapon)
		var ready := pending_evolutions.has(weapon)
		panel(Rect2(x,y,273,61),Color(0.30,0.26,0.13,0.94) if completed else (Color(0.22,0.29,0.34,0.94) if ready else Color(0.09,0.17,0.2,0.9)))
		var weapon_name: String = ULTIMATE_NAMES[index] if completed else WEAPON_NAMES[index]
		text_at("%s  %d/5" % [weapon_name,int(hero[weapon])],Vector2(x+9,y+23),14,Color("f7df91") if completed else Color.WHITE)
		text_at("%s  %d/3" % [ITEM_NAMES[index],item_level(ITEMS[index])],Vector2(x+9,y+46),12,Color("d0e2d6"))
		text_at("완성" if completed else ("진화 대기" if ready else "조합"),Vector2(x+194,y+46),11,Color("f7df91") if completed or ready else Color("a8bdb6"))
	text_at("보석 %d/%d · 처치 %d · 방패 %d" % [hero["xp"],hero["xp_goal"],hero["kills"],hero["shield"]],Vector2(365,556),13,Color("d6e5db"))

func draw_monster(m: Dictionary) -> void:
	var data: Dictionary = TYPES[m["type"]]
	var p: Vector2 = m["pos"]
	var c: Color = data["color"]
	var id: String = m["type"]
	var family := String(data.get("family",""))
	if family == "":
		if id in ["bat","swarm","venom_moth","carrion_crow"]: family = "wing"
		elif id in ["skeleton","archer","bone_runner","bone_spearman","giant"]: family = "bone"
		elif id in ["ghost","frost","wraith","banshee","imp"]: family = "spirit"
		elif id in ["hound","rat","crawler"]: family = "beast"
		elif id in ["mudling","sporeling","plague"]: family = "slime"
		elif id in ["armored_zombie","shield_goblin","stone_golem","abyss_knight","demon_guard"]: family = "armor"
		else: family = "humanoid"
	var size := 20.0 if COUNTERS.has(id) or id in ["giant","stone_golem","abyss_knight"] else (10.0 if id in ["rat","sporeling"] else 14.0)
	var phase := sin(elapsed*6.0+float(int(m["id"])%7))*2.0
	draw_circle(p+Vector2(3,size*0.85),size*0.9,Color(0.05,0.08,0.08,0.4))
	match family:
		"wing":
			draw_colored_polygon(PackedVector2Array([p+Vector2(-4,-2),p+Vector2(-size*1.5,-12-phase),p+Vector2(-size*1.6,8),p+Vector2(-3,4)]),c.darkened(0.35))
			draw_colored_polygon(PackedVector2Array([p+Vector2(4,-2),p+Vector2(size*1.5,-12-phase),p+Vector2(size*1.6,8),p+Vector2(3,4)]),c.darkened(0.35))
			draw_circle(p,size*0.65,c)
		"beast":
			draw_circle(p+Vector2(0,2),size,c.darkened(0.3))
			draw_circle(p+Vector2(7,-3),size*0.64,c)
			for leg in [-1,1]: draw_line(p+Vector2(leg*7,8),p+Vector2(leg*9,17+phase),c.darkened(0.45),4.0)
		"bone":
			draw_line(p+Vector2(0,-5),p+Vector2(0,14),c,5.0)
			for rib in [-1,1]: draw_line(p+Vector2(0,2+rib*4),p+Vector2(11,2+rib*4),c,3.0)
			draw_circle(p+Vector2(0,-11),size*0.57,c.lightened(0.2))
		"spirit":
			draw_colored_polygon(PackedVector2Array([p+Vector2(-size,-7),p+Vector2(0,-size*1.4),p+Vector2(size,-7),p+Vector2(size*0.7,size),p+Vector2(0,size*0.55),p+Vector2(-size*0.7,size)]),c)
			draw_circle(p+Vector2(0,-5),size*0.55,c.lightened(0.2))
		"plant":
			draw_rect(Rect2(p-Vector2(5,1),Vector2(10,16)),c.darkened(0.35))
			for side in [-1,1]: draw_colored_polygon(PackedVector2Array([p,p+Vector2(side*size,-size),p+Vector2(side*size*0.7,7)]),c)
		"slime":
			draw_circle(p+Vector2(0,3),size,c.darkened(0.3))
			draw_circle(p+Vector2(-2,-2),size*0.7,c)
		"armor":
			draw_rect(Rect2(p-Vector2(size*0.75,size),Vector2(size*1.5,size*2)),c.darkened(0.4))
			draw_rect(Rect2(p-Vector2(size*0.55,size*0.8),Vector2(size*1.1,size*1.4)),c)
			draw_rect(Rect2(p.x-size*0.7,p.y-size*1.2,size*1.4,7),c.lightened(0.2))
		_:
			draw_rect(Rect2(p-Vector2(size*0.65,size*0.7),Vector2(size*1.3,size*1.6)),c.darkened(0.35))
			draw_circle(p+Vector2(0,-size*0.7),size*0.65,c)
	var mark: int = absi(id.hash())%4
	if mark == 0: draw_line(p+Vector2(size*0.6,-5),p+Vector2(size*1.3,-size*1.1),Color("d7d4bc"),3.0)
	elif mark == 1: draw_circle(p+Vector2(-size*0.7,-size),4.0,c.lightened(0.45))
	elif mark == 2: draw_rect(Rect2(p.x+size*0.5,p.y-4,5,size),c.darkened(0.6))
	else: draw_colored_polygon(PackedVector2Array([p+Vector2(-size*0.5,-size),p+Vector2(0,-size*1.6),p+Vector2(size*0.5,-size)]),c.lightened(0.3))
	draw_rect(Rect2(p.x-6,p.y-7,4,3),Color("f6e9cc"))
	draw_rect(Rect2(p.x+3,p.y-7,4,3),Color("f6e9cc"))
	if COUNTERS.has(id):
		draw_arc(p,size+7.0,0,TAU,24,Color("f1c976"),3.0)
		text_at(String(data["name"]),p+Vector2(-size*1.5,-size-20),12,Color("ffe4a7"))
	elif m["elite"]: draw_arc(p,size+5.0,0,TAU,18,Color("eaca80"),2.0)

func bar(r: Rect2, ratio: float, color: Color) -> void:
	draw_rect(r,Color("1a2529"))
	draw_rect(Rect2(r.position,Vector2(r.size.x*clampf(ratio,0,1),r.size.y)),color)

func draw_side_panel() -> void:
	var controlled := state == "mini" or state == "final"
	var x := 1031.0 if controlled else 861.0
	var width := SCREEN.x-x
	panel(Rect2(x,0,width,720),Color("19292f"))
	if controlled:
		text_at("%s 직접 조작" % ("중간보스" if state == "mini" else "악마 대빵"),Vector2(x+18,43),20,Color("f2d89a"))
		text_at("체력 %d/%d" % [maxi(0,int(boss["hp"])),int(boss["max_hp"])],Vector2(x+18,81),17)
		if state == "mini": text_at("남은 시간 %d초" % maxi(0,int(60.0-boss_time)),Vector2(x+18,112),15)
		else: text_at("결전 구역 축소 중",Vector2(x+18,112),15,Color("eea79b"))
		text_at("Lv%d · 전력 %s" % [int(boss.get("level",1)),String(boss.get("grade","보통"))],Vector2(x+18,142),15,Color("e7cda0"))
		text_at("WASD 이동",Vector2(x+18,180),16)
		text_at("좌클릭 공격  %dpx" % (145 if state == "mini" else 104),Vector2(x+18,210),14)
		text_at("Space 회피  %.1f초" % boss_dash_cd,Vector2(x+18,240),14)
		text_at("Q 광역  %dpx · %.1f초" % [245 if state == "mini" else 180,boss_special_cd],Vector2(x+18,270),13)
		text_at("악마 Lv%d  경험치 %d/%d" % [demon_level,int(demon_xp),int(demon_xp_goal())],Vector2(x+18,350),13,Color("c8d7bd"))
		text_at("영구 마력 %d · 결전 %d" % [int(meta.get("demon_mana",0)),int(meta.get("demon_final",0))],Vector2(x+18,330),12,Color("d2bde6"))
		text_at("박쥐 자동 투입",Vector2(x+18,379),15,Color("b9d9c0"))
		text_at("예약 %d/%d" % [reserves.size(),reserve_limit],Vector2(x+18,407),15)
		for i in mini(2,reserves.size()): text_at("%d. %s" % [i+1,TYPES[reserves[i]]["name"]],Vector2(x+18,445+i*24),13)
		if state == "final":
			var available: Array[String] = []
			for id in COUNTERS:
				if unlocked.has(id): available.append(id)
			for i in available.size():
				panel(Rect2(x+9,475+i*31,width-18,28),Color("514735"))
				text_at("%s  %d마력" % [TYPES[available[i]]["name"],int(TYPES[available[i]]["cost"])],Vector2(x+16,495+i*31),12,Color("ffe4ac"))
		return
	text_at("악마 전술실",Vector2(886,45),27,Color("f2d89a"))
	text_at("악마 Lv%d  경험치 %d/%d" % [demon_level,int(demon_xp),int(demon_xp_goal())],Vector2(886,78),16,Color("d8e3cf"))
	text_at("영구 마력%d  회복%d  예약%d  결전%d" % [int(meta.get("demon_mana",0)),int(meta.get("demon_regen",0)),int(meta.get("demon_reserve",0)),int(meta.get("demon_final",0))],Vector2(886,104),13,Color("d2bde6"))
	text_at("마력 %d/%d  ·  몬스터 Lv%d" % [int(mana),int(mana_max),int(hero.get("level",1))],Vector2(886,128),16)
	bar(Rect2(886,138,366,9),mana/mana_max,Color("ae8bdb"))
	text_at("예약 %d/%d" % [reserves.size(),reserve_limit],Vector2(886,171),16)
	for i in reserves.size():
		var label := "%d %s" % [i+1,TYPES[reserves[i]]["name"]]
		text_at(label,Vector2(886+(i%4)*90,190+(i/4)*18),11,Color("c7dcbd"))
	text_at("분대 클릭 · Q/E 목록 이동",Vector2(886,232),17,Color("d7e4db"))
	for i in range(roster_page*14,mini(unlocked.size(),(roster_page+1)*14)):
		var id: String = unlocked[i]
		var col := (i-roster_page*14)%2
		var row := (i-roster_page*14)/2
		var px := 877.0+float(col)*196.0
		var py := 251.0+float(row)*56.0
		if py > 650.0: break
		var affordable: bool = mana >= TYPES[id]["cost"] and reserves.size() < reserve_limit
		panel(Rect2(px,py,186,50),Color("31564c") if affordable else Color("354043"))
		text_at("%d %s" % [i-roster_page*14+1,TYPES[id]["name"]],Vector2(px+9,py+21),14)
		text_at("%d마력 · %d기" % [int(TYPES[id]["cost"]),int(TYPES[id]["count"])],Vector2(px+9,py+42),12,Color("c6d5cb"))
	var mouse: Vector2 = get_global_mouse_position()
	if mouse.x >= 877.0 and mouse.y >= 251.0 and mouse.y < 643.0:
		var hover_index := roster_page*14+int((mouse.y-251.0)/56.0)*2+(0 if mouse.x < 1073.0 else 1)
		if hover_index < unlocked.size(): text_at(monster_role(unlocked[hover_index]),Vector2(886,663),13,Color("e5d7a9"))
	text_at("목록 %d/%d  ›  자동 투입 포함 %d기" % [roster_page+1,maxi(1,int(ceil(float(unlocked.size())/14.0))),monsters.size()],Vector2(886,689),14,Color("b6cdbd"))

func draw_event_modal() -> void:
	draw_rect(Rect2(Vector2.ZERO,SCREEN),Color(0.03,0.05,0.08,0.75))
	if state == "unlock":
		panel(Rect2(160,160,960,430),Color("27383b"))
		text_at("새 몬스터 해금",Vector2(476,218),32,Color("f3d995"))
		text_at("후보 중 하나를 선택하라  ·  %d/%d" % [chosen_count+1,int(current_event["picks"])],Vector2(447,259),17)
		for i in current_options.size():
			var x := 230.0+float(i)*275.0
			panel(Rect2(x,300,255,184),Color("3b5149"))
			var id: String = current_options[i]
			var title: String = "마력 회복" if id == "mana_refill" else TYPES[id]["name"]
			text_at("%d" % [i+1],Vector2(x+20,336),16,Color("f3d995"))
			text_at(title,Vector2(x+20,388),23)
			if id != "mana_refill": text_at("%d마력 · %d기" % [int(TYPES[id]["cost"]),int(TYPES[id]["count"])],Vector2(x+20,429),17)
			if id != "mana_refill": text_at(monster_role(id),Vector2(x+20,458),13,Color("d6e3d0"))
		text_at("선택 중에는 전투와 시간이 멈춘다.",Vector2(467,548),16,Color("b9cfc7"))
	elif state == "chest":
		panel(Rect2(315,171,650,410),Color("303e3c"))
		text_at("궁극 무기 대응 상자" if current_event.get("kind","") == "counter_chest" else "악마의 전리품 상자",Vector2(456,242),31,Color("f3d995"))
		draw_rect(Rect2(550,324,180,117),Color("a67844"))
		draw_rect(Rect2(566,344,148,28),Color("d8b86b"))
		draw_rect(Rect2(621,325,38,117),Color("e7cf83"))
		text_at("Enter 또는 상자를 클릭해 보상 하나를 획득",Vector2(395,511),17)
	else:
		panel(Rect2(310,178,660,395),Color("303e3c"))
		text_at("상자 보상",Vector2(550,250),31,Color("f3d995"))
		text_at(last_result,Vector2(398,367),23)
		text_at("Enter  계속",Vector2(788,523),18)

func draw_result() -> void:
	draw_rect(Rect2(Vector2.ZERO,SCREEN),Color(0.03,0.05,0.08,0.75))
	panel(Rect2(230,187,820,374),Color("263a39"))
	text_at("영웅 격퇴 · 승리" if state == "victory" else "영웅 생존 · 패배",Vector2(440,271),34,Color("f3d995" if state == "victory" else Color("edaaa0")))
	text_at(last_result,Vector2(339,353),20)
	text_at("전투 시간  %02d:%02d" % [int(elapsed)/60,int(elapsed)%60],Vector2(517,420),19)
	text_at("N  새 게임     Enter  제목으로",Vector2(646,518),17)
