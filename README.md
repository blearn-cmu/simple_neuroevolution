# Simple Neuroevolution Environment

Eventually will be part of a tutorial series on using neural networks in 2d games.


## What's actually going on here

We are using a neural network to track a target, i.e. move towards the target. This is a diagram of the NN that controls the AI character. Each parameter is a scalar value between -1.0 and 1.0. Inputs are also normalized to be mapped to a value between -1.0 and 1.0. Keeping these values on the same scale helps the learning process.

First here's how the NN works. On each game engine step we feed information about the environment into the NN. This network is given the AI character's x and y position as well as the distance to the target and the angle to the target. The NN uses the inputs and its parameters (weights and bias values) to determine which outputs to trigger. In this case the outputs correspond to 4 button presses (up, down, left, right). It can decide to trigger 0-4 outputs on each step. What you currently see is a very dumb NN because its parameters are completely random. Typically you start with a random NN and try to improve it with training.

The environment has more information that the NN doesn't know about. For example, it doesn't know that different tile types exist or that it cannot move through certain tiles. It also doesn't know it has energy or that it will die when it runs out of energy. That's okay because generally you want to maximize the NN's perform but also minimize the amount of inputs (for computation efficiency). 

Now, how training works. There are many ways to train but in this case we are using a random search optimization. Specifically its using a genetic algorithm (GA), which means it aims to mimic biological evolution.
GA's typically run a loop like this:

0) Generate a population by mutating the previous best model(s)
1) Run simulations for the population
2) Select the best performer(s)

Currently this GA is using a population of 1 (bad). A simple fitness function is used to determine how well the NN model performed: how long the character survived (will be improved soon). The most important part is the mutation step. There are endless ways to mutate but in this case each parameter in the model has a random chance to be changed. There are four types of changes that can occur:

1) flip the sign (+/-) of the value
2) slightly increase the value
3) slightly decrease the value
4) re-roll the value
The goal of mutation is to nudge the parameters around and hope to fall into a better solution to the task (moving towards the target).

With enough iterations it can learn simple rules such as "when the angle to the target is 0, I can hold 'up' until I hit the target".
