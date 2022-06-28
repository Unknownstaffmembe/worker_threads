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

function Module.Iterate(Start, Centre, End, LineSize, IncX, IncY)
	local ReturnTable = {}
	local Sx, Sy = Start.X, Start.Y
	local Cx, Cy = Centre.X, Centre.Y
	local Lx, Ly = End.X, End.Y
	local StartIndex = (Sx - 1) * LineSize + Sy
	local Counter = 0

	for iy = Sy, LineSize do
		ReturnTable[StartIndex + Counter] = Z((Sx - Cx) * IncX, (iy - Cy) * IncY)
		Counter += 1
	end

	for ix = Sx, End.X do
		for iy = 1, LineSize do
			ReturnTable[StartIndex + Counter] = Z((ix - Cx) * IncX, (iy - Cy) * IncY)
			Counter += 1
		end
	end

	for iy = 0, Ly do
		ReturnTable[StartIndex + Counter] = Z((Lx - Cx) * IncX, (iy - Cy) * IncY)
		Counter += 1
	end

	return ReturnTable
end

return Module
