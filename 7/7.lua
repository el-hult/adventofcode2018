-- https://adventofcode.com/2018/day/7

function string:iterlines()
	--iterate over the lines in the string 
	-- https://stackoverflow.com/questions/19326368/iterate-over-lines-including-blank-lines
	s = self
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end


function table.keys(t) 
	o = {}
	for k,_ in pairs(t) do 
		table.insert(o,k)
		end 
	 return o 
end
list = {}
function list.concat(t1,t2)
	o = {}
	for _,v1 in ipairs(t1) do table.insert(o,v1) end 
	for _,v2 in ipairs(t2) do table.insert(o,v2) end 
	return o 
end
function list.map(t,func)
	o = {}
	for k,v in ipairs(t) do
		table.insert(o,func(v))
	end
	return o
end
function list.all(t,predicate)
	for k,v in ipairs(t) do
		if not predicate(v) then return false end
	end
	return true
end
function list.filter(t,predicate)
	o = {}
	for k,v in ipairs(t) do
		if predicate(v) then table.insert(o,v) end
	end
	return o
end
function list.range(stop)
	o = {}
	for i=1,stop do
		table.insert(o,i)
	end
	return o
end


graph = {edges={},nodes={}}
function graph:add_edge(a,b)
	-- N.B. no error handling for duplicate edges! make sure the input is validated!
	if graph.nodes[a] == nil then graph:add_node(a) end
	if graph.nodes[b] == nil then graph:add_node(b)  end
	table.insert(self.edges,{parent=graph.nodes[a],child=graph.nodes[b]})
	table.insert(graph.nodes[a]['children'],graph.nodes[b])
	table.insert(graph.nodes[b]['parents'],graph.nodes[a])
end
function graph:add_node(label)
	if self.nodes[label] == nil
	then self.nodes[label] = {label=label,children={},parents={}}
	else error("ERROR: Node already existing!") 
	end
end
function graph:find_top()
	-- the top element in the pre-order is larger than everything else, and is called a terminal object in category theory.
	-- this algo assumes the top is a single element, and that the  graph is connected
	_,top_node_candidate = next(self.nodes)
	while #top_node_candidate.children ~= 0 do 
		_,top_node_candidate = next(top_node_candidate.children)
	end
	top_node = top_node_candidate
	return top_node
end
function graph:find_bottom()
	-- the bottom element in the pre-order is smaller than everything else, and is called a initial object in category theory.
	-- this algo assumes the bottom is a single element, and that the graph is connected
	_,bottom_node_candidate = next(self.nodes)
	while #bottom_node_candidate.parents ~= 0 do 
		_,bottom_node_candidate = next(bottom_node_candidate.parents)
	end
	bottom_node = bottom_node_candidate
	return bottom_node
end

-------------------------------------------------------------------------------------------------------------------------------- Specific code



function graph:assembly_order()
	
	--
	-- Find all start points in the assembly
	--
	o = {}
	to_visit = {}
	for _,node in pairs(graph.nodes) do
		if #node.parents == 0 then
			table.insert(to_visit,node)
			seen ={} ; seen[node.label] = true
		end
	end
	assembled = {} ; 
	
	
	--
	-- Make a flood filling on the assembly'able nodes
	--
	while #to_visit ~= 0 do
		table.sort(to_visit, function(a,b) return a.label > b.label end)
		node = table.remove(to_visit)
		table.insert(o,node.label)
		--print(node.label .. " has a known place element")
		assembled[node.label] = true
		
		for _,child in ipairs(node.children) do
			if seen[child.label] == nil then
				add_node = true
				for _,parent in ipairs(child.parents) do
					if not assembled[parent.label] then add_node = false end
				end
				if add_node == true then 
					seen[child.label] = true
					table.insert(to_visit,child)
				end
			end
		end
	end	
	return o
end

function graph:compute_worktime(min_time,n_elves)
	local order = self:assembly_order()
	local all_steps= self:assembly_order()
	local output_table = {}
	local completed_steps = {}
	
	for this_minute=1,10355 do -- loop over minutes of work. must be shorter than 10355
		work_this_minute = {}
		
		for elf=1,n_elves do
			can_pick_up_new_work = true
			worked_last_minute = this_minute>1 and output_table[this_minute-1][elf] ~= nil
			if  worked_last_minute then
				work_completed = completed_steps[output_table[this_minute-1][elf]] == true
				if not work_completed then
					can_pick_up_new_work = false
				end
			end
			
			if can_pick_up_new_work then
				for i = 1, #order do 
					next_step_label = order[i]
					prestep_labels = list.map(self.nodes[next_step_label].parents,function(node) return node.label end)
					presteps_done = list.all(prestep_labels,function(label) return completed_steps[label] end)
					if presteps_done then
						table.remove(order,i)
						work_this_minute[elf] = next_step_label
						--print("Elf "..elf.." picked up "..next_step_label.." for work")
						break
					else
						--print("Elf "..elf.." wants to pick up "..next_step_label.." for work, but must wait for "..table.concat(list.filter(prestep_labels,function(label) return not completed_steps[label] end)))
					end
				end
			else 
				work_this_minute[elf] = output_table[this_minute-1][elf]
				--print("Elf "..elf.." continues to work on ".. output_table[this_minute-1][elf])
			end
		end
		
		table.insert(output_table,work_this_minute)
		
		for elf=1,n_elves do
		
			work_item = work_this_minute[elf]
			if work_item then
				--print("Did "..work_item.." complete?")
				done = true
				for lookback=1,string.byte(work_item)-64+min_time do
					minute_to_check = this_minute-(lookback-1)
					--print("Looking back "..lookback.." minutes (checking minute "..minute_to_check..")")
					if minute_to_check < 1 then 
						done = false
						--print("Has not worked long enough.")
						break
					elseif output_table[minute_to_check][elf] ~= work_item then
						done = false
						--print("Did not work long enough - on this minute, the elf worked on ".. (output_table[minute_to_check][elf] or ""))
						break
					end
				end
				if done then
					completed_steps[work_item] = true
					--print("Work on "..work_item.." completed this round!")
				end
			end
		end
		
		fancy_work_list = list.map(list.range(n_elves),function(i) return (work_this_minute[i] or " ") end)
		--print(this_minute,table.concat(fancy_work_list,"\t"),"\tDone:",table.concat(table.keys(completed_steps),""))
		
		all_work_done = list.all(all_steps,function(label) return completed_steps[label] end)
		if all_work_done then return output_table end
	end
	error"Work should be done by now!"
end

f= assert(io.open("input.txt"))
true_input = f:read('a')

test_input = [[Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
]]


------------------------------------------------------------------------------------------------------------------------------------------- Run code

---[[  True case
input = true_input
min_time=60
n_elves=5
--]]


--[[ Test case
input = test_input
min_time=0
n_elves=2
--]]

for l in input:iterlines() do
	--print(l)
	local a,b = l:match"Step (%a) must be finished before step (%a) can begin."
	--print(l,a,b)
	graph:add_edge(a,b)
end

--[[
-- Print all edges in the same style as the input (different order though...)
--
print"showing the graph edges from out-bound"
for _,a in pairs(graph.nodes) do
	for _,b in pairs(a['children']) do
		print("Step "..a.label.." must be finished before step "..b.label.." can begin.")
	end
end

print"showing the graph edges from in-bound"
for _,b in pairs(graph.nodes) do
	for _,a in pairs(b['parents']) do
		print("Step "..a.label.." must be finished before step "..b.label.." can begin.")
	end
end

print"showing the graph edges from out-bound"
for _,v in ipairs(graph.edges) do
	print("Step "..v.parent.label.." must be finished before step "..v.child.label.." can begin.")
end
--]]


print("A :" .. table.concat(graph:assembly_order(),"")) --FMOXCDGJRAUIHKNYZTESWLPBQV
print("B :" .. #graph:compute_worktime(min_time,n_elves),"") --1053

