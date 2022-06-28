local Module = {}
local Methods = {}
Methods.__index = Methods

local ActorTemplate
local ActorContainer = Instance.new("Folder")
ActorContainer.Name = "WORKER CONTAINER"

if game:GetService("RunService"):IsStudio() then
	ActorTemplate = script:WaitForChild("Actor_Server")
	ActorContainer.Parent = game.ServerScriptService
else
	ActorTemlate = script:WaitForChild("Actor_Client")
	ActorContainer.Parent = game:GetService("Players").LocalPlayer.PlayerScripts -- this was done assuming that scripts in ReplicatedFirst won't require this moduel, if so, I'd recommend changing this to something else (╯ ͠° ͟ʖ ͡°)╯┻━┻ 
end

function Module.New(Module, Job, NumWorkers)
	local Object = setmetatable({}, Methods)
	Object.Module = Module
	Object.Job = Job
	Object.Counter = 1
	Object.NumWorkers = 0
	Object.Workers = {}

	for i = 1, NumWorkers do
		Object:NewWorker() -- I hope luau inlines this ( ͡° ͜ʖ ͡°)
	end

	return Object
end

function Methods:AddWork(...) -- if you wanted to optimise this even more, you could create this in Module.New and use an upvalue referencing the object created instead; I hope luau optimises this ¯\_( ͡° ͜ʖ ͡°)_/¯
	local Worker = self.Counter
	if Worker == self.NumWorkers then
		self.Counter = 1
	else
		self.Counter += 1
	end
	return self.Workers[Worker]:Invoke(...)
end

function Methods:NewWorker()
	local NewActor = ActorTemplate:Clone()
	NewActor.Module.Value = self.Module
	NewActor.Job.Value = self.Job
	NewActor.Script.Disabled = false
	NewActor.Name = "WORKER:" .. self.Job
	NewActor.Parent = ActorContainer
	table.insert(self.Workers, NewActor.Event)
	self.NumWorkers += 1
end

function Methods:Clean() -- the reason why RemoveWorker isn't a method is because things can get messy, what if a function yeilds and workers are currently doing work, you may remove an active worker; clean is meant to be run when no work is being done ( ͡°( ͡° ͜ʖ( ͡° ͜ʖ ͡°)ʖ ͡°) ͡°)
	for _, Worker in pairs(self.Workers) do
		Worker:Destroy() -- don't reuse this object after cleaning it because references in self.Workers won't be removed; they're expected to be garbage collected so, make sure to remove all references to the object this has been called on ( ͡° ͜ʖ ͡ – ✧)
	end
end

return Module
