
require "class"
require "neuron"


Layer = class()


function Layer:_init(num_neurons, inputs_per_neuron, neurons)
	self.num_neurons = num_neurons
	self.inputs_per_neuron = inputs_per_neuron
	if neurons == nil then
		self.neurons = {}
		self:makeRandomNeurons()
	else
		self.neurons = neurons
	end
end

function Layer:makeRandomNeurons()
	for i = 1, self.num_neurons do
		self.neurons[i] = Neuron(self.inputs_per_neuron)
	end
end

function Layer:update(inputs)
	local outputs = {}
	for i = 1, self.num_neurons do
		outputs[i] = self.neurons[i].update(inputs)
	end
	return outputs
end