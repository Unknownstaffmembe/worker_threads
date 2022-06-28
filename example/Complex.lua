local Module = {}
local Iterations = 20
local Black = Color3.new(0, 0, 0)

local function Z(a, b) -- n = a + bi
	local Cache
	local Zr, Zi = 0, 0
	for i = 0, Iterations do
		Cache = Zr^2 - Zi^2 + a
		Zi = 2 * Zr * Zi + b
		Zr = Cache
		if (Zr^2 + Zi^2) > 4 then
			local S = i/Iterations -- Stability
			return Color3.fromHSV(S, S, S)
		end
	end
	return Black
end

local C2_r = 0.5
local C2_i = 0.25
local function Z2(a, b) -- n = a + bi
	local Cache
	local Zr, Zi = a, b
	for i = 0, Iterations do
		Cache = Zr^2 - Zi^2 + C2_r
		Zi = 2 * Zr * Zi + C2_i
		Zr = Cache
		if (Zr^2 + Zi^2) > 2 then
			local S = i/Iterations -- Stability
			return Color3.fromHSV(S, S, S)
		end
	end
	return Black
end

local C3_r = 1/math.pi
local C3_i = 1/(math.pi^2)
local function Z3(a, b) -- n = a + bi
	local Cache
	local Zr, Zi = a, b
	for i = 0, Iterations do
		Cache = Zr^2 - Zi^2 + C3_r
		Zi = 2 * Zr * Zi + C3_i
		Zr = Cache
		if (Zr^2 + Zi^2) > 2 then
			local S = i/Iterations -- Stability
			return Color3.fromHSV(S, S, S)
		end
	end
	return Black
end

local function SHIP(a, b)
	local Cache
	local Zr, Zi = 0, 0
	for i = 0, Iterations do
		Zr = math.abs(Zr)
		Zi = math.abs(Zi)
		Cache = Zr^2 - Zi^2 + a
		Zi = 2 * Zr * Zi + b
		Zr = Cache
		if (Zr^2 + Zi^2) > 4 then
			local S = i/Iterations -- Stability
			return Color3.fromHSV(S, S, S)
		end
	end
	return Black
end

local FUNC
FUNC = SHIP

function Module.Iterate(Start, Centre, End, LineSize, IncX, IncY)
	local ReturnTable = {}
	local Sx, Sy = Start.X, Start.Y
	local Cx, Cy = Centre.X, Centre.Y
	local Lx, Ly = End.X, End.Y
	local StartIndex = (Sx - 1) * LineSize + Sy
	local Counter = 0

	for iy = Sy, LineSize do
		ReturnTable[StartIndex + Counter] = FUNC((Sx - Cx) * IncX, (iy - Cy) * IncY)
		Counter += 1
	end
	Sx += 1

	if Sx > Lx then return ReturnTable end

	for ix = Sx, Lx - 1 do
		for iy = 1, LineSize do
			ReturnTable[StartIndex + Counter] = FUNC((ix - Cx) * IncX, (iy - Cy) * IncY)
			Counter += 1
		end
	end

	for iy = 1, Ly do
		ReturnTable[StartIndex + Counter] = FUNC((Lx - Cx) * IncX, (iy - Cy) * IncY)
		Counter += 1
	end

	return ReturnTable
end

return Module
