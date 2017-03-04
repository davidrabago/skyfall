local vector = require("lib.hump.vector")

local player1 = {
  location = vector(),
  size = vector(48, 48),
  
  max_speed = 400,
  speed = 0,
  accel = 1000,
  
  score = 0,
  
  img = nil,
  
  fruitType = "apple",
}

local player2 = {
  location = vector(),
  size = vector(48, 48),
  
  max_speed = 400,
  speed = 0,
  accel = 1000,
  
  score = 0,
  
  fruitType = "banana",
}

local fruit_frames = {}
local fruit_spritesheet

local monkey_frames = {}
local monkey_spritesheet

local tenSecondTimer = 10

local fruitTimerMax = .25
local fruitTimer = fruitTimerMax
local fruits = {}

local fruitFlag = 0

function love.load()
  fruit_spritesheet = love.graphics.newImage("assets/Vegies.png")
  fruit_frames[1] = love.graphics.newQuad(0, 0, 32, 32, fruit_spritesheet:getDimensions())
  fruit_frames[2] = love.graphics.newQuad(420, 0, 32, 32, fruit_spritesheet:getDimensions())
  
  monkey_spritesheet = love.graphics.newImage("assets/monkey.png")
  monkey_frames[1] = love.graphics.newQuad(0,25, 32, 48, monkey_spritesheet:getDimensions())
  monkey_frames[2] = love.graphics.newQuad(160, 25, 24, 48, monkey_spritesheet:getDimensions())
  
  love.graphics.setFont(love.graphics.newFont("assets/score.ttf", 18))
  
  player1.location.x = player1.size.x + 24
  player1.location.y = love.graphics.getHeight() - player1.size.y
  
  player2.location.x = love.graphics.getWidth() - player2.size.x - 24
  player2.location.y = love.graphics.getHeight() - player2.size.y
end

function love.update(delta)
  if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
  
  handleTimers(delta)
  handlePlayerMovement(delta)
  handleFruits(delta)
end

function love.draw()
  love.graphics.draw(monkey_spritesheet, monkey_frames[1], player1.location.x, player1.location.y)
  love.graphics.draw(monkey_spritesheet, monkey_frames[2], player2.location.x, player2.location.y)
  
  for i, v in ipairs(fruits) do
    love.graphics.draw(fruit_spritesheet, v.img, v.location.x, v.location.y)
  end
  
  love.graphics.print("Time: " .. math.ceil(tenSecondTimer))
  
  love.graphics.printf(player1.score .. "", player1.location.x, player1.location.y - 20, player1.size.x, 'center')
  love.graphics.printf(player2.score .. "", player2.location.x, player2.location.y - 20, player1.size.x, 'center')
  
end

function fruitSpawnApple()
  local fruit = {
    location = vector(),
    size = vector(24, 24),
    
    speed = 160,
    
    img = fruit_frames[1],
    
    fruitType = "apple",
  }
  
  fruit.location.x = math.random(0, love.graphics.getWidth())
  fruit.location.y = 0
  
  table.insert(fruits, fruit)
end

function handleTimers(delta)
  tenSecondTimer = tenSecondTimer -  delta
  if tenSecondTimer < 0 then
    tenSecondTimer = 10
  end
  
  fruitTimer = fruitTimer - delta
  if (fruitTimer < 0) then
    if fruitFlag == 0 then
      fruitSpawnApple()
      fruitFlag = 1
    elseif fruitFlag == 1 then
      fruitSpawnBanana()
      fruitFlag = 0
    end
    fruitTimer = fruitTimerMax
  end
end


function handlePlayerMovement(delta)
  if love.keyboard.isDown("a") then
    player1.speed = player1.speed - (player1.accel * delta)
    if player1.speed < player1.max_speed * -1 then
      player1.speed = -player1.max_speed
    end
  elseif love.keyboard.isDown("d") then
    player1.speed = player1.speed + (player1.accel * delta)
    if player1.speed > player1.max_speed then
      player1.speed = player1.max_speed
    end
  else
    if player1.speed > 0 then player1.speed = player1.speed - (player1.accel * delta) end
    if player1.speed < 0 then player1.speed = player1.speed + (player1.accel * delta) end
  end
  
  player1.location.x = player1.location.x + (player1.speed * delta)
  if player1.location.x < 0 then 
    player1.location.x = 0 
  elseif player1.location.x + player1.size.x > love.graphics.getWidth() then
    player1.location.x = love.graphics.getWidth() - player1.size.x
  end
  
  if love.keyboard.isDown("left") then
    player2.speed = player2.speed - (player2.accel * delta)
    if player2.speed < player2.max_speed * -1 then
      player2.speed = -player2.max_speed
    end
  elseif love.keyboard.isDown("right") then
    player2.speed = player2.speed + (player2.accel * delta)
    if player2.speed > player2.max_speed then
      player2.speed = player2.max_speed
    end
  else
    if player2.speed > 0 then player2.speed = player2.speed - (player2.accel * delta) end
    if player2.speed < 0 then player2.speed = player2.speed + (player2.accel * delta) end
  end
  
  player2.location.x = player2.location.x + (player2.speed * delta)
  if player2.location.x < 0 then 
    player2.location.x = 0 
  elseif player2.location.x + player2.size.x > love.graphics.getWidth() then
    player2.location.x = love.graphics.getWidth() - player2.size.x
  end
end

function handleFruits(delta)
    for i, v in ipairs(fruits) do
    local modified = false
    
    v.location.y = v.location.y + (v.speed * delta)
    
    if v.location.y + v.size.y > love.graphics.getHeight() then
      table.remove(fruits, i)
      modified = true
    end
    
    -- Collisions
    
    coinFlip = math.random(1,2)
    
    if(coinFlip==1) then
      if CheckCollisionVec(v.location, v.size, player1.location, player1.size) and not modified then
        if v.fruitType == player1.fruitType then 
          player1.score = player1.score + 1
          table.remove(fruits, i)
        end
      end
    elseif(coinFlip==2) then
      if CheckCollisionVec(v.location, v.size, player2.location, player2.size) and not modified then
        if v.fruitType == player2.fruitType then
          player2.score = player2.score + 1
          table.remove(fruits, i)
        end
      end
    end
  end
end

function fruitSpawnBanana()
  local fruit = {
    location = vector(),
    size = vector(24, 24),
    
    speed = 160,
    
    img = fruit_frames[2],
    
    fruitType = "banana",
  }
  
  fruit.location.x = math.random(0, love.graphics.getWidth())
  fruit.location.y = 0
  
  table.insert(fruits, fruit)
end

function CheckCollisionVec(loc1, size1, loc2, size2)
  return CheckCollision(loc1.x, loc1.y, size1.x, size1.y, loc2.x, loc2.y, size2.x, size2.y)
end


-- Collision detection function.
-- Checks if a and b overlap.
-- w and h mean width and height.
function CheckCollision(ax1,ay1,aw,ah,bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end


function moveToPointer(delta)  
  local direction = vector(love.mouse.getX() - player1.location.x, love.mouse.getY() - player1.location.y)
  local distance = direction:len()
  local unit = direction:normalized()
  
  local speed = math.min(distance * player1.decel, player1.max_speed)
  local movement = unit * (speed * delta)
  
  player1.location = player1.location + movement
end
