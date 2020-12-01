-- http://lua-users.org/wiki/FileInputOutput
function readall(filename)
  local fh = assert(io.open(filename, "rb"))
  local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
  fh:close()
  return contents
end


function table.map(t,func)
	local o = {}
	for k,v in ipairs(t) do
		table.insert(o,func(v))
	end
	return o
end

function table.flatten1(t)
	local o = {}
	for _,o2 in ipairs(t) do
		for _,element in ipairs(o2) do
			table.insert(o,element)
		end
	end
	return o
end

function manhattan(c1,c2)
	-- calculate manhattan distance between two points given as 2-long tables/lists
	return math.abs(c1[1]-c2[1]) + math.abs(c1[2]-c2[2])
end


function fst(t)
	return t[1]
end

function snd(t)
	return t[2]
end

function enumerate(iter)
	local n =0
	return function()
		n = n+1
		val = iter()
		if val then return n,val
		else return nil
		end
	end
end

function filter(iter,predicate)
	return function()
		while true do
			
			val = {iter()}
			if val[1] then else return nil end
			if predicate(table.unpack(val)) then return table.unpack(val) end
		end
	end
end


function argmin(t,order) 
	-- Returns the key of a minimal element in a table. Splits ties arbitrarily.
	-- Also provides the minimal value
	
	-- the `order(a,b)` must return `true` if `a < b` according to the ordering you define

	local minv = nil
	local mink = nil

    for k,v in pairs(t) do 
		if minv then
			if order(v,minv) then
				--for k,v in pairs(v) do print(k) end
				mink,minv = k,v
			end
		else
			mink,minv = k,v
		end
	end
	
	return mink,minv
end


function icount(iter)
	local n = 0
	local val = iter()
	while val do
		n = n+1
		val = iter()
	end
	return n
end


function iskip(iter,skips)
	for i = 1,(skips) do
		iter()
	end
	return iter
end



function izip(iter1,iter2)
	return function()
		return iter1(),iter2()
	end
end

function imap(iter,func)
	return function()
		--print(iter)
		val = {iter()}
		--print(val)
		if val then return func(val) else return nil
		end
	end
end






-------------------------


--
-- Load the coordinates
--
f = assert(io.open("input.txt"))
-- a quick check says all coordinates are positive. simplifies the checks a bit.
coordinates = {}
for l in f:lines() do
	--print(l)
	if l then -- trailing newline creates a nil line at the end
		local x,y=l:match("(%d+), (%d+)")
		table.insert(coordinates,{tonumber(x),tonumber(y)})
	end
end

--
-- Determine the size of the coordinate system
--
xmax = math.max(table.unpack(table.map(coordinates,fst)))
ymax = math.max(table.unpack(table.map(coordinates,snd)))
--print(xmax)
--print(ymax)


--
-- Produce the grid showing voronoi cell membership per coordinate
--
grid = {}
for y = 1,ymax do 
	table.insert(grid,{})
	for x=1,xmax do
		closest_coord = nil
		closest_dist = 99999999
		is_tie = false
		for i,c in ipairs(coordinates) do
			current_dist = manhattan(c,{x,y})
			if current_dist < closest_dist then closest_coord = i; is_tie = false; closest_dist = current_dist
			elseif current_dist < closest_dist then is_tie = true
			end
		end
		if is_tie then 
			grid[y][x] = nil
		else 
			grid[y][x] = closest_coord
		end
	end
end


--[[
--
-- Show the grid
--
print(
	table.concat(
		table.map(
			grid,
			function (l) return table.concat(l,"\t") end
			),
		"\n"
		)
)
--]]

--
-- Determine what cells are infinite size. They extend do the corners of the grid use a table as a set http://www.lua.org/pil/11.5.html
--
infinite_cells = {}
for y = 1,ymax do  infinite_cells[grid[y   ][1   ]] = true end
for y = 1,ymax do  infinite_cells[grid[y   ][xmax]] = true end
for x = 1,xmax do  infinite_cells[grid[1   ][x   ]] = true end
for x = 1,xmax do  infinite_cells[grid[ymax][x   ]] = true end

--
-- Count the cell size for every cell. Assume that every cell is connected, so we can disregard the cell shape and simply count the number of coordinates in the cell.
--
finite_cell_sizes = {}
flatgrid = table.flatten1(grid)
for c =1,#coordinates do
	if not infinite_cells[c] then
	for _,v in ipairs(flatgrid) do 
		if c == v then
			finite_cell_sizes [c] = (finite_cell_sizes [c] or 0) +1
		end
	end
	end
end

_,area = argmin(finite_cell_sizes ,function(a,b) return a>b end )
print("A :".. area) -- 4011 is correct



--
-- Brute force check distance to points and count valid points.
-- Quite a bit of code duplication from above, but I accept that.
--
region_size = 0
for y = 1,ymax do 
	for x=1,xmax do
		total_dist = 0
		for _,c in ipairs(coordinates) do
			total_dist = total_dist + manhattan(c,{x,y})
		end
		if total_dist < 10000 then region_size = region_size + 1 end
	end
end
print("B: " .. region_size)