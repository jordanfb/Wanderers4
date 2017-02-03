
require "class"

Neuron = class()

function Neuron:_init(num_inputs, weights)
	self.num_inputs = num_inputs
	if (weights == nil) then
		self.weights = {}
		self:randomWeights()
	else
		self.weights = weights
	end
end

function Neuron:randomWeights()
	for i = 1, self.num_inputs do
		self.weights[i] = math.random(-1, 1)
	end
end

function Neuron:update(input)
	if (#input ~= self.num_inputs) then
		print("ERROR! WRONG NUMBER OF INPUTS FOR NEURON!")
		return
	end
	local sum = 0
	for i = 1; #input do
		sum = sum + input[i]*self.weights[i]
	end
	return self:sigma_activation(sum)
end

function Neuron:sigma_activation(inputSum)
	return 1/(1+math.exp(-inputSum))
end