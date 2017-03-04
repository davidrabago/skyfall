local vector = require("lib.hump.vector")

local player1 = {
  location = vector(),
  size = vector(48, 48),
  
  max_speed = 400,
  accel = 20,
  
  img = nil,
}

local player2 = {
  location = vector(),
  size = vector(48, 48),
  
  max_speed = 400,
  accel = 20,
  
  img = nil,
}

local spr_apple = nil

local fruitTimerMax = .25
local fruitTimer = fruitTimerMax
local fruits = {}

function love.load()
  player1.img = love.graphics.newImage("assets/player1.png")
  player2.img = love.graphics.newImage("assets/player2.png")
  spr_apple = love.graphics.newImage("assets/apple.png")
  
  player1.location.x = player1.size.x + 24
  player1.location.y = love.graphics.getHeight() - player1.size.y
  
  player2.location.x = love.graphics.getWidth() - player2.size.x - 24
  player2.location.y = love.graphics.getHeight() - player2.size.y
  
  fruitSpawner()
end

function love.update(delta)
  for i, v in ipairs(fruits) do
    v.location.y = v.location.y + (v.speed * delta)
  end
  
  -- Timers
  fruitTimer = fruitTimer - delta
  if (fruitTimer < 0) then
    fruitSpawner()
    fruitTimer = fruitTimerMax
  end
  
end

function love.draw()
  love.graphics.draw(player1.img, player1.location.x, player1.location.y)
  love.graphics.draw(player2.img, player2.location.x, player2.location.y)
  
  for i, v in ipairs(fruits) do
    love.graphics.draw(v.img, v.location.x, v.location.y)
  end
end

function fruitSpawner()
  local fruit = {
    location = vector(),
    size = vector(24, 24),
    
    speed = 160,
    
    img = spr_apple,
  }
  
  fruit.location.x = math.random(0, love.graphics.getWidth())
  fruit.location.y = 0
  
  table.insert(fruits, fruit)
end

function moveToPointer(delta)  
  local direction = vector(love.mouse.getX() - player1.location.x, love.mouse.getY() - player1.location.y)
  local distance = direction:len()
  local unit = direction:normalized()
  
  local speed = math.min(distance * player1.decel, player1.max_speed)
  local movement = unit * (speed * delta)
  
  player1.location = player1.location + movement
end
