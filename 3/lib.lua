function defaultdict(default_value_factory)
	-- https://stackoverflow.com/a/25694804/4050510
    local t = {}
    local metatable = {}
    metatable.__index = function(t, key)
        if not rawget(t, key) then
            rawset(t, key, default_value_factory(key))
        end
        return rawget(t, key)
    end
    return setmetatable(t, metatable)
end

function string:iterlines()
	--iterate over the lines in the string 
	-- https://stackoverflow.com/questions/19326368/iterate-over-lines-including-blank-lines
	s = self
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end


Grid = {}
function Grid:new(size)
	o = {}
	o.size=size
	for i =1,size do
		o[i] = {}
	end
	setmetatable(o, self)
    self.__index = self
    return o
end

function Grid:tostring(peeksize)
	-- utility function for printing the Grid
	local t = {}
	size = peeksize or self.size
	emptymarker = "."
	for i =1,size do
		local t2 = {}
		for j=1,size do
			val =self[i][j] or emptymarker
			t2[j] = val
		end
		t[i] = table.concat(t2,"")
	end
	return table.concat(t,"\n")
end

function Grid:count(val)
	local n = 0
	for i =1,self.size do
		for j=1,self.size do
			if self[i][j] == val then
			 n = n+1
			 end
		end
	end
	return n
end