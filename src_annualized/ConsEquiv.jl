using Roots
function ConsEquiv(m, W)
	function f(x)
		set_param!(m, :neteconomy, :CEQ, x)
		run(m)
		diff = W - m[:welfare, :UTILITY]
		return diff
	end
CEQ = find_zero(f, (0, 2), Bisection())
CEQ = CEQ*1e12
return CEQ
end