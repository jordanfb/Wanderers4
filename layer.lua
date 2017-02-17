
require "class"
require "neuron"


Layer = class()


function Layer:_init(num_neurons, inputs_per_neuron, neurons)
	if (type(num_neurons) == "table") then
		self:unserialize(num_neurons)
	else
		self.num_neurons = num_neurons
		self.inputs_per_neuron = inputs_per_neuron
		if neurons == nil then
			self.neurons = {}
			self:makeRandomNeurons()
		else
			self.neurons = neurons
		end
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

function Layer:mutate(chance)
	-- runs through all neurons' weights and mutates chance% of them to a random new weight.
	for k, v in pairs(self.neurons) do
		v:mutate(chance)
	end
end

function Layer:serialize()
	local output = "layer num_neurons " .. self.num_neurons .. " inputs_per_neuron " .. self.inputs_per_neuron .. " neurons"
	for i = 1, #self.neurons do
		output = output .. " " .. self.neurons[i]:serialize()
	end
	return output .. " end_layer"
end

function Layer:unserialize(text)
	self.neurons = {}
	local state = 0 -- state 0 = none, state 1 = num_neurons, state 2 = inputs_per_neuron, 3 = inputting neurons
	for i = 1, #text do
		if text[i] == "layer" then
			state = 0
		elseif text[i] == "num_neurons" then
			state = 1
		elseif text[i] == "inputs_per_neuron" then
			state = 2
		elseif text[i] == "neurons" then
			state = 3
		elseif text[i] == "end_layer" then
			return
		elseif state == 1 then
			self.num_neurons = tonumber(text[i])
		elseif state == 2 then
			self.inputs_per_neuron = tonumber(text[i])
		elseif state == 3 then
			if text[i] == "neuron" then
				local j = i
				local neuron_input = {}
				while j <= #text and text[j] ~= "end_neuron" do
					neuron_input[#neuron_input+1] = text[j]
					j = j + 1
				end
				self.neurons[#self.neurons+1] = Neuron(neuron_input)
				i = j -- and we've already added one to it to make it the one after the end of the neuron
			end
		end
	end
end