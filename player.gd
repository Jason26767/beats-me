#@tool
extends Node2D


@export var radius: float = 80.0
# Adjust the glow intensity by multiplying the color values
@export var glow_intensity: float = 1.4
@export var base_color: Color = Color.CYAN
@export var deviation_rightside: float = 0.5#is in percent of screen
@export var attack_movement: int = 40
@export var my_notes:Node
@export var controlling:bool

var current_glow:float = 1
var anchor_position: Vector2 = Vector2.ZERO
var deviation_vector: Vector2 = Vector2.ZERO

var glow_tween: Tween
var attack_tween: Tween

var on_measure:int = 1
var playing_note:int = 1
var wait:float = 0

@onready var timer:Node = $"../measure_timer"
		
func _ready() -> void:
	var viewport_size:Vector2 = get_viewport_rect().size
	position = Vector2.ZERO
	anchor_position = viewport_size/2
	anchor_position.x *= (1+deviation_rightside)
	wait = timer.wait_time/my_notes.shortest_note
	

func _process(delta:float) -> void:
	if (timer.wait_time - timer.time_left) >= ((wait*playing_note)):
		playing_note += 1
		#if not controlling:
			#print(on_measure)
			#print(playing_note)
			#print()
		if my_notes.rhythm[on_measure-1][playing_note-1]:
			move_for_attack()
	queue_redraw()

#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			##print("left click")
			#move_for_attack()
		
func pulse(fade_time: float):
	if glow_tween and glow_tween.is_running():
		glow_tween.kill()
	glow_tween = create_tween()
	glow_tween.tween_property(self, "current_glow", glow_intensity, 0.05)
	glow_tween.tween_property(self, "current_glow", 1, fade_time)
	
func move_for_attack():
	if attack_tween and attack_tween.is_running():
		attack_tween.kill()
	attack_tween = create_tween()
	pulse(0.3)
	deviation_vector.x  = -attack_movement
	attack_tween.tween_property(self, "deviation_vector:x", 0, 0.1)
	

func _draw():
	# Multiply RGB values by intensity to trigger the WorldEnvironment Bloom
	var hdr_color = Color(
		base_color.r * current_glow,
		base_color.g * current_glow,
		base_color.b * current_glow,
		base_color.a
	)
	#if current_glow != 1:
		#print(current_glow)
	
	# draw_arc arguments: center, radius, start_angle, end_angle, point_count, color, width, antialiased
	# 64 points ensures the circle stays smooth at larger sizes
	draw_circle(anchor_position + deviation_vector, radius, hdr_color, true)


func _on_measure_timer_timeout() -> void:
	#print(on_measure)
	#print(my_notes.rhythm[on_measure-1])
	if on_measure == 4:
		on_measure = 0
		#print("hi!")
	on_measure += 1
	playing_note = 1
	#print(on_measure)
	#print(playing_note)
	#print()
	if my_notes.rhythm[on_measure-1][playing_note-1]:
		move_for_attack()
