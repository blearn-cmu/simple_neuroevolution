extends Node2D

onready var training_environment = preload("res://scenes/test_scene.tscn")

export (int) var population_size = 20
var running_agents = null

var update_timer = null

var agents = Array()
var scores = Array()

var top_agent = -1
var agent_label = null
var score_label = null

var performer_agent = null

func update_scores():
	for i in range(population_size):
		scores[i] = agents[i].get_top_score()

func selection():
	var _top_score = scores.max()
	var _top_agent = scores.find(_top_score)
	print("Best Score: %s [agent %s]" % [_top_score, _top_agent])
	
	if top_agent != _top_agent: # if new best performer found, copy and load that model
		top_agent = _top_agent
#		agents[top_agent].character.nn.save_model("A")
#		performer_agent.character.nn.load_model("A")
		agent_label.text = "Agent: %s" % top_agent
		score_label.text = "Score: %s" % _top_score

func _on_Update_Timer_timeout():
	#update_scores()
	#for i in range(population_size):
		#print("agent %s: %s" % [i, scores[i]])
	
	var _top_score = scores.max()
	var _top_agent = scores.find(_top_score)
	print("Best Score: %s [agent %s]" % [_top_score, _top_agent])
	
	if top_agent != _top_agent: # if new best performer found, copy and load that model
		top_agent = _top_agent
#		agents[top_agent].character.nn.save_model("A")
#		performer_agent.character.nn.load_model("A")
		agent_label.text = "Agent: %s" % top_agent
		score_label.text = "Score: %s" % _top_score

func _on_agent_done(_id, _score):
	print("Agent %s completed: %s" % [_id, _score])
	scores[_id] = _score
	running_agents -= 1
	
	if running_agents <= 0: # when population has completed
		# find most fit agents
		selection()

func _ready():
	# init 'best performer' display
	#performer_agent = training_environment.instance()
	#performer_agent.scene_id = "A"
	#performer_agent.set_perform_mode(true)
	#add_child(performer_agent)
	
	# init training population
	for i in range(population_size):
		agents.append(training_environment.instance())
		scores.append(0.0)
		agents[i].scene_id = i
		agents[i].hide()
		agents[i].connect("agent_done", self, "_on_agent_done") # issue
		agents[i].set_running(true)
		add_child(agents[i])
	
	running_agents = population_size
	
	# init score update timer
#	self.update_timer = Timer.new()
#	add_child(update_timer)
#
#	update_timer.connect("timeout", self, "_on_Update_Timer_timeout")
#	update_timer.set_wait_time(5.0)
#	update_timer.set_one_shot(false)
#	update_timer.start()
	
	# init labels
	agent_label = get_node("UI/Top Agent")
	score_label = get_node("UI/Top Score")

func _process(delta):
	#update_scores()
	pass
