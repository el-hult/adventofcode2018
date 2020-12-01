f = io.open("input.txt",'r')
input = f:read('a'):gsub("%s","")

function reduce(input)
	-- Takes a polymer string and returns a table of all non-reduced monomers

	elements = {}
	setmetatable(elements,{__index=table}) -- make the `table` library methods on the `elements` table

	for c in input:gmatch"." do --gmatch returns a iterator
		if #elements == 0 then
			elements:insert(c)
			--print("Empty string. Adding " .. c)
		else
			local last = elements[#elements]
			if c ~= last and last:upper() == c:upper() then
				elements:remove()
				-- print(c .. " and " .. last .. " DO   annihilate")
			else
				elements:insert(c)
				--print(c .. " and " .. last .. " DONT annihilate")
			end
		end
	end

	return elements
end

basic_residue = #(reduce(input))
print("A :" .. basic_residue) --9808

shortest_residue = basic_residue
best_char = ""
for c in ("abcdefghijklmnopqrstuvxyz"):gmatch(".") do
	input_fixed = input:gsub(c,"")
	input_fixed = input_fixed:gsub(c:upper(),"")
	residue = #(reduce(input_fixed))
	if residue < shortest_residue then best_char = c shortest_residue = residue end
end
print("B :"..shortest_residue) -- 6484

