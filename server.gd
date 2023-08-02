class_name server
extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var server = HttpServer.new()
	var r = examplerouter.new()
	r.gaming.connect(process_message)
	server.register_router("/", r)
	add_child(server)
	server.start()

func process_message(msg):
	var msg_dict = JSON.parse_string(msg)
	process_dict(msg_dict)

func process_dict(dict, layers = []):
	if layers.size() > 0:
		var peek = layers.back()
		if peek == "added": layers.pop_back()
		if peek == "previously": return
		#Reset weapons to clear grenades may now be gone
		if peek == "weapons": DataManager.reset_data("/".join(layers))

	if dict == null: return
	for key in dict.keys():
		var item = dict[key]
		if typeof(item) == TYPE_DICTIONARY:
			process_dict(item, layers + [key])
		else:
			var path = "/".join(layers + [key])
			DataManager.push_new_data(path, item)


class examplerouter extends HttpRouter:
	signal gaming
	func handle_post(request, response):
		response.send(200)
		gaming.emit(request.body)

	
