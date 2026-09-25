extends Node2D

signal finished

const FONT = preload("res://fonts/NanumGothic-Regular.ttf")
var elapsed := 0.0
var sent := false
var sparks: Array[Vector2] = []

func _ready() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 991000
	for i in 90: sparks.append(Vector2(random.randf_range(0,1600),random.randf_range(0,900)))

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= 23.0: finish_intro()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE: finish_intro()
		elif event.keycode == KEY_ENTER: elapsed = minf(22.8,elapsed+5.0)

func finish_intro() -> void:
	if sent: return
	sent = true
	finished.emit()

func say(value: String, position: Vector2, size: int, color: Color = Color.WHITE) -> void:
	draw_string(FONT,position,value,HORIZONTAL_ALIGNMENT_CENTER,-1,size,color)

func demon_shape(pos: Vector2, scale_factor: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([pos+Vector2(-95,10)*scale_factor,pos+Vector2(-140,-100)*scale_factor,pos+Vector2(-26,-65)*scale_factor]),color.darkened(0.35))
	draw_colored_polygon(PackedVector2Array([pos+Vector2(95,10)*scale_factor,pos+Vector2(140,-100)*scale_factor,pos+Vector2(26,-65)*scale_factor]),color.darkened(0.35))
	draw_circle(pos,62.0*scale_factor,color)
	draw_colored_polygon(PackedVector2Array([pos+Vector2(-45,-30)*scale_factor,pos+Vector2(-65,-112)*scale_factor,pos+Vector2(-5,-55)*scale_factor]),Color("d9ad79"))
	draw_colored_polygon(PackedVector2Array([pos+Vector2(45,-30)*scale_factor,pos+Vector2(65,-112)*scale_factor,pos+Vector2(5,-55)*scale_factor]),Color("d9ad79"))
	draw_circle(pos+Vector2(-20,-6)*scale_factor,7.0*scale_factor,Color("ffe4a0"))
	draw_circle(pos+Vector2(20,-6)*scale_factor,7.0*scale_factor,Color("ffe4a0"))

func draw_castle() -> void:
	draw_rect(Rect2(0,0,1600,900),Color("131c33"))
	for star in sparks: draw_circle(star,1.5,Color("8795be"))
	for x in [130.0,390.0,670.0,930.0,1190.0,1430.0]:
		draw_rect(Rect2(x,290,125,370),Color("363749"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-20,290),Vector2(x+62,155),Vector2(x+145,290)]),Color("4d4560"))
		draw_rect(Rect2(x+48,375,22,70),Color("be566a"))
	draw_rect(Rect2(495,365,610,310),Color("494359"))
	draw_colored_polygon(PackedVector2Array([Vector2(460,365),Vector2(800,100),Vector2(1140,365)]),Color("5e5068"))
	draw_rect(Rect2(720,520,160,155),Color("161622"))
	draw_rect(Rect2(0,670,1600,230),Color("242c38"))
	for i in 30:
		var x := float(i)*54.0
		draw_circle(Vector2(x,720+float(i%4)*25.0),13.0,Color("6b334d"))
		draw_line(Vector2(x,737),Vector2(x,790),Color("78424d"),8.0)

func _draw() -> void:
	var phase := 0 if elapsed < 6.0 else (1 if elapsed < 11.0 else (2 if elapsed < 16.0 else 3))
	if phase == 0:
		draw_rect(Rect2(0,0,1600,900),Color("191326"))
		draw_rect(Rect2(0,680,1600,220),Color("31283d"))
		for i in 14:
			var ring := 65.0+float(i)*31.0+fmod(elapsed*105.0,30.0)
			draw_arc(Vector2(1090,400),ring,0.0,TAU,64,Color("8941a6",0.43),2.0)
		demon_shape(Vector2(410,535),1.7,Color("a83c68"))
		var fallen := elapsed > 4.5
		var rise := minf(1.0,elapsed/4.0)
		var hero_pos := Vector2(1080+sin(elapsed*9.0)*65.0,585-rise*310.0+sin(elapsed*5.0)*60.0)
		if fallen:
			hero_pos = Vector2(1080,lerpf(hero_pos.y,655.0,clampf((elapsed-4.5)*2.0,0.0,1.0)))
			draw_rect(Rect2(hero_pos+Vector2(-62,-16),Vector2(112,25)),Color("d6dbe6"))
			draw_circle(hero_pos+Vector2(63,-5),19.0,Color("f7dbbd"))
			draw_line(hero_pos+Vector2(-55,-8),hero_pos+Vector2(-105,-29),Color("e5f6ff"),7.0)
		else:
			draw_rect(Rect2(hero_pos+Vector2(-26,-42),Vector2(52,80)),Color("d6dbe6"))
			draw_circle(hero_pos+Vector2(0,-55),21.0,Color("f7dbbd"))
			draw_line(hero_pos+Vector2(28,-16),hero_pos+Vector2(70,-90),Color("e5f6ff"),7.0)
			for i in 7:
				var a := elapsed*3.0+float(i)*TAU/7.0
				draw_circle(hero_pos+Vector2(cos(a),sin(a))*95.0,7.0,Color("ec9df6"))
		say("디아블라 · 레벨 99 최상급 악마",Vector2(800,105),38,Color("ffe3aa"))
		say("영웅의 마지막 저항마저 그의 손안에서 무너졌다.",Vector2(800,790),25)
	else:
		draw_castle()
		if phase == 1:
			say("그날부터 전 세계는 악마의 시대가 되었다.",Vector2(800,760),31,Color("ffdea6"))
			say("영웅들은 디아블라에게 하나씩 패했다.",Vector2(800,812),25)
		elif phase == 2:
			draw_rect(Rect2(0,0,1600,900),Color("111724",0.70))
			say("그로부터 1000년 뒤",Vector2(800,360),49,Color("ffe5b2"))
			say("영웅들이 세상을 되찾기 위해 힘을 모으기 시작했다.",Vector2(800,445),29)
		else:
			draw_rect(Rect2(0,0,1600,900),Color("141a25",0.78))
			demon_shape(Vector2(800,510),0.67,Color("a94e73"))
			say("위대한 디아블라의 후손, 다블라",Vector2(800,230),39,Color("f1d59c"))
			say("레벨 1. 조상의 이름만으로는 영웅을 막을 수 없다.",Vector2(800,700),27)
	say("Enter 다음 장면    Esc 건너뛰기",Vector2(800,865),17,Color("aeb8c9"))
