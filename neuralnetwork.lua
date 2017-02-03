
require "class"
require "layer"

NeuralNetwork = class()


function NeuralNetwork:_init(num_inputs, num_layers, layer_width, num_outputs, num_passthroughs, layers)
	-- num layers includes all layers including input and output, probably, just cause?
	-- num_passthroughs are only included in the first layer's inputs and the last layer, normally it's just layer_width wide
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
	-- also include the state vector cause awesomeness!
	inputs = self:includeStateVector(inputs)
	for i = 1, #self.layers do
		inputs = self.layers[i]:update(inputs)
	end
	-- it returns the outputs combined with the state vector, just cause visualizations? and cause I'm too lazy.
	self:setStateVector(inputs)
	return inputs
end