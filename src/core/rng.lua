-- A tiny seedable PRNG (Park-Miller LCG) so shuffles are deterministic and
-- reproducible across platforms. Pure: no love.* and no global math.random state.
local M = {}

function M.new(seed)
	local state = (seed or 1) % 2147483647
	if state <= 0 then
		state = state + 2147483646
	end
	-- random()  -> float in [0, 1); random(n) -> integer in [1, n].
	return {
		random = function(_, n)
			state = (state * 16807) % 2147483647
			local r = (state - 1) / 2147483646
			if n then
				return math.floor(r * n) + 1
			end
			return r
		end,
	}
end

return M
