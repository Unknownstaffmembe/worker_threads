--!nocheck
-- For some reason, there's a type error in Studio
-- Type Error: (11,8) Unknown require: [SOME NUMBER BETWEEN 0 and 1].Value

local Job
local Event = script.Parent.Event
do
	local Actor = script.Parent
	local Module = Actor.Module.Value
	local JobKey = Actor.Job.Value
	Job = require(Module)[JobKey] or error("JOB NOT FOUND:\nMODULE: " .. tostring(Module) .. "\nJOB: " .. JobKey)
end

Event.OnInvoke = function(...)
	task.desynchronize()
	return Job(...)
end
