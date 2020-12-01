function string:iterlines()
	--iterate over the lines in the string 
	-- https://stackoverflow.com/questions/19326368/iterate-over-lines-including-blank-lines
	s = self
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end

function spairs(t, order)
	-- iterate over a tables SORTED pairs
	-- https://stackoverflow.com/questions/15706270/sort-a-table-in-lua

    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
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