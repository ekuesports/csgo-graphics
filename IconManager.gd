#class_name IconManager
extends Node

const PATH = "res://graphics/icons/"

var icons : Dictionary

func _ready():
	register_contents(PATH)

func get_icon(key : StringName) -> Texture:
	var i = icons.get(key)
	if i == null: print("Could not find Icon %s" % [key])
	return i

func register_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var extensionless = file_name.substr(0, file_name.rfind("."))
			var extension = file_name.substr(file_name.rfind("."))
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				register_contents(path + file_name + "/")
			else:
				if extension != ".import":
					icons[extensionless] = load(path + file_name)
					#print("Registered %s." % [file_name])
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")