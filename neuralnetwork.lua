
require "class"
require "layer"

NeuralNetwork = class()


function NeuralNetwork:_init(num_inputs, num_layers, layer_width, num_outputs, num_passthroughs, layers)
	-- num layers includes all layers including input and output, probably, just cause?
	-- num_passthroughs are only included in the first layer's inputs and the last layer, normally it's just layer_width wide
	if type(num_inputs) == "string" or type(num_inputs) == "table" then
		self:unserialize(num_inputs)
	else
		self.num_inputs = num_inputs
		self.num_layers = num_layers
		self.layer_width = layer_width
		self.num_outputs = num_outputs
		self.num_passthroughs = num_passthroughs
		self.state_vector = {} -- this is going to be num_passthroughs wide
		if layers == nil then
			self.layers = {}
			self:makeRandomLayers()
		else
			self.layers = layers
		end
	end
end

function NeuralNetwork:makeRandomLayers()
	if self.num_layers < 1 then
		return
	end
	local currentInputWidth = self.num_inputs + self.num_passthroughs
	-- we use currentLayerWidth in case there's just one layer (which would be the output layer)
	local layersLeftToDo = self.num_layers
	while layersLeftToDo > 1 do
		-- make a layer
		self.layers[#self.layers+1] = Layer(self.layer_width, currentInputWidth)
		currentInputWidth = self.layer_width
		-- now that we've done at least one layer make the number of inputs equal to the width of the layers
		layersLeftToDo = layersLeftToDo - 1 -- and decrease the loop.
	end
	-- then make the output layer
	self.layers[#self.layers+1] = Layer(self.num_outputs+self.num_passthroughs, currentInputWidth)
end

function NeuralNetwork:includeStateVector(inputs)
	if #self.state_vector == 0 then
		for i = 1, self.num_passthroughs do
			self.state_vector[i] = 0
		end
	end
	for i = 1, self.num_passthroughs do
		inputs[#inputs+1] = self.state_vector[i]
	end
	return inputs
end

function NeuralNetwork:setStateVector(inputs)
	-- this sets the state vector from the output of the last layer of neural nets.
	self.state_vector = {}
	for i = self.num_outputs+1, #inputs do
		self.state_vector[#self.state_vector+1] = inputs[i]
	end
end

function NeuralNetwork:update(inputs)
	-- also include the state vector in its return cause awesomeness!
	inputs = self:includeStateVector(inputs)
	for i = 1, #self.layers do
		inputs = self.layers[i]:update(inputs)
	end
	-- it returns the outputs combined with the state vector, just cause visualizations? and cause I'm too lazy to remove it.
	self:setStateVector(inputs) -- record the state vector in itself in order to remember it for future updates.
	return inputs
end

function NeuralNetwork:serializeStateVector()
	local output = "statevector"
	for i = 1, #self.state_vector do
		output = output .. " " .. self.state_vector[i]
	end
	return output .. " end_statevector"
end

function NeuralNetwork:unserializeStatevector(input)
	self.state_vector = {}
	for i = 1, #input do
		if input[i] == "statevector" then
			-- do nothing
		elseif input[i] == "end_statevector" then
			return
		else
			self.state_vector[#self.state_vector+1] = tonumber(input[i])
		end
	end
end

function NeuralNetwork:serialize()
	-- a simple string serialize that, while not optimized for size, it is optimized for programmer time / cross compatibility.
	-- note that I put "statevectors" as plural to fit with the pattern of opening with a plural form, but perhaps should be
	-- changed in a future version
	local output = "net ".."num_inputs "..self.num_inputs.." num_layers "..self.num_layers
	output = output .. " layer_width "..self.layer_width .. " num_outputs "..self.num_outputs
	output = output .. " num_passthroughs " .. self.num_passthroughs
	output = output .. " statevectors " .. self:serializeStateVector() .. " layers"
	for i = 1, #self.layers do
		output = output .. " " .. self.layers[i]:serialize()
	end
	return output .. " end_net"
end

function NeuralNetwork:splitTextBySpaces(text)
	local t = {}
	for i in string.gmatch(text, "%S+") do
		t[#t+1] = i
	end
	return t
end

function NeuralNetwork:unserialize(text)
	if type(text) == "string" then
		-- split it into a table of words separated by spaces.
		text = self:splitTextBySpaces(text)
	end
	self.layers = {}
	self.state_vector = {}
	local state = 0 -- state 0 = none, state 1 = num_inputs, state 2 = num_layers, 3 = layer_width 4 = num_outputs
	-- 5 = num_passthroughs, 6 = inputting state vector, 7 = inputting layers
	for i = 1, #text do
		-- print(text[i] .. " state = "..state)
		if text[i] == "net" then
			state = 0
		elseif text[i] == "num_inputs" then
			state = 1
		elseif text[i] == "num_layers" then
			state = 2
		elseif text[i] == "layer_width" then
			state = 3
		elseif text[i] == "num_outputs" then
			state = 4
		elseif text[i] == "num_passthroughs" then
			state = 5
		elseif text[i] == "statevectors" then
			state = 6
		elseif text[i] == "layers" then
			state = 7
		elseif text[i] == "end_net" then
			return
		elseif state == 1 then
			self.num_inputs = tonumber(text[i])
		elseif state == 2 then
			self.num_layers = tonumber(text[i])
		elseif state == 3 then
			self.layer_width = tonumber(text[i])
		elseif state == 4 then
			self.num_outputs = tonumber(text[i])
		elseif state == 5 then
			self.num_passthroughs = tonumber(text[i])
		elseif state == 6 then
			if text[i] == "statevector" then
				local j = i
				local state_vector_input = {}
				while j <= #text and text[j] ~= "end_statevector" do
					state_vector_input[#state_vector_input+1] = text[j]
					j = j + 1
				end
				self:unserializeStatevector(state_vector_input)
				i = j
			end
		elseif state == 7 then
			if text[i] == "layer" then
				local j = i
				local layer_input = {}
				while j <= #text and text[j] ~= "end_layer" do
					layer_input[#layer_input+1] = text[j]
					j = j + 1
				end
				self.layers[#self.layers+1] = Layer(layer_input)
				i = j -- and we've already added one to it to make it the one after the end of the neuron
			end
		end
	end
end