extends ColorRect

@export var speed:int = 400
@export var width:int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size:Vector2 = get_viewport_rect().size
	size = Vector2(width, 40)
	position.x = viewport_size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed*delta
	if position.x < -1* width:
		queue_free()
