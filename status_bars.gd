extends Node2D

@export var max_hp: int
@export var damage: int
@export var max_statuses: int
@export var regens: float
@export var mistake_cost: float
@export var bar_width: int
@export var outline_width: int

@export var player_color:Color
@export var enemy_color:Color
@export var fatigue_color:Color
@export var shock_color: Color

@export_range(0, 1, 0.01) var enemy_defend_miss: float
@export_range(0, 1, 0.01) var enemy_attack_miss: float
@export_range(0, 1, 0.01) var enemy_make_fatigue: float

var player_hp: float = 0
var player_shock: float = 0
var player_fatigue: float = 0
var enemy_hp: float = 0
var enemy_shock: float = 0
var enemy_fatigue: float = 0
var viewport_size: Vector2 = Vector2.ZERO

var player_hit: bool = false
var player_defended: bool = false
var enemy_hit: bool = true
var enemy_defended:bool = false

var on_measure:int = 0
var wait:float = 0
var beat_times:Array = []
var attack_margin = 0
var on_beat: int


@onready var player_notes: Node = $"../player_notes"
@onready var enemy_notes: Node = $"../enemy_notes"
@onready var timer: Node = $"../measure_timer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	player_hp = max_hp
	enemy_hp = max_hp
	wait = timer.wait_time/player_notes.shortest_note
	attack_margin = wait/2
	for i in range(player_notes.shortest_note):
		beat_times.append((player_notes.shortest_note-i)*wait)
	#print(beat_times)
	randomize()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	if (timer.wait_time - timer.time_left) > (on_beat*wait + attack_margin):
		if player_notes.rhythm[on_measure][on_beat]:
			if not player_hit:
				player_shock += mistake_cost
				if player_shock > max_statuses:
					player_shock = max_statuses
			if not enemy_defended:
				enemy_shock += mistake_cost
				if player_hit:
					enemy_hp -= calc_damage(player_fatigue, enemy_shock)
					#print(calc_damage(player_fatigue, enemy_shock))
					#print(pow(enemy_shock+1, 2))
					#print((damage/(4*log(player_fatigue+2.718)))*pow(enemy_shock+1, 2))
					if enemy_hp <= 0:
						print("player_wins")
						get_tree().quit()
		if enemy_notes.rhythm[on_measure][on_beat]:
			if not player_defended:
				if enemy_hit:
					player_hp -= calc_damage(enemy_fatigue, player_shock)
					if player_hp <= 0:
						print("enemy_wins")
						get_tree().quit()
				player_shock += mistake_cost
				if player_shock > max_statuses:
					player_shock = max_statuses
			if not enemy_hit:
				enemy_shock += mistake_cost
		#print("meep")
		on_beat += 1
		player_hit = false
		player_defended = false
	if enemy_fatigue > 0: 
		enemy_fatigue -= (regens*delta)
		if enemy_fatigue < 0:
			enemy_fatigue = 0
	if player_fatigue > 0:
		player_fatigue -= (regens*delta)
		if player_fatigue < 0:
			player_fatigue = 0
			
	if enemy_shock > 0:
		enemy_shock -= (regens*delta)
		if enemy_shock < 0:
			enemy_shock = 0
	if player_shock > 0:
		player_shock -= (regens*delta)
		if player_shock < 0:
			player_shock = 0

func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#player_hp -= damage
			#enemy_hp -= damage
			#enemy_fatigue += mistake_cost
			#player_fatigue += mistake_cost
			#enemy_shock += mistake_cost
			#player_shock += mistake_cost
	var hit_beat = 0
	
	for i in range(len(beat_times)):
		if abs(timer.time_left-beat_times[i]) < attack_margin:
			hit_beat = i
	var observed_measure = on_measure
	if hit_beat == 0:
		if timer.time_left < attack_margin:
			observed_measure += 1
		if observed_measure == player_notes.total_measures:
			observed_measure = player_notes.total_measures - 1
			hit_beat = player_notes.shortest_note
	#print(hit_beat)
	#print(on_measure)
	#print("meep\n")
	if event.is_action_pressed("attack"):
		if player_notes.rhythm[observed_measure][hit_beat] and not player_hit:
			print("HIT!")
			player_hit = true
		else:
			print("FATIGUE")
			print("FATIGUE")
			if player_fatigue <= max_statuses:
				player_fatigue += mistake_cost
			else:
				player_hp -= mistake_cost
	if event.is_action_pressed("defend"):
		if enemy_notes.rhythm[observed_measure][hit_beat] and not player_defended:
			print("DEFENDED!")
			player_defended = true
		else:
			print("FATIGUE")
			if player_fatigue <= max_statuses:
				player_fatigue += mistake_cost
			else:
				player_hp -= mistake_cost

func _draw():
	var half_view_width = viewport_size.x/2
	
	#bars
	var enemy_health_offset = (1-enemy_hp/max_hp)*half_view_width
	var enemy_fatigue_offset = (1-enemy_fatigue/max_statuses)*half_view_width
	var enemy_shock_offset = (1-enemy_shock/max_statuses)*half_view_width
	
	draw_rect(Rect2(enemy_health_offset, viewport_size.y - bar_width*3, half_view_width - enemy_health_offset, bar_width), enemy_color)
	draw_rect(Rect2(enemy_fatigue_offset, viewport_size.y - bar_width*2, half_view_width - enemy_fatigue_offset, bar_width), fatigue_color)
	draw_rect(Rect2(enemy_shock_offset, viewport_size.y - bar_width, half_view_width - enemy_shock_offset, bar_width), shock_color)
	
	var player_health_offset = (player_hp/max_hp)*half_view_width
	var player_fatigue_offset = (player_fatigue/max_statuses)*half_view_width
	var player_shock_offset = (player_shock/max_statuses)*half_view_width
	
	draw_rect(Rect2(half_view_width, viewport_size.y - bar_width*3, player_health_offset, bar_width), player_color)
	draw_rect(Rect2(half_view_width, viewport_size.y - bar_width*2, player_fatigue_offset, bar_width), fatigue_color)
	draw_rect(Rect2(half_view_width, viewport_size.y - bar_width, player_shock_offset, bar_width), shock_color)
	
	#outlines
	draw_rect(Rect2(0, viewport_size.y - bar_width*3, half_view_width, bar_width), enemy_color, false, outline_width)
	draw_rect(Rect2(0, viewport_size.y - bar_width*2, half_view_width, bar_width), enemy_color, false, outline_width)
	draw_rect(Rect2(0, viewport_size.y - bar_width, half_view_width, bar_width), enemy_color, false, outline_width)
	draw_rect(Rect2(half_view_width, viewport_size.y - bar_width*3, half_view_width, bar_width), player_color, false, outline_width)
	draw_rect(Rect2(half_view_width, viewport_size.y - bar_width*2, half_view_width, bar_width), player_color, false, outline_width)
	draw_rect(Rect2(half_view_width, viewport_size.y - bar_width, half_view_width, bar_width), player_color, false, outline_width)
	
	#center line
	draw_line(Vector2(half_view_width, viewport_size.y - bar_width*3 - 0.5*outline_width), Vector2(half_view_width, viewport_size.y), Color.WHITE, 2*outline_width)
	



func _on_measure_timer_timeout() -> void:
	#print(on_measure)
	#print(my_notes.rhythm[on_measure-1])
	on_measure += 1
	if on_measure == 4:
		on_measure = 0
	on_beat = 0
		#print("hi!")
	#print(on_measure)
	#print()


func _on_middle_pulser_next_beat() -> void:
	enemy_defended = randf() > enemy_defend_miss
	enemy_hit = randf() > enemy_attack_miss
	if randf() < enemy_make_fatigue:
		if enemy_fatigue <= max_statuses:
			enemy_fatigue += mistake_cost
		else:
			enemy_hp -= mistake_cost

func calc_damage(hitter_fatigue, hittee_shock) -> float:
	return (damage/(4*log(hitter_fatigue+1.28)))*pow(hittee_shock+1, 2)
	#if player_did_damage:
		#enemy_hp -= (damage/(2*log(player_fatigue+2.718)))*pow(enemy_shock+1, 2)
	#else:
		#player_hp -= (damage/(5*log(enemy_fatigue+2.718)))*pow(player_shock+1, 2)
	
