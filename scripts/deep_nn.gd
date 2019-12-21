extends Node

class_name DeepNN

signal saved
signal loaded

const FILE_NAME = "user://model_%s.json"

var model = {
	"input_nodes": Array(),    # 1-D array of input node values
	"output_nodes": Array(),   # 1-D array of output node values
	"hidden_nodes": Array(),   # 2-D array of hidden node values per layer
	"hidden_weights": Array(), # 3-D array of hidden weight values per layer
	"hidden_bias": Array(),    # 1-D array of hidden bias values (1 bias per layer)
	"output_weights": Array(), # 2-D array of output weight values
	"output_bias": 0.0,        # bias value for output layer (scalar)
	"fitness": 0.0             # fitness score for model's performance
}

func init_nn(input_size, output_size, num_layers, layer_size): # initialize neural network parameters
	# input layer
	for i in range(input_size): # for each input node
		model["input_nodes"].append(0.0) # init node
	
	# hidden layers
	for l in range(num_layers): # for each hidden layer
		model["hidden_bias"].append(0.0)        # init bias
		model["hidden_nodes"].append(Array())   # init 2-D array of nodes
		model["hidden_weights"].append(Array()) # init 3-D array of weights
		
		for h in range(layer_size): # for each hidden node
			model["hidden_nodes"][l].append(0.0) # init node
		
		if l == 0: # first hidden layer weights have dimension [input_size][layer_size]
			for i in range(input_size):     # for each input node
				model["hidden_weights"][l].append(Array())    # add 1-d array of weights
				for h in range(layer_size): # for each hidden node
					model["hidden_weights"][l][i].append(0.0) # init weight value
		else:      # remaining hidden layer weights have dimension [layer_size][layer_size]
			for p in range(layer_size):     # for each previous layer hidden node
				model["hidden_weights"][l].append(Array())    # add 1-d array of weights
				for h in range(layer_size): # for each hidden node
					model["hidden_weights"][l][p].append(0.0) # init weight value
	
	# output layer
	model["output_bias"] = 0.0 # init bias
	
	for o in range(output_size): # for each output node
		model["output_nodes"].append(0.0) # init node
	
	for h in range(layer_size): # for each previous layer hidden node
		model["output_weights"].append(Array()) # init 2-D array of weights
		for o in range(output_size): # for each output node
			model["output_weights"][h].append(0.0) # init weight value

func randomize_nn(): # randomize neural network parameters
	var input_size = model["input_nodes"].size()
	var num_layers = model["hidden_nodes"].size()
	var layer_size = model["hidden_nodes"][0].size()
	var output_size = model["output_nodes"].size()
	
	randomize()
	
	# input layer
	for i in range(input_size): # for each input node
		model["input_nodes"][i] = rand_range(-1.0, 1.0) # randomize node
	
	# hidden layers
	for l in range(num_layers): # for each hidden layer
		model["hidden_bias"][l] = rand_range(-1.0, 1.0) # randomize bias
		
		for h in range(layer_size): # for each hidden node
			model["hidden_nodes"][l][h] = rand_range(-1.0, 1.0) # randomize node
		
		if l == 0: # first hidden layer weights have dimension [input_size][layer_size]
			for i in range(input_size):     # for each input node
				for h in range(layer_size): # for each hidden node
					model["hidden_weights"][l][i][h] = rand_range(-1.0, 1.0) # randomize weight value
		else:      # remaining hidden layer weights have dimension [layer_size][layer_size]
			for p in range(layer_size):     # for each previous layer hidden node
				for h in range(layer_size): # for each hidden node
					model["hidden_weights"][l][p][h] = rand_range(-1.0, 1.0) # randomize weight value
	
	# output layer
	model["output_bias"] = rand_range(-1.0, 1.0) # randomize bias
	
	for o in range(output_size): # for each output node
		model["output_nodes"][o] = rand_range(-1.0, 1.0) # randomize node
	
	for h in range(layer_size): # for each previous layer hidden node
		for o in range(output_size): # for each output node
			model["output_weights"][h][o] = rand_range(-1.0, 1.0) # randomize weight value

func feedforward(): # calculate the neural network's output values
	var input_size = model["input_nodes"].size()
	var num_layers = model["hidden_nodes"].size()
	var layer_size = model["hidden_nodes"][0].size()
	var output_size = model["output_nodes"].size()
	
	# hidden layers
	for l in range(num_layers): # for each hidden layer
		for h in range(layer_size): # for each hidden node
			model["hidden_nodes"][l][h] = 0.0 # reset node value
		
		# calculate weighted sum
		if l == 0: # first hidden layer weights have dimension [input_size][layer_size]
			for i in range(input_size):     # for each input node
				for h in range(layer_size): # for each hidden node
					model["hidden_nodes"][l][h] += model["input_nodes"][i] * model["hidden_weights"][l][i][h] # weighted sum of previous layer
		else:      # remaining hidden layer weights have dimension [layer_size][layer_size]
			for p in range(layer_size):     # for each previous layer hidden node
				for h in range(layer_size): # for each hidden node
					model["hidden_nodes"][l][h] += model["hidden_nodes"][l][p] * model["hidden_weights"][l][p][h] # weighted sum of previous layer
		
		# add bias and apply activation function
		for h in range(layer_size): # for each hidden node
			model["hidden_nodes"][l][h] += model["hidden_bias"][l]
			model["hidden_nodes"][l][h] = tanh(model["hidden_nodes"][l][h])
	
	# output layer
	for o in range(output_size): # for each output node
		model["output_nodes"][o] = 0.0 # reset node
	
	# calcuate weighted sum
	for h in range(layer_size): # for each previous layer hidden node
		for o in range(output_size): # for each output node
			model["output_nodes"][o] += model["hidden_nodes"][num_layers-1][h] * model["hidden_weights"][num_layers-1][h][o] # weighted sum of previous layer
	
	# add bias and apply activation function
	for o in range(output_size): # for each output node
		model["output_nodes"][o] += model["output_bias"]
		model["output_nodes"][o] = tanh(model["output_nodes"][o])
		

func mutation(_rate): # mutate each weight with a chance of _rate (value between 0.0 and 1.0)
	var input_size = model["input_nodes"].size()
	var num_layers = model["hidden_nodes"].size()
	var layer_size = model["hidden_nodes"][0].size()
	var output_size = model["output_nodes"].size()
	
	# hidden layer
	for l in range(num_layers): # for each hidden layer
		if l == 0: # first hidden layer weights have dimension [input_size][layer_size]
			for i in range(input_size):     # for each input node
				for h in range(layer_size): # for each hidden node
					model["hidden_weights"][l][i][h] = mutate(model["hidden_weights"][l][i][h], _rate) # mutate weight value
		else:      # remaining hidden layer weights have dimension [layer_size][layer_size]
			for p in range(layer_size):     # for each previous layer hidden node
				for h in range(layer_size): # for each hidden node
					model["hidden_weights"][l][p][h] = mutate(model["hidden_weights"][l][p][h], _rate) # mutate weight value
	
	# output layer
	for h in range(layer_size): # for each previous layer hidden node
		for o in range(output_size): # for each output node
			model["hidden_weights"][num_layers-1][h][o] = mutate(model["hidden_weights"][num_layers-1][h][o], _rate) # mutate weight value

func mutate(x, rate): # mutate x value with a chance of rate (rate between 0.0 and 1.0)
	randomize()
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

func normalize(_input, _min, _max): # normalize _input for a range of (_min, _max)
	var _x = (_input - _min) / (_max - _min)
	return _x

# Setter functions

func set_inputs(input_array): # sets model's input node array
	if input_array.size() == model["input_nodes"].size():
		model["input_nodes"] = input_array
		return true
	else: # throw error
		print("input array is wrong size. Expected %s but received %s" % [model["input_nodes"].size(), input_array.size()])
		return false

func set_fitness(value): # sets model's fitness score
	model["fitness"] = value
	return true

# Getter functions

func get_output(): # returns model's output node array
	return model["output_nodes"]

func get_fitness(): # returns model's fitness score
	return model["fitness"]

# Read/Write model functions

func save_model(_id):
	var f = File.new()
	f.open(FILE_NAME % str(_id), f.WRITE)
	f.store_string(to_json(model))
	f.close()
	emit_signal("saved")

func load_model(_id):
	var f = File.new()
	if f.file_exists(FILE_NAME % str(_id)):
		f.open(FILE_NAME % str(_id), File.READ)
		var data = parse_json(f.get_as_text())
		f.close()
		if typeof(data) == TYPE_DICTIONARY:
			model = data
			emit_signal("loaded")
			return true
		else:
			printerr("Corrupted data!")
			return false
	else:
		printerr("No saved data")
	return false
