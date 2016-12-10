--[[
	CharacterMotor: Controla a barata
]]

CharacterMotor = {}
CharacterMotor.__index = CharacterMotor

local function new()
	local cm = {}
	setmetatable(cm, CharacterMotor)	

	cm.isComponent = true
	cm.name = "motor"

	cm.isAlive = true
	cm.maxSpeed = 375
	cm.accSpeed = 100
	cm.turnSpeed = 5

	cm.fwdSpeed = 0
	cm.speedX = 0
	cm.speedY = 0


	return cm
end

function CharacterMotor:init()
	assert(self.go, self.name.." component has no GameObject")
	assert(self.go.collider, self.name.." needs a collider component")
end

function CharacterMotor:update(dt)
	if not self.isAlive then
		return
	end
	self.speedX = (math.sin(self.go.transform.o)) * self.fwdSpeed * dt
    self.speedY = -(math.cos(self.go.transform.o)) * self.fwdSpeed * dt
	local nX, nY, cols, n = physics:move(self.go, self.go.transform.x + self.speedX, self.go.transform.y + self.speedY, function(a, b)
		if(b.food or b.enemy) then
			return "cross"
		else
			return "slide"
		end
	end)

	for k,v in pairs(cols) do
		if v.other.food then
			GameMgr.addScore(10)
			v.other:destroy()
		end
	end
	
	self.go.transform:translate(nX, nY)

	self.fwdSpeed = self.fwdSpeed * 0.8
	if(self.fwdSpeed<10)then
		self.fwdSpeed = 0
	end

	pprint("fwdSpeed = "..self.fwdSpeed)
	pprint("speedX = "..self.speedX)
	pprint("speedY = "..self.speedY)
end

function CharacterMotor:turn(dir)
	self.go.transform.o = self.go.transform.o + (dir * self.turnSpeed)
end

function CharacterMotor:move(dir)
	self.fwdSpeed = math.min(self.fwdSpeed + (dir * self.accSpeed), self.maxSpeed)
    --modelPosition += Vector3.Forward * speedz;
    --modelPosition += Vector3.Left * speedx;
end

function CharacterMotor:die()
	self.isAlive = false
end

function CharacterMotor:clone()
	return new()
end

setmetatable(CharacterMotor, {__call = function(_, ...) return new(...) end})