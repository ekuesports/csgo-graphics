extends Button

@export var slice : PlayerSlice

# Called when the node enters the scene tree for the first time.
func _ready():
	self.toggled.connect(func(b): 
		if b:
			slice.on_target_death()
		else:
			slice.on_target_live()
	)

