--[[
	SpriteAnimator
]]
SpriteAnimator = {}
SpriteAnimator.__index = SpriteAnimator

local function new(anim)
	local sa = {}
	setmetatable(sa, SpriteAnimator)	

	sa.isComponent = true
	sa.name = "animator"

	sa.lastUpdate = love.timer.getTime()
	sa.curFrame = 1

	if anim then
		sa:setAnim(anim)
	end
	return sa
end

function SpriteAnimator:init()
	assert(self.go, self.name.." component has no GameObject")
	assert(self.go.renderer, self.name.." needs a renderer component")
	
	if (self.anim) then
		--self:setAnim(self.anim.name)
	end
end

function SpriteAnimator:update(dt)
	if (self.anim) then
		if (love.timer.getTime() - self.lastUpdate > self.anim.timestep) then
			self.curFrame = self.curFrame + 1
			if (self.curFrame > self.anim.size) then
				if (self.anim.loop) then
					self.curFrame = 1
				else
					self.curFrame = self.anim.size
				end
			end
			self.go.renderer.quad = self.anim.frames[self.curFrame].quad

			self.lastUpdate  = love.timer.getTime()
		end
	end
end

function SpriteAnimator:setAnim(name)
	self.anim = ResourceMgr.get("anim", name)
	if (self.go) then
		self.go.renderer.texture = self.anim.texture
		self.go.renderer.quad = self.anim.frames[1].quad
		if (self.go.collider and self.anim.colBox) then
			self.go.collider:updateRect(0,0,self.anim.colBox.w, self.anim.colBox.h)
			self.go.renderer.offsetX = self.anim.offsetX
			self.go.renderer.offsetY = self.anim.offsetY
		end
	end
end

function SpriteAnimator:clone()
	return new(self.anim.name)
end

setmetatable(SpriteAnimator, {__call = function(_, ...) return new(...) end})