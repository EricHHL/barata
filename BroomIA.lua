--[[
	BroomIA: Controla a vassoura
]]
BroomIA = {}
BroomIA.__index = BroomIA

local function new(...)
	local bia = {}
	setmetatable(bia, BroomIA)	

	bia.isComponent = true
	bia.name = "enemy"

	bia.reach = 256

	bia.cooldown = 4	--Segundos entre ataques
	bia.attackTime = 0.3
	bia.lastAttack = love.timer.getTime()	

	bia.isAttacking = false

	return bia
end

function BroomIA:init()
	self.barata = GameMgr.getPlayer()
	
	self.go.renderer.offsetOX = self.go.renderer.texture:getWidth()/2
end

function BroomIA:update(dt)
	self:updateCollider()
	self.barataDist = dist(self.go.transform.x,self.go.transform.y,self.barata.transform.x,self.barata.transform.y)
	if not self.isAttacking then
		self:lookAt(self.barata.transform.x, self.barata.transform.y)
	end
	if (love.timer.getTime() - self.lastAttack > self.cooldown) and (self.barataDist < self.reach) and self.barata.motor.isAlive then
		local fX, fY = self.barata.transform.x + self.barata.motor.speedX * self.attackTime / dt * 0.8, self.barata.transform.y + self.barata.motor.speedY * self.attackTime / dt * 0.8
		self:lookAt(fX, fY)
		self.barataDist = dist(self.go.transform.x,self.go.transform.y, fX, fY)
		self:attack()
	end
end

function BroomIA:attack()
	self.isAttacking = true
	Timer.tween(self.attackTime, self.go.transform, {sy = self.barataDist/self.reach}, "in-cubic", function()
		Timer.tween(self.cooldown, self.go.transform, {sy = 0.5}, "out-quad")
		self.isAttacking = false
		self:updateCollider()
		local actualX, actualY, cols, len = physics:check(self.go)
		for k,v in pairs(cols) do
			if(v.other == self.barata)then
				self.barata.motor:die()
				pprint("morreu","a")
			end
		end
	end)
	self.lastAttack  = love.timer.getTime()
end

function BroomIA:updateCollider()
	local colY = math.cos(self.go.transform.o) * self.go.transform.sy * self.go.renderer.texture:getHeight()-25
	local colX = -math.sin(self.go.transform.o) * self.go.transform.sy * self.go.renderer.texture:getHeight()-25
	self.go.collider:updateRect(colX,colY)
end

function BroomIA:lookAt(x,y)
self.go.transform.o = -math.atan2(x - self.go.transform.x, y - self.go.transform.y)
end

function BroomIA:clone()
	return new()
end

setmetatable(BroomIA, {__call = function(_, ...) return new(...) end})