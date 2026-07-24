extends Node2D

@export var line_width: int
@export var measures: int
@export var line_height: int
@export var sub_line_height: int
@export var meter: int
@export var go_down: int
@export var line_color: Color = Color(255, 255, 255)

var line_y: float = 0
var viewport_size:Vector2 = Vector2.ZERO
var spacing: float = 0
var sub_spacing: float = 0
var sub_y_down: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(0, go_down)
	viewport_size = get_viewport_rect().size
	line_y = line_height/2
	spacing = viewport_size.x/measures
	sub_spacing = spacing/meter
	sub_y_down = (line_height-sub_line_height)/2
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	var start = Vector2(0, line_y)
	var end = Vector2(viewport_size.x, line_y)
	# Built-in engine method
	draw_line(start, end, line_color, line_width)
	for i in range(measures+1):
		start = Vector2(spacing*i, 0)
		end = Vector2(spacing*i, line_height)
		draw_line(start, end, line_color, line_width)
		for j in range(meter-1):
			var x_over = spacing*i + sub_spacing*(j+1)
			start = Vector2(x_over, sub_y_down)
			end = Vector2(x_over, sub_line_height+sub_y_down)
			draw_line(start, end, line_color, line_width/4)
