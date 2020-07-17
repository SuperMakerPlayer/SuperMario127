extends Control

onready var left = $Left
onready var right = $Right

onready var value_text = $Value
var window_scale = 1

func _ready():
	window_scale = 5 if OS.window_fullscreen else (OS.window_size.x / 768)
	value_text.text = str(window_scale) if window_scale != 5 else "F"
	var _connect = left.connect("pressed", self, "decrease_value")
	var _connect2 = right.connect("pressed", self, "increase_value")

func decrease_value():
	window_scale -= 1
	if window_scale < 1:
		window_scale = 5
	process()

func increase_value():
	window_scale += 1
	if window_scale > 5:
		window_scale = 1
	process()

func process():
	OS.window_fullscreen = window_scale == 5
	OS.window_size = Vector2(768, 432) * window_scale
	value_text.text = str(window_scale) if window_scale != 5 else "F"
