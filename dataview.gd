extends TextEdit

@export var filter : LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = JSON.stringify(DataManager.filter_data(filter.text), "\t")
