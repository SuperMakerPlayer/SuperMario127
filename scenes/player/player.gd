extends LevelDataLoader

func _ready():
	var data = LevelData.new()
	data.load_in(load("res://assets/level_data/test_level.tres").contents)
	load_in(data, data.areas[0])
	
func _process(delta):
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()

func switch_scenes():
	get_tree().change_scene("res://scenes/editor/editor.tscn")
