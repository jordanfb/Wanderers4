
require "class"
require "neuralnetwork"

NetManager = class()

function NetManager:_init(save_filename, history_filename)
	-- do something
end


--[[ what I want:
I want to be able to take these four classes and just have neural nets in every single thing I do.
I pass in the number of inputs, and the number of outputs, and possible state vectors/sizes/layernums
I pass in the number of creatures I want, and then I give it the inputs for each, and it gives the outputs for each
Once I'm done with a generation I give it the scores, and then it breeds them for me, and then we do it again.

There should also be ways to not breed things, so I can hold steady/run it in a game or something,
It should save things, and have options to figure out how many times to save things.

By default save the best of the generation, and then save everything/load everything when starting up/closing.

]]--