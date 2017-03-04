local vector = require("lib.hump.vector")

local player1 = {
  location = vector(),
  size = vector(48, 48),
  
  max_speed = 400,
  accel = 20,
  
  score = 0,
  
  img = nil,
}

local player2 = {
  location = vector(),
  size = vector(48, 48),
  
  max_speed = 400,
  accel = 20,
  
  score = 0,
  
  img = nil,
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
  
  tenSecondTimer = tenSecondTimer -  delta
  if tenSecondTimer < 0 then
    tenSecondTimer = 10
  end
  
  -- keyboard actions for our characters
  widthOfGame = love.graphics.getWidth() - 40
  
  if love.keyboard.isDown("a") then
    if player1.location.x > 0 then
      player1.location.x = player1.location.x - player1.max_speed*delta
    end
  elseif love.keyboard.isDown("d") then
    if player1.location.x < widthOfGame then
    player1.location.x = player1.location.x + player1.max_speed*delta
    end
  end
  
  if love.keyboard.isDown("left") then
    if player2.location.x > 0 then
      player2.location.x = player2.location.x - player2.max_speed*delta
    end
  elseif love.keyboard.isDown("right") then
    if player2.location.x < widthOfGame then
    player2.location.x = player2.location.x + player2.max_speed*delta
    end
  end
  
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
        player1.score = player1.score + 1
        table.remove(fruits, i)
      elseif CheckCollisionVec(v.location, v.size, player2.location, player2.size) and not modified then
        player2.score = player2.score + 1
        table.remove(fruits, i)
      end
    elseif(coinFlip==2) then
      if CheckCollisionVec(v.location, v.size, player2.location, player2.size) and not modified then
        player2.score = player2.score + 1
        table.remove(fruits, i)
      elseif CheckCollisionVec(v.location, v.size, player1.location, player1.size) and not modified then
        player1.score = player1.score + 1
        table.remove(fruits, i)
      end
    end
    
  end
  
  -- Timers
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
  }
  
  fruit.location.x = math.random(0, love.graphics.getWidth())
  fruit.location.y = 0
  
  table.insert(fruits, fruit)
end

function fruitSpawnBanana()
  local fruit = {
    location = vector(),
    size = vector(24, 24),
    
    speed = 160,
    
    img = fruit_frames[2],
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
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
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
