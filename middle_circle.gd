#@tool
extends Node2D

@export var radius: float = 100.0:
	set(value):
		radius = value
		#queue_redraw()
		
@export var line_width: float = 4.0:
	set(value):
		line_width = value
		#queue_redraw()


# Adjust the glow intensity by multiplying the color values
@export var glow_intensity: float = 2.0:
	set(value):
		glow_intensity = value
		#queue_redraw()
		
@export var base_color: Color = Color.CYAN:
	set(value):
		base_color = value
		#queue_redraw()
		

var current_glow:float = 1
var draw_position: Vector2 = Vector2.ZERO

var tween: Tween

@export var shockwave_scene: PackedScene

@onready var timer_node: Node = $"../measure_timer"
@onready var time_signiture: Node = $"../player_lines"

var meter:int = 0
var wait: float = 0
var beat: int = 1

signal next_beat

		
func _ready() -> void:
	position = Vector2.ZERO
	var viewport_size:Vector2 = get_viewport_rect().size
	draw_position = viewport_size/2
	#print(draw_position)
	meter = time_signiture.meter
	wait = timer_node.wait_time/meter
	pulse(true)
	
	

func _process(delta:float) -> void:
	if (wait*meter - timer_node.time_left) >= (wait*beat):
		pulse(false)
		beat += 1
		next_beat.emit()
	queue_redraw()

#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			##print("left click")
			#pulse()
			
func create_shockwave():
	var shockwave_instance = shockwave_scene.instantiate()
	shockwave_instance.draw_position = draw_position
	shockwave_instance.base_color = base_color
	shockwave_instance.speed = 600
	shockwave_instance.fade_speed = 2
	shockwave_instance.initial_radius = radius
	shockwave_instance.glow_intensity = 1
	add_child(shockwave_instance)
	#print("newshockwave")
	
		
func pulse(shockwave: bool):
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "current_glow", glow_intensity, 0.05)
	tween.tween_property(self, "current_glow", 1, 0.4)
	if shockwave:
		create_shockwave()
	

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
	draw_arc(draw_position, radius, 0, TAU, 64, hdr_color, line_width, true)


func _on_timer_timeout() -> void:
	pulse(true)
	beat = 1
	next_beat.emit()
