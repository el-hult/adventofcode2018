
function iskip(iter,skips)
	for i = 1,(skips) do
		iter()
	end
	return iter
end

function enumerate(iter)
	n =0
	return function()
		n = n+1
		val = iter()
		if val then return n,val
		else return nil
		end
	end
end

function izip(iter1,iter2)
	return function()
		return iter1(),iter2()
	end
end

function filter(iter,predicate)
	return function()
		while true do
			
			val = {iter()}
			if val[1] then else return nil end
			if predicate(table.unpack(val)) then   return table.unpack(val) end
		end
	end
end

function string:chars()
	return string.gmatch(self,".")
end

function iterlines(s)
	--iterate over the lines in the string 
	-- https://stackoverflow.com/questions/19326368/iterate-over-lines-including-blank-lines
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end

function count(base, pattern)
	-- count occurrences in a string 
	-- https://stackoverflow.com/a/51256340/4050510
    return select(2, string.gsub(base, pattern, ""))
end

function trim1(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end
-- from PiL2 20.4 - programming in lua, chapter 20.4

------------------------------------------------------


f = io.open("aoc2018_2_input.txt",'r')
input = f:read('a')
--print(input)

------------------------------------------------ A


doubles = 0
triples = 0
for line in iterlines(input) do
	charcount = {}
	for c in line:chars() do --char iterator https://stackoverflow.com/a/832414/4050510
		val = charcount[c]
		if val then charcount[c] = val+1
		else charcount[c] = 1 end
	end
	hastwo = 0
	hasthree = 0
	for k,v in pairs(charcount) do
		if v == 2 then hastwo = 1 end
		if v == 3 then hasthree = 1 end
	end
	doubles = doubles + hastwo
	triples = triples + hasthree
end
print("A: " .. doubles*triples) -- 4940 i correct


------------------------------------------ B
require "dist"
for i,line1 in enumerate(iterlines(input)) do
	for line2 in iskip(iterlines(input),i) do
		dist = line1:hamming(line2)
		if dist == 1 then
			a = ""
			for c,_ in filter(izip(line1:chars(),line2:chars()),function(a,b) return a==b end) do
				a = a .. c
				end
			print("B: " .. a)
			foundit = true
			break
		end
	end
	if foundit then break end
end