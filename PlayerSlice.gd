class_name PlayerSlice
extends Control

@export var target_steamid : int
@export var right_side : bool = false
@export var health_color : Color

var player_path : String :
	get:
		return "allplayers/%s" % [target_steamid]

var player_alive : bool

var observer_idx = 0

func _ready():
	observer_idx = int(self.name.substr(self.name.rfind("e") + 1))
	
	$"%HEALTHBAR".set("self_modulate", health_color)
	#TODO: FIND ALTERNATE SOLUTION FOR THIS????
	#$"%BOTTOMBAR".get_node("HorizMargins").set("modulate", Color.BLACK if health_color.v > 0.8 else Color.WHITE)

	if right_side:
		reflect_all_horizontal()

func _process(delta):
	var success = get_target()
	if not success: return

	handle_player_name()
	handle_player_money()
	handle_player_health()
	handle_player_alive()
	handle_player_armor()
	handle_player_weapons()

func fetch(path) -> Variant:
	return DataManager.get_data("%s/%s" % [player_path, path])

func get_target() -> bool:
	var players_dict = DataManager.get_data("allplayers")
	if players_dict == null: return false

	var steamids = players_dict.keys()
	for id in steamids:
		var oslot = DataManager.get_data("allplayers/%s/%s" % [id, "observer_slot"])
		if typeof(oslot) != TYPE_FLOAT : continue
		if int(oslot) == observer_idx:
			target_steamid = int(id)
			return true
	return false

func handle_player_name():
	$"%NAME".set("text", fetch("name"))

func handle_player_health():
	var health = fetch("state/health")
	$"%HEALTH".set("text", health)
	$"%HEALTHBAR".set("value", health)
	# var tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	# tween.tween_property($"%HEALTHBAR", "value", health, 5).set_ease(Tween.EASE_OUT)

func handle_player_alive():
	var new_value = fetch("state/health") > 0
	if player_alive != new_value:
		player_alive = new_value
		if player_alive:
			on_target_live()
		else:
			on_target_death()

func handle_player_money():
	$"%MONEY".set("text", "$%s" % [fetch("state/money")])

func handle_player_armor():
	var armor_value = fetch("state/armor")
	var helmet = fetch("state/helmet")

	if helmet: 
		$"%ARMOR".set("texture", IconManager.get_icon("armor_helmet"))
	else:
		if armor_value > 0: 
			$"%ARMOR".set("texture", IconManager.get_icon("armor"))
		else: 
			$"%ARMOR".set("texture", IconManager.get_icon("none"))

func handle_player_weapons():
	var weapons : Array[StringName] = ["","",""]
	var grenades : Array[StringName] = []
	var c4 : bool = false
	for i in range(0, 8):
		var weapon_name = fetch("weapons/weapon_%s/name" % [i])
		if typeof(weapon_name) != TYPE_STRING: continue
		match fetch("weapons/weapon_%s/type" % [i]):
			"Knife":
				weapons[2] = weapon_name
			"Pistol":
				weapons[1] = weapon_name
			"Grenade":
				if fetch("weapons/weapon_%s/ammo_reserve" % [i]) != 0:
					grenades.append(weapon_name)
			"C4":
				c4 = true
			_:
				weapons[0] = weapon_name

	var tex_rects = $"%WEAPONS".get_children()
	if not right_side: tex_rects.reverse()
	for i in range(0, 2):
		var icon : TextureRect = tex_rects[i]
		icon.texture = IconManager.get_icon("none")
		var weapon = weapons[i]
		if weapon == "": continue
		icon.texture = IconManager.get_icon(weapon)

	tex_rects = $"%GRENADES".get_children()
	if not right_side: tex_rects.reverse()
	for i in range(0, len(tex_rects)):
		var icon : TextureRect = tex_rects[i]
		icon.texture = IconManager.get_icon("none")
		if i >= len(grenades): continue
		var grenade = grenades[i]
		if grenade == "": continue
		icon.texture = IconManager.get_icon(grenade)

func on_target_death():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	if right_side: tween.tween_property($"%CONTAINER", "anchor_left", 0.25, 2).set_ease(Tween.EASE_OUT)
	else: tween.tween_property($"%CONTAINER", "anchor_right", 0.75, 2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"%STATS", "modulate", Color.TRANSPARENT, 0.66).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"%GRENADES", "modulate", Color.TRANSPARENT, 0.66).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"%BOTTOMBAR".get_node("HorizMargins"), "modulate", Color.TRANSPARENT, 0.66).set_ease(Tween.EASE_OUT)
	
func on_target_live():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	if right_side: tween.tween_property($"%CONTAINER", "anchor_left", 0, 2).set_ease(Tween.EASE_OUT)
	else: tween.tween_property($"%CONTAINER", "anchor_right", 1, 2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($"%STATS", "modulate", Color.WHITE, 1).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($"%GRENADES", "modulate", Color.WHITE, 1).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($"%BOTTOMBAR".get_node("HorizMargins"), "modulate", Color.WHITE, 1).set_ease(Tween.EASE_IN)

func reflect_all_horizontal(node = self):
	for child in node.get_children():
		#print("Reflecting %s." % [child])
		match child.get_class():
			"HBoxContainer":
				var child_children = child.get_children()
				child_children.reverse()
				for i in range(0, len(child_children) - 1):
					child.move_child(child_children[i], i)
				match child.alignment:
					BoxContainer.ALIGNMENT_BEGIN:
						child.alignment = BoxContainer.ALIGNMENT_END
					BoxContainer.ALIGNMENT_END:
						child.alignment = BoxContainer.ALIGNMENT_BEGIN
			
			"TextureRect":
				child.flip_h = true

			"TextureProgressBar":
				child.fill_mode = TextureProgressBar.FILL_RIGHT_TO_LEFT

			"Label":
				match child.horizontal_alignment:
					HORIZONTAL_ALIGNMENT_LEFT:
						child.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
					HORIZONTAL_ALIGNMENT_RIGHT:
						child.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

			"MarginContainer":
				match child.anchors_preset:
					Control.PRESET_RIGHT_WIDE:
						child.anchors_preset = Control.PRESET_LEFT_WIDE

		#print("Reflected %s." % [child])
		reflect_all_horizontal(child)
		
