extends Node

var autosave_interval = 60 * 5
var timer = 0.0

func _ready():
	timer = autosave_interval

func _physics_process(delta):
	timer -= delta
	if timer <= 0:
		timer = autosave_interval
		save()

func save():
	if "mode" in get_tree().current_scene and get_tree().current_scene.mode == 1:
		var saved_file = File.new()
		saved_file.open("user://autosave.txt", File.WRITE)
		saved_file.store_line(CurrentLevelData.level_data.get_encoded_level_data())
		saved_file.close()
		print("Autosaved level")
