#@tool
extends Node2D

@export var initial_radius: float = 100.0
@export var shockwave_width = 10
# Adjust the glow intensity by multiplying the color values
@export var glow_intensity: float = 2.0
@export var base_color: Color = Color.CYAN
@export var speed: int = 200
@export var fade_speed: float = 0.1
		

var current_glow:float = 1
var draw_position: Vector2 = Vector2.ZERO
var tween: Tween
var radius: float
		
func _ready() -> void:
	position = Vector2.ZERO
	current_glow = glow_intensity
	radius = initial_radius
	

func _process(delta:float) -> void:
	radius += speed*delta;
	current_glow -= fade_speed*delta
	queue_redraw()
	if current_glow < 0:
		#print("I exited")
		queue_free()

#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#print("left click")
			#pulse()
	

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
	draw_arc(draw_position, radius, 0, TAU, 64, hdr_color, shockwave_width, true)
