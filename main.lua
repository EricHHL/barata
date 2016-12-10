--Principais
require("GameObject")
require("Scene")

--Componentes
require("Transform")
require("Renderer")
require("BoxCollider")
require("SpriteAnimator")
require("PlayerInput")
require("CharacterMotor")

require("Food")
require("BroomIA")

--Outros
require("Color")
ResourceMgr = require("ResourceManager")
GameMgr = require("GameManager")

local bump = require("lib.bump")
local bumpdebug = require("lib.bump_debug")
Timer = require("lib.hump.timer")

gui = require("lib.gui.gui")

local pprintList = {}

function love.load()

	physics = bump.newWorld(168)	--Tem que colocar isso em algum outro lugar	
	initExtraPhysics()
	initResources()	

	GUI = gui()
	font = love.graphics.getFont()


	love.graphics.setBackgroundColor(200, 200, 200)

	barata = GameObject("barata", {Renderer(barataTex), BoxCollider(24,24), CharacterMotor(), PlayerInput()}):newInstance({x = 100, y = 100, sx = 0.5, sy = 0.5})

	barata.renderer.offsetX = 12
	barata.renderer.offsetY = 12
	barata.renderer.offsetOX = 32
	barata.renderer.offsetOY = 32
	
	GameMgr.init(barata)


	food = GameObject("food", {Renderer(foodTex), BoxCollider(16, 16), Food()})
	broom = GameObject("v", {Renderer(broomTex), BoxCollider(50,50), BroomIA()})

	testScene = Scene()
	testScene:addGO(barata)

	testScene:addGO(broom:newInstance({x = 300, y = 500, o = 150, sy = 0.5}))
	testScene:addGO(broom:newInstance({x = 10, y = 400, o = 150, sy = 0.5}))
	testScene:addGO(broom:newInstance({x = 500, y = 100, o = 150, sy = 0.5}))
	testScene:addGO(broom:newInstance({x = 700, y = 300, o = 150, sy = 0.5}))

	for i=1,20 do
		testScene:addGO(food:newInstance({x = love.math.random()*love.graphics.getWidth(), y = love.math.random() * love.graphics.getHeight()}))		
	end
end

function love.update(dt)
	testScene:update(dt)
	Timer.update(dt)
end

function love:draw()
	testScene:draw()

	GameMgr.draw()

	bumpdebug.draw(physics)

	pprintDraw()
end

function initResources()
	barataTex = ResourceMgr.get("texture", "barata.png")
	foodTex = ResourceMgr.get("texture", "food.png")
	broomTex = ResourceMgr.get("texture", "broom.png")
end

function initExtraPhysics()	--Achar um lugar pra por isso
	local oneway = function(world, col, x,y,w,h, goalX, goalY, filter)
  		local cols, len = world:project(col.item, x,y,w,h, goalX, goalY, filter)
		return goalX, math.min(goalY,col.item.transform.y), cols, len
	end
	local slope = function(world, col, x,y,w,h, goalX, goalY, filter)

		col.normal = {x = 0, y = 0}	--Até provado o contrario, não teve realmente uma colisão
  		local range = math.abs(col.other.collider.rightY-col.other.collider.leftY)

  		local charBase = math.min(math.max(col.item.transform.x + col.item.collider.w/2,col.other.transform.x), col.other.transform.x + col.other.collider.w)
  		local xNormal = (charBase - col.other.transform.x) / col.other.collider.w
  		if (col.other.collider.rightY < col.other.collider.leftY) then
  			xNormal = 1 - xNormal
  		end
  		local slopeY = (col.other.transform.y+col.other.collider.h) - ((xNormal * range) * col.other.collider.h) - math.min(col.other.collider.rightY, col.other.collider.leftY) * col.other.collider.h
  		slopeY = slopeY - col.item.collider.h
		if (goalY>slopeY) then
			col.normal = {x = 0, y = -1}	--Foi provado o contrario, teve colisão
		end

		return goalX, math.min(goalY,slopeY), {}, 0
	end

	physics:addResponse("slope", slope)

end

function dist(x1, y1, x2, y2)
	return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
end

--Print para depurar valores contínuos
function pprint(text, name)
	if name then
		pprintList[name] = text
	else
		pprintList[#pprintList+1] = text
	end
end

function pprintDraw()
	love.graphics.setColor(0, 0, 0)
	local j = 0
	for i,v in ipairs(pprintList) do
		love.graphics.print(v, 10, j*10)
		pprintList[i] = nil
		j = j + 1
	end
	for k,v in pairs(pprintList) do
		love.graphics.print(v, 10, j*10)
		j = j + 1
	end
end