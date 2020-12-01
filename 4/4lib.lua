function string:iterlines()
	--iterate over the lines in the string 
	-- https://stackoverflow.com/questions/19326368/iterate-over-lines-including-blank-lines
	s = self
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end