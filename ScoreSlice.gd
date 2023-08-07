class_name ScoreSlice
extends Panel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handle_score()
	handle_timer()

func handle_score():
	
	var ct = DataManager.get_data("map/team_ct/score")
	if ct != null:
		%SCORERIGHT.text = str(ct)
	
	var t = DataManager.get_data("map/team_t/score")
	if t != null:
		%SCORELEFT.text = str(t)
	
	pass
	
func handle_timer():
	
	var time = DataManager.get_data("phase_countdowns/phase_ends_in")
	if time == null: return
	
	time = roundi(float(time))
	var minutes = int(time / 60)
	var seconds = int(time % 60)
	%TIMER.text = "%s:%02d" % [minutes, seconds]
	
	pass
