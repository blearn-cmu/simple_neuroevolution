extends Node2D

signal agent_done

var food
var character
export (String) var scene_id

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	food = get_node("food")
	food.reset()
	character = get_node("character")
	
	character.set_target(food)
	character.running = true
	character.connect("done", self, "_on_agent_done")
	
	print("scene: %s" % scene_id)

func set_perform_mode(_bool):
	$character.perform_mode = _bool

func set_running(_bool):
	$character.running = _bool

func get_top_score():
	return $character.best_score

func _on_agent_done(_id, _score):
	#print("agent %s complete" % _id)
	emit_signal("agent_done", _id, _score)
	#character.reset()
	#character.running = true

func _process(delta):
	$score.text = "%9.2f" % character.score

func _finalize():
	#character.nn.print_nn()
	pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		#character.nn.save()
		# hook to do things before the application quits
		get_tree().quit()