extends Node2D

@onready var sword:Node = $sword
@onready var shield:Node = $shield

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sword.modulate.a = 0
	shield.modulate.a = 0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("left click")

func pulse_sword():
	pass
	
func pulse_shield():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
