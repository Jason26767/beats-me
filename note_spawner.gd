extends Node2D

@export var note_size: int
@export var note_color: Color
@export var total_measures: float
@export var shortest_note:int = 4
@export var go_down: int
@export_range(0, 1, 0.01) var note_chance: float

var measures:int = 4
var rhythm: Array = []
var beat_size:float = 0
var measures_past = 0
var carry_over: bool = false

@onready var timer:Node = $"../measure_timer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size:Vector2 = get_viewport_rect().size
	beat_size = viewport_size.x/(shortest_note*measures)
	create_notes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_notes() -> void:
	rhythm = []
	for i in range(measures):
		var meesure:Array = []
		for j in range(shortest_note):
			meesure.append(randf() < note_chance)
		rhythm.append(meesure)
	rhythm[0][0] = carry_over
	carry_over = randf() < note_chance
	rhythm[-1].append(carry_over)
	#print(rhythm)
	

#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			##print("left click")
			#create_notes()
			#queue_redraw()
	
func _draw() -> void:
	var beats = 0
	for measure in rhythm:
		for note in measure:
			if note:
				draw_circle(Vector2((beats*beat_size), go_down), note_size, note_color, false, total_measures)
			beats += 1
	#if carry_over:
		#draw_circle(Vector2((beats*beat_size), go_down), note_size, note_color, false, total_measures)


func _on_measure_timer_timeout() -> void:
	measures_past += 1
	if measures_past == 4:
		measures_past = 0
		#print("hi")
		create_notes()
		queue_redraw()
