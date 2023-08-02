#class_name DataManager
extends Node

var data : Dictionary

func push_new_data(path : String, value : Variant):
	#print("New value for %s: %s" % [path, value])
	var working_dict : Dictionary = data
	var layers = Array(path.split("/"))
	for layer in layers.slice(0,-1):
		var temp = working_dict.get(layer)
		if temp == null or typeof(temp) != TYPE_DICTIONARY:
			working_dict[layer] = {}
		working_dict = working_dict[layer]
	working_dict[layers.back()] = value

func reset_data(path : String):
	var working_dict : Dictionary = data
	var layers = Array(path.split("/"))
	for layer in layers:
		if layer == "": continue
		var working_item = working_dict.get(layer)
		if working_item == null: return null
		if typeof(working_item) != TYPE_DICTIONARY: return working_item
		working_dict = working_item
	working_dict.clear()

func get_data(path : String = "") -> Variant:
	var working_dict : Dictionary = data.duplicate(true)
	var layers = Array(path.split("/"))
	for layer in layers:
		if layer == "": continue
		var working_item = working_dict.get(layer)
		if working_item == null: return null
		if typeof(working_item) != TYPE_DICTIONARY: return working_item
		working_dict = working_item
	return working_dict

func filter_data(path : String = "") -> Variant:
	var working_dict : Dictionary = data.duplicate(true)
	var layers = Array(path.split("/"))
	for layer in layers:
		if layer == "": continue
		for key in working_dict.keys():
			if key != layer:
				working_dict.erase(key)
	return working_dict
