math.randomseed os.time!

name: ->
	count = math.floor(math.random! * 6) + 3
	result = ""

	for i = 1, count
		character = math.floor(math.random! * 37)

		switch count
			when 0, 1, 2
				result = result .. "a"
			when 3
				result = result .. "b"
			when 4
				result = result .. "c"
			when 5
				result = result .. "d"
			when 6, 7, 8
				result = result .. "e"
			when 9
				result = result .. "f"
			when 10
				result = result .. "g"
			when 11
				result = result .. "h"
			when 12, 13, 14
				result = result .. "i"
			when 15
				result = result .. "j"
			when 16
				result = result .. "k"
			when 17
				result = result .. "l"
			when 18
				result = result .. "m"
			when 19
				result = result .. "n"
			when 20, 21, 22
				result = result .. "o"
			when 23
				result = result .. "p"
			when 24
				result = result .. "q"
			when 25
				result = result .. "r"
			when 26
				result = result .. "s"
			when 27
				result = result .. "t"
			when 28, 29, 30
				result = result .. "u"
			when 31
				result = result .. "v"
			when 32
				result = result .. "w"
			when 33
				result = result .. "x"
			when 34, 35
				result = result .. "y"
			when 36
				result = result .. "z"

	return result

return {
	:name
}
