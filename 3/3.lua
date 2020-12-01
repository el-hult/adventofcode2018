require "lib"

input = [[#1 @ 1,3: 4x4
#2 @ 3,1: 4x4
#3 @ 5,5: 2x2
]]

f = io.open("input3.txt",'r')
input = f:read('a')

fabric = Grid:new(1000)
overlaps = {}
collisionmarker="X"
for l in input:iterlines() do
	id,left,top,width,height = l:match"#(%d+) @ (%d+),(%d+): (%d+)x(%d+)"
	id,left,top,width,height = tonumber(id),tonumber(left),tonumber(top),tonumber(width),tonumber(height)
	overlaps[id] = false
	for dx=1,width do
		for dy=1,height do
		val = fabric[top+dy][left+dx]
		if val then
			new = collisionmarker
			overlaps[id]=true
			if val ~= collisionmarker then
				overlaps[val] = true
			end
		else new = id end
		fabric[top+dy][left+dx] = new
	end end
end

print("A: "..fabric:count(collisionmarker))
for a,b in pairs(overlaps) do
	if not b then print("B: "..a) end
end