extends Control

var object : GameObject
var key : String

onready var label = $Label

var property_type

func _ready():
	label.text = key.capitalize()
	
	var value = object[key]
	var type = typeof(value)
	var type_scene_name := "None"
	if type == TYPE_VECTOR2:
		type_scene_name = "Vector2"
	elif type == TYPE_INT:
		type_scene_name = "int"
	elif type == TYPE_REAL:
		type_scene_name = "float"
	elif type == TYPE_STRING:
		type_scene_name = "string"
	elif type == TYPE_BOOL:
		type_scene_name = "bool"
	
	if type_scene_name != "None":
		var property_type_scene = load("res://scenes/editor/property_type_scenes/" + type_scene_name + "/" + type_scene_name + ".tscn")
		property_type = property_type_scene.instance()
		add_child(property_type)
		property_type.set_value(value)

func get_value():
	return property_type.get_value()

func update_value(value):
	object.set_property(key, value, true)