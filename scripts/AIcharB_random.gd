extends KinematicBody2D

export (int) var speed = 200
export (float) var rotation_speed = 1.5
export (float) var energy = 100

var velocity = Vector2()
var rotation_dir = 0

# neurons by layer (array)
var input_neurons = Array()
var hidden_neurons = Array()
var output_neurons = Array()

# weights by layer (matrix)
var hidden_weights = Array()
var output_weights = Array()

var il = 4 # input nodes
var hl = 2 # hidden nodes
var ol = 4 # output nodes

func init_nn(): # initialize neural network parameters
	# input layer
	for i in range(il):
		input_neurons.append(0.0)
	
	# hidden layer
	for i in range(hl):
		hidden_neurons.append(0.0)
		hidden_weights.append([])
		for j in range(il):
			hidden_weights[i].append(0.0)
	
	# output layer
	for i in range(ol):
		output_neurons.append(0.0)
		output_weights.append([])
		for j in range(hl):
			output_weights[i].append(0.0)

func randomize_nn(): # randomize neural network parameters
	randomize()
	
	# hidden layer
	for i in range(hl):
		hidden_neurons[i] = rand_range(-1.0, 1.0)
		for j in range(il):
			hidden_weights[i][j] = rand_range(-1.0, 1.0)
	
	# output layer
	for i in range(ol):
		output_neurons[i] = rand_range(-1.0, 1.0)
		for j in range(hl):
			output_weights[i][j] = rand_range(-1.0, 1.0)

func nn_feedforward(): # calculate the neural network's output values
	# hidden layer
	for i in range(hl):
		#hidden_neurons[i] = 0.0
		for j in range(il):
			hidden_neurons[i] += input_neurons[j] * hidden_weights[i][j]
		# activation
		hidden_neurons[i] = tanh(hidden_neurons[i])
	
	# output layer
	for i in range(ol):
		#output_neurons[i] = 0.0
		for j in range(hl):
			output_neurons[i] += hidden_neurons[j] * output_weights[i][j]
		# activation
		output_neurons[i] = tanh(output_neurons[i])

func print_nn(): # print all neural network parameters
	# input layer
	print("== input layer ==")
	for i in range (il):
		print(input_neurons[i])
	
	# hidden layer
	print("== hidden layer ==")
	for i in range (hl):
		print(hidden_neurons[i])
	print("====")
	for i in range (hl):
		for j in range(il):
			print(hidden_weights)
	
	# output layer
	print("== output layer ==")
	for i in range(ol):
		print(output_neurons[i])
	print("====")
	for i in range(ol):
		for j in range(hl):
			print(output_weights[i][j])

func print_output_layer():
	print("[%f, %f, %f, %f]" % output_neurons)

func update_engerybar(energy):
	get_node("EnergyBar").set_value(energy)

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
	nn_feedforward()
	#print_output_layer()
	
	rotation_dir = 0
	velocity = Vector2()

	if output_neurons[0] > 0.0: # right
		rotation_dir += 1
	if output_neurons[1] > 0.0: # left
		rotation_dir -= 1
	if output_neurons[2] > 0.0: # down
		velocity = Vector2(-speed, 0).rotated(rotation)
	if output_neurons[3] > 0.0: # up
		velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	get_ai_input()
	rotation += rotation_dir * rotation_speed * delta
	velocity = move_and_slide(velocity)
	energy -= 0.01
	update_engerybar(energy)

func _ready():
	init_nn()
	randomize_nn()
	#print_nn()
	print_output_layer()
