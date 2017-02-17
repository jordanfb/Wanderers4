
require "class"

Neuron = class()

function Neuron:_init(num_inputs, weights)
	if type(num_inputs) == "table" then
		self:unserialize(num_inputs)
	else
		self.num_inputs = num_inputs
		if (weights == nil) then
			self.weights = {}
			self:randomWeights()
		else
			self.weights = weights
			self.num_inputs = #weights
		end
	end
end

function Neuron:randomWeights()
	for i = 1, self.num_inputs do
		self.weights[i] = 2*math.random()-1
	end
end

function Neuron:update(input)
	if (#input ~= self.num_inputs) then
		print("ERROR! WRONG NUMBER OF INPUTS FOR NEURON!")
		return
	end
	local sum = 0
	for i = 1, #input do
		sum = sum + input[i]*self.weights[i]
	end
	return self:sigma_activation(sum)
end

function Neuron:sigma_activation(inputSum)
	return 1/(1+math.exp(-inputSum))
end

function Neuron:mutate(chance)
	-- runs through all weights and mutates chance% of them to a random new weight.
	for i = 1, self.num_inputs do
		if math.random() < chance then
			self.weights[i] = 2*math.random()-1
		end
	end
end

function Neuron:serialize()
	local output = "neuron neuron_inputs " .. self.num_inputs .. " weights"
	for i = 1, #self.weights do
		output = output .. " " .. self.weights[i]
	end
	return output .. " end_neuron"
end

function Neuron:unserialize(text)
	self.weights = {}
	local state = 0 -- state 0 = none, state 1 = num_inputs, state 2 = inputting inputs
	for i = 1, #text do
		if text[i] == "neuron" then
			state = 0
		elseif text[i] == "neuron_inputs" then
			state = 1
		elseif text[i] == "weights" then
			state = 2
		elseif text[i] == "end_neuron" then
			return
		elseif state == 1 then
			self.num_inputs = tonumber(text[i])
		elseif state == 2 then
			self.weights[#self.weights+1] = tonumber(text[i])
		end
	end
end