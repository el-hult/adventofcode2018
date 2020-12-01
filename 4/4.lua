require"lib4"

f = io.open("input4.txt",'r')
input = f:read('a')

input_as_t = {}
for line in input:iterlines() do
	table.insert(input_as_t,line)
end
table.sort(input_as_t,function(a,b) --in place sorting
	return a:sub(2,17) < b:sub(2,17)
end)

total = "Total"
maxminute = "MaxMinute"

sleep_record = {}
for k,line in ipairs(input_as_t) do
	yyyy,MM,dd,hh,mm,ss = line:match"%[(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d)%] (.+)"
	--print(line)
	if ss=="falls asleep" then
		sleep_start = tonumber(mm)
	elseif ss == "wakes up" then
		sleep_end = tonumber(mm)
		duration = sleep_end - sleep_start
		current_sleep_record = sleep_record[gid] or {}
		for minute = sleep_start,sleep_end do
			current_sleep_record[minute] = 1+(current_sleep_record[minute] or 0)
		end
		current_sleep_record[total] = duration + (current_sleep_record[total] or 0)
		sleep_record[gid] = current_sleep_record
	else
		gid = ss:match"Guard #(%d+) begins shift"
	end
end

print("Guard",total,maxminute, "MaxMinVal")
for guard,record in spairs(sleep_record,function(t,a,b) 
	return t[a][total] > t[b][total] 
	end) do
	maxmin = 0
	maxnow = 0
	for minute = 0,59 do
		if (record[minute] or 0) > maxnow then
			maxmin = minute;
			maxnow = record[minute]
			end
		record[maxminute] = maxmin
	end
	print(guard,record[total],record[maxminute],record[record[maxminute]])
end

id_of_guard_that_sleeps_the_most,record = argmin(sleep_record,function(a,b) return a[total] > b[total] end)
print("The guard "..id_of_guard_that_sleeps_the_most.." sleeps the most")
print("A: "..tonumber(id_of_guard_that_sleeps_the_most)*record[maxminute]) --143415 is correct


id_of_guard_that_sleeps_most_regular,record = argmin(sleep_record,
	function(a,b) return a[a[maxminute]] > b[b[maxminute]] end)
print("The guard "..id_of_guard_that_sleeps_most_regular.." sleeps most regular")
print("B: "..tonumber(id_of_guard_that_sleeps_most_regular)*record[maxminute]) --49944 is correct
