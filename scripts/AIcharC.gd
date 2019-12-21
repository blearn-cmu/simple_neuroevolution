extends KinematicBody2D

export (int) var speed = 200
export (float) var rotation_speed = 1.5
export (float) var energy = 100

var id = 0

var nn
var target
var energyBar

var size = Vector2()
var velocity = Vector2()
var rotation_dir = 0

var score = 0.0
var best_score = 0.0

var perform_mode = false

func set_target(_target):
	self.target = _target

func update_engerybar(_energy):
	energyBar.set_value(_energy)

func get_ai_input():
	rotation_dir = 0
	velocity = Vector2()
	var output_neurons = nn.get_output()

	if output_neurons[0] > 0.001: # left
		rotation_dir -= 1
	if output_neurons[1] > 0.001: # right
		rotation_dir += 1
	if output_neurons[2] > 0.001: # up
		velocity = Vector2(speed, 0).rotated(rotation)
		score += 0.001
	if output_neurons[3] > 0.001: # down
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
	var _char = get_centered_pos() # character's position
	var _target = target.position  # target's position
	
	# distance and angle to target
	var dist = _char.distance_to(_target)
	var char_normal = _char.rotated(rotation).normalized()
	var direction_vector = (_target - _char).normalized()
	var ang = direction_vector.dot(char_normal) # value between -1 and 1. ang==0: angle=90;  ang>0: angle<90; ang<: angle>90
	
	var inputs = [_char.x, _char.y, dist, ang]
	
	# normalize the inputs
	inputs[0] = nn.normalize(inputs[0], 0, 1024) # character's x position
	inputs[1] = nn.normalize(inputs[1], 0, 608)  # character's y position
	inputs[2] = nn.normalize(inputs[2], 0, 1191) # distance to target
	inputs[3] = nn.normalize(inputs[3], -1, 1)  # "angle" to target; "facing target?"
	
	nn.set_inputs(inputs) # send inputs to nn
	nn.feedforward()      # calculate nn's response to input

func reset():
	# record info
	if score > best_score:
		record_best()
	
	# reset variables
	energy = 100
	score = 0
	
	# mutate network
	if !perform_mode:
		nn.mutation(0.001)
	else:
		target.reset()
	
	# respawn
	self.position = Vector2(524.0, 324.0)

func get_centered_pos():
	var _x = self.position.x + (self.size.x/2)
	var _y = self.position.y + (self.size.y/2)
	var c = Vector2(_x, _y)
	return c

func record_best():
	#print("New record! %f" % best_score)
	self.best_score = self.score
	nn.set_fitness(score)
	
	# update UI
	self.get_parent().get_node("best_score").text = "Best Score: %9.2f" % best_score
	
	# save NN parameters
	nn.save_model(id)

func _on_food_hit():
	energy = 100
	score += 10

func _physics_process(delta):
	ai_sense_env()
	get_ai_input()
	
	#energy -= 10 * delta # existense energy cost
	energy -= 10 # existense energy cost
	
	if(energy > -0.0001): # move
		#rotation += rotation_dir * rotation_speed * delta
		#velocity = move_and_slide(velocity)
		rotation += rotation_dir * rotation_speed
		var collision = move_and_collide(velocity)
		if collision:
			velocity = velocity.slide(collision.normal)

func _process(delta):
	#score += 1.0 * delta
	score += 1.0
	
	update_engerybar(energy)
	if(energy < -10.00): # die
		reset()

func _ready():
	self.nn = get_node("DeepNN")
	self.size = get_node("Sprite").get_rect().size
	self.energyBar = get_node("EnergyBar")
	self.id = get_parent().scene_id
	
	if nn.load_model(id) == true: # try to load model
		print("model loaded")
		self.best_score = nn.get_fitness()
	else:                 # create new randomized model
		print("failed to load model")
		var input_size = 4
		var num_layers = 2
		var layer_size = 4
		var output_size = 4
		nn.init_nn(input_size, output_size, num_layers, layer_size)
		nn.randomize_nn()
		nn.feedforward()
	self.get_parent().get_node("best_score").text = "Best Score: %9.2f" % best_score


func _on_DeepNN_loaded():
	reset()
	print("model loaded")
	self.best_score = nn.get_fitness()
	self.get_parent().get_node("best_score").text = "Best Score: %9.2f" % best_score
