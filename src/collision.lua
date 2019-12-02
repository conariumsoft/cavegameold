local collision = {}

--- Axis-Aligned Bounding-Box overlap check.
-- @param ax x of box A
-- @param ay y of box A
-- @param aw 1/2 width of box A (distance from the edge of the box to the center)
-- @param ah 1/2 height of box A (distance from the edge of the box to the center)
-- @param bx x of box B
-- @param by y of box B
-- @param bw 1/2 width of box B (distance from the edge of the box to the center)
-- @param bh 1/2 height of box B (distance from the edge of the box to the center)
-- @return boolean
function collision.aabb(ax, ay, aw, ah, bx, by, bw, bh)
	local distanceX = ax - bx
	local distanceY = ay - by

	local absDistX = math.abs(distanceX)
	local absDistY = math.abs(distanceY)

	local sumWidth = aw + bw
	local sumHeight = ah + bh

	if absDistX >= sumWidth or absDistY >= sumHeight then
		return false -- no intersection
	end
	return true
end

--- AABB separation test (Find the separation between two overlapping boxes)
-- @see collision.aabb
-- @return number sx, sy
function collision.test(ax, ay, aw, ah, bx, by, bw, bh)

	local distanceX = ax - bx
	local distanceY = ay - by

	local absDistX = math.abs(distanceX)
	local absDistY = math.abs(distanceY)

	local sumWidth = aw + bw
	local sumHeight = ah + bh

	if absDistY >= sumHeight or absDistX >= sumWidth  then
		return false -- no intersection
	end

	local sx, sy = sumWidth - absDistX, sumHeight - absDistY

	if sx > sy then
		if sy > 0 then
			sx = 0
		end
	else
		if sx > 0 then
			sy = 0
		end
		
	end

	if distanceX < 0 then
		sx = -sx
	end
	if distanceY < 0 then
		sy = -sy
	end

	return sx, sy
end

--- Get the collision normal for two overlapping rectangles
-- @return number nx, ny
function collision.solve(sx, sy, velx, vely)
	-- find collision normal
	local d = math.sqrt(sx * sx + sy * sy)
	local nx, ny = sx / d, sy / d

	-- relative velocity?
	-- will add later when entities are actually coded
	local vx, vy = velx, vely

	-- penetration speed
	local ps = vx * nx + vy * ny

	if ps <= 0 then
		return nx, ny
	end
end

return collision