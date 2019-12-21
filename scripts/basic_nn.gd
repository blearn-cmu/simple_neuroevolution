extends Node

class_name BasicNN

signal saved

# neurons by layer (array)
var input_neurons
var hidden_neurons
var output_neurons

# weights by layer (matrix)
var hidden_weights
var output_weights

# bias by layer (scalar)
var hidden_bias = 0.1
var output_bias = 0.1

var il = 4 # input nodes
var hl = 2 # hidden nodes
var ol = 4 # output nodes

var best_model

const FILE_NAME = "user://nn-params_%s.json"

func init_nn(): # initialize neural network parameters
	# neurons by layer (array)
	input_neurons = Array()
	hidden_neurons = Array()
	output_neurons = Array()
	
	# weights by layer (matrix)
	hidden_weights = Array()
	output_weights = Array()
	
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
	
	# input layer
	#for i in range(il):
		#input_neurons[i] = rand_range(-1.0, 1.0)
	
	# hidden layer
	for i in range(hl):
		#hidden_neurons[i] = rand_range(-1.0, 1.0)
		for j in range(il):
			hidden_weights[i][j] = rand_range(-1.0, 1.0)
	hidden_bias = rand_range(-1.0, 1.0)
	
	# output layer
	for i in range(ol):
		#output_neurons[i] = rand_range(-1.0, 1.0)
		for j in range(hl):
			output_weights[i][j] = rand_range(-1.0, 1.0)
	output_bias = rand_range(-1.0, 1.0)

func nn_feedforward(): # calculate the neural network's output values
	# compute hidden layer output
	# Y = mX + b
	for i in range(hl):
		hidden_neurons[i] = 0.0
		for j in range(il): # weighted sum of previous layer
			hidden_neurons[i] += input_neurons[j] * hidden_weights[i][j]
		hidden_neurons[i] += hidden_bias # add bias
		hidden_neurons[i] = tanh(hidden_neurons[i]) # activation function
	
	# compute output layer output
	# Y = mX + b
	for i in range(ol):
		output_neurons[i] = 0.0
		for j in range(hl): # weighted sum of previous layer
			output_neurons[i] += hidden_neurons[j] * output_weights[i][j]
		output_neurons[i] += output_bias # add bias
		output_neurons[i] = tanh(output_neurons[i]) # activation function

func nn_mutation():
	set_nn_to_best_model() # start with previous best model
	
	# hidden layer
	for i in range(hl):
		for j in range(il):
			hidden_weights[i][j] = mutate(hidden_weights[i][j], 0.05)
	hidden_bias = mutate(hidden_bias, 0.05)
	
	# output layer
	for i in range(ol):
		for j in range(hl):
			output_weights[i][j] = mutate(output_weights[i][j], 0.05)
	output_bias = mutate(output_bias, 0.05)
	
	# debug
	#print_nn()

func mutate(x, rate):
	var chance = randf()
	if chance < rate:
		chance = randf()
		if chance < 0.1: # flip sign
			x *= -1
		elif chance < 0.2: # increase
			x = rand_range(x, x*2)
		elif chance < 0.45: # decrease
			x = rand_range(x*-0.5, x)
		elif chance < 0.7: # re-roll
			x = rand_range(-1.0, 1.0)
	
	return x

func update_inputs(input_array):
	self.input_neurons = input_array

func normalize(_input, _min, _max):
	var _x = (_input - _min) / (_max - _min)
	return _x

func get_output():
	return output_neurons

func save(_id):
	var nn_params = {
		"input_nodes": il,
		"hidden_nodes": hl,
		"output_nodes": ol,
		"hidden_weights": hidden_weights,
		"hidden_bias": hidden_bias,
		"output_weights": output_weights,
		"output_bias": output_bias
	}
	
	var f = File.new()
	f.open(FILE_NAME % str(_id), f.WRITE)
	f.store_string(to_json(nn_params))
	f.close()

func load(_id):
	var f = File.new()
	if f.file_exists(FILE_NAME % str(_id)):
		f.open(FILE_NAME % str(_id), File.READ)
		var data = parse_json(f.get_as_text())
		f.close()
		if typeof(data) == TYPE_DICTIONARY:
			self.il = data["input_nodes"]
			self.hl = data["hidden_nodes"]
			self.ol = data["output_nodes"]
			
			init_nn()
			
			self.hidden_weights = data["hidden_weights"]
			self.hidden_bias = data["hidden_bias"]
			self.output_weights = data["output_weights"]
			self.output_bias = data["output_bias"]
			
			self.best_model = data
			return true
		else:
			printerr("Corrupted data!")
			return false
	else:
		printerr("No saved data")
	return false

func set_nn_to_best_model(): # reset NN to previous best model
	if typeof(best_model) == TYPE_DICTIONARY: # assumes model already loaded from disk
		self.il = best_model["input_nodes"]
		self.hl = best_model["hidden_nodes"]
		self.ol = best_model["output_nodes"]
		
		init_nn()
		
		self.hidden_weights = best_model["hidden_weights"]
		self.hidden_bias = best_model["hidden_bias"]
		self.output_weights = best_model["output_weights"]
		self.output_bias = best_model["output_bias"]
		
		return true
	else:
		printerr("Corrupted data!")
		return false

func print_nn(): # print all neural network parameters
	# input layer
	print("== input nodes ==")
	for i in range (il):
		print(input_neurons[i])
	
	# hidden layer
	print("== hidden weights ==")
	print(hidden_weights)
	print("== hidden nodes ==")
	for i in range (hl):
		print(hidden_neurons[i])
	
	# output layer
	print("== output weights ==")
	print(output_weights)
	print("== output layer ==")
	for i in range(ol):
		print(output_neurons[i])

func temp_print():
	print("== ==")
	print("angle: %.3f" % input_neurons[3])
	print("left: %.3f" % output_neurons[0])
	print("up: %.3f" % output_neurons[2])
	print("   ")

func print_input_layer():
	print("[%f, %f, %f, %f]" % input_neurons)

func print_output_layer():
	print("[%f, %f, %f, %f]" % output_neurons)

func _init(il=4, hl=2, ol=4):
	self.il = il
	self.hl = hl
	self.ol = ol

func _ready():
	init_nn()
	randomize_nn()
	#print_nn()
	print_output_layer()
