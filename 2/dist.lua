function string.hamming(str1,str2)
	-- https://codereview.stackexchange.com/q/33896/148834
	local distance = 0

	-- cannot calculate Hamming distance if strings have different sizes
	if #str1 ~= #str2 then return false end

	for i = 1, #str1 do
		if str1:sub(i,i) ~= str2:sub(i,i) then
			distance = distance + 1 
		end
	end

	return distance
end