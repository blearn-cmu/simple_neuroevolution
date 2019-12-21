extends KinematicBody2D

export (int) var speed = 200
export (float) var rotation_speed = 1.5
export (float) var energy = 100

var id = 0

var velocity = Vector2()
var rotation_dir = 0
var tookAction = false
var score = 0.0
var best_score = 263.32

var NeuralNetwork = load("res://scripts/basic_nn.gd") # reference to Neural Network class
var nn = NeuralNetwork.new() # create instance of Neural Network

var food
var energyBar

var debug = true

func set_food(fud):
	self.food = fud

func update_engerybar(_energy):
	energyBar.set_value(_energy)

func get_input():
	rotation_dir = 0
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		rotation_dir += 1
	if Input.is_action_pressed('left'):
		rotation_dir -= 1
	if Input.is_action_pressed('down'):
		velocity = Vector2(-speed, 0).rotated(rotation)
	if Input.is_action_pressed('up'):
		velocity = Vector2(speed, 0).rotated(rotation)

func get_ai_input():
	# debug
	#nn.nn_feedforward()
	#nn.print_input_layer()
	#nn.print_output_layer()
	
	rotation_dir = 0
	velocity = Vector2()

	if nn.output_neurons[0] > 0.001: # left
		tookAction = true
		rotation_dir -= 1
	if nn.output_neurons[1] > 0.001: # right
		tookAction = true
		rotation_dir += 1
	if nn.output_neurons[2] > 0.001: # up
		tookAction = true
		velocity = Vector2(speed, 0).rotated(rotation)
		score += 0.001
	if nn.output_neurons[3] > 0.001: # down
		tookAction = true
		velocity = Vector2(-speed, 0).rotated(rotation)
		score += 0.001

func get_human_input():
	rotation_dir = 0
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		rotation_dir += 1
	if Input.is_action_pressed('left'):
		rotation_dir -= 1
	if Input.is_action_pressed('down'):
		velocity = Vector2(-speed, 0).rotated(rotation)
		score += 0.001
	if Input.is_action_pressed('up'):
		velocity = Vector2(speed, 0).rotated(rotation)

func ai_sense_env(): # gather info about environment to feed into the neural network
	var pos = self.position
	var target = food.position
	# debug
	#print(target)
	
	# distance and angle to target
	var dist = pos.distance_to(target)
	var char_normal = pos.rotated(rotation).normalized()
	var direction_vector = (target - pos).normalized()
	var ang = direction_vector.dot(char_normal) # value between -1 and 1. ang==0: angle=90;  ang>0: angle<90; ang<: angle>90
	
	var inputs = [pos.x, pos.y, dist, ang]
	
	# normalize the inputs
	inputs[0] = nn.normalize(inputs[0], 0, 1024) # character's x position
	inputs[1] = nn.normalize(inputs[1], 0, 608)  # character's y position
	inputs[2] = nn.normalize(inputs[2], 0, 1191) # distance to target
	inputs[3] = nn.normalize(inputs[3], -1, 1)  # "angle" to target; "facing target?"
	
	nn.update_inputs(inputs) # send inputs to nn
	nn.nn_feedforward()      # calculate nn's response to input

func reset():
	# record info
	if score > best_score:
		record_best()
	
	# reset variables
	energy = 100
	score = 0
	
	# mutate network
	#nn.randomize_nn()
	nn.nn_mutation()
	
	# respawn
	self.position = Vector2(524.0, 324.0)

func record_best():
	best_score = score
	print("New record! %f" % best_score)
	
	# update best score
	self.get_parent().get_node("best_score").text = "Best Score: %9.2f" % best_score
	
	# save NN parameters
	nn.save(id)

func _on_food_hit():
	energy = 100
	score += 10

func _physics_process(delta):
	ai_sense_env()
	get_ai_input()
	#get_human_input()
	
	# spend energy
	#if(tookAction == true): # action energy
	#	energy -= 0.1
	#	tookAction = false
	energy -= 0.2 # existense energy
	
	if(energy > 0.00): # move
		rotation += rotation_dir * rotation_speed * delta
		velocity = move_and_slide(velocity)

func _process(delta):
	score += delta
	
	update_engerybar(energy)
	if(energy <= -10.00): # die
		reset()

func _ready():
	self.energyBar = get_node("EnergyBar")
	self.id = get_parent().scene_id
	self.get_parent().get_node("best_score").text = "Best Score: %9.2f" % best_score
	
	if nn.load(id) == true: # try to load model
		print("model loaded")
	else:                 # create new randomized model
		print("failed to load model")
		nn.init_nn()
		nn.randomize_nn()
		nn.nn_feedforward()
