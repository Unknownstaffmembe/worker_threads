local WorkerThreads = require(game:GetService("ReplicatedStorage").WorkerThreads)
local Complex = script.Complex
local NumWorkers = 64
local Workers = WorkerThreads.New(Complex, "Iterate", NumWorkers)

local GridSize = Vector2.new(500, 500)
local CentrePosition = Vector3.new(0, 0, 0)
local PartSize = Vector3.new(1, 1, 1)

local PartIncX, PartIncZ = PartSize.X, PartSize.Z
local Sx, Sy = GridSize.X, GridSize.Y
local Cx, Cy = GridSize.X/2, GridSize.Y/2
local IncX, IncY = 2.5/Sx, 2.5/Sy
local NumParts = Sx * Sy
local Centre_Shift = Vector2.new(30, 0)
local Centre = Vector2.new(Cx, Cy) + Centre_Shift

local PartsForSingleWorker = NumParts % NumWorkers
local PartsPerWorker = (NumParts - PartsForSingleWorker)/NumWorkers
PartsForSingleWorker = (PartsForSingleWorker == 0) and PartsPerWorker or PartsForSingleWorker

local PartsTable = {}
local ColoursTable = {}
local Counter = 1

local Jobs = PartsPerWorker < 0 and 1 or NumWorkers
local CompletedJobs = 0

local function Done()
	for i, v in pairs(PartsTable) do
		v[1].Color = ColoursTable[tostring(i)]
	end
end

local function DispatchWork(Start, End)
	local Ret = Workers:DoWork(Start, Centre, End, Sy, IncX, IncY)
	for i, v in pairs(Ret) do
		PartsTable[tonumber(i)][1].Color = v
	end
	CompletedJobs += 1
	if CompletedJobs == Jobs then
		--Done()
	end
end

local BlueprintPart = Instance.new("Part")
BlueprintPart.Anchored = true
BlueprintPart.CanCollide = false
BlueprintPart.Material = Enum.Material.Neon
BlueprintPart.Size = PartSize

print("WAITING FOR THE GAME TO LOAD IN") -- lol
task.wait(3) -- just preventing a sudden lag spike
local Iterations = 0
for ix = 1, Sx do
	for iy = 1, Sy do
		local Part = BlueprintPart:Clone()
		Part.Position = CentrePosition + Vector3.new((ix - Cx) * PartIncX, 0, (iy - Cy) * PartIncZ)
		PartsTable[Counter] = {Part, Vector2.new(ix, iy)}
		Part.Parent = workspace
		Counter += 1
		Iterations += 1
		if Iterations == 400 then
			task.wait()
			Iterations = 0
		end
	end
end

print("YIELDING FOR 3 SECONDS")
task.wait(3)

task.spawn(DispatchWork, Vector2.new(1, 1), PartsTable[PartsForSingleWorker][2], 1)

local Start = PartsForSingleWorker
local End = PartsForSingleWorker
for i = 1, NumWorkers - 1 do
	Start = End
	End = Start + PartsPerWorker
	task.spawn(DispatchWork, PartsTable[Start + 1][2], PartsTable[End][2])
end
