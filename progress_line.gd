extends ColorRect

#@export var wait_time:float
@export var width:int 
@export var height: int

var viewport_size: Vector2
var speed: float = 0
var measures_past:int = 0

@onready var time_signiture: Node = $"../player_lines"
@onready var measure_timer_node: Node = $"../measure_timer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	size = Vector2(width, height)
	position = Vector2.ZERO
	var wait_time = measure_timer_node.wait_time
	speed = viewport_size.x/(wait_time*time_signiture.measures)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed*delta
	#if position.x > (viewport_size.x + width):


func _on_timer_timeout() -> void:
	measures_past += 1
	if measures_past == 4:
		position = Vector2.ZERO
		measures_past = 0
