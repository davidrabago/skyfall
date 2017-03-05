------------------------------------- Imports ------------------------------------------------------------
local vector = require("lib.hump.vector")
local isEnd
------------------------------------- Declarations ------------------------------------------------------------
local player1 = {
  location = vector(),
  size = vector(24, 48),
  
  max_speed = 400,
  speed = vector(0,0),
  accel = 1000,
  
  score = 0,
  
  img = nil,
  
  fruitType = "apple",
}

local player2 = {
  location = vector(),
  size = vector(24, 48),
  
  max_speed = 400,
  speed = vector(0,0),
  accel = 1000,
  
  score = 0,
  
  fruitType = "banana",
}

local background_img

local fruit_frames = {}
local fruit_spritesheet

local monkey_frames = {}
local monkey_spritesheet

local tenSecondTimer = 10

local fruitTimerMax = .25
local fruitTimer = fruitTimerMax
local fruits = {}

local fruitFlag = 0

------------------------------------- On Start Actions ------------------------------------------------------------
function love.load()
  background_img = love.graphics.newImage("assets/background.jpg")
  
  fruit_spritesheet = love.graphics.newImage("assets/Vegies.png")
  fruit_frames[1] = love.graphics.newQuad(0, 0, 32, 32, fruit_spritesheet:getDimensions())
  fruit_frames[2] = love.graphics.newQuad(420, 0, 32, 32, fruit_spritesheet:getDimensions())
  
  monkey_spritesheet = love.graphics.newImage("assets/monkey.png")
  monkey_frames[1] = love.graphics.newQuad(5,25, 24, 48, monkey_spritesheet:getDimensions())
  monkey_frames[2] = love.graphics.newQuad(160, 25, 24, 48, monkey_spritesheet:getDimensions())
  
  love.graphics.setFont(love.graphics.newFont("assets/score.ttf", 14))
  
  player1.location.x = player1.size.x + 24
  player1.location.y = love.graphics.getHeight() - player1.size.y
  
  player2.location.x = love.graphics.getWidth() - player2.size.x - 24
  player2.location.y = love.graphics.getHeight() - player2.size.y
end

------------------------------------- Update Screen ------------------------------------------------------------
function love.update(delta)
  if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
  
  handleTimers(delta)
  handlePlayerMovement(delta)
  handlePlayerCollision(delta)
  handleFruits(delta)
  
  if(isEnd) then
    if love.keyboard.isDown("r")  then
      player1.location.x = player1.size.x + 24
      player1.location.y = love.graphics.getHeight() - player1.size.y
      player1.speed.x = 0
      player1.speed.y = 0
      player1.score = 0
      player2.location.x = love.graphics.getWidth() - player2.size.x - 24
      player2.location.y = love.graphics.getHeight() - player2.size.y
      player2.speed.x = 0
      player2.speed.y = 0
      player2.score = 0
      tenSecondTimer = 10
      isEnd = false
    end
  end
end

------------------------------------- Drawing Stuff to Screen ------------------------------------------------------------
function love.draw()
  love.graphics.draw(background_img, 0, 0)
  love.graphics.draw(monkey_spritesheet, monkey_frames[1], player1.location.x, player1.location.y)
  love.graphics.draw(monkey_spritesheet, monkey_frames[2], player2.location.x, player2.location.y)
  
  for i, v in ipairs(fruits) do
    love.graphics.draw(fruit_spritesheet, v.img, v.location.x, v.location.y)
  end
  
  if math.ceil(tenSecondTimer) > 0 then
    love.graphics.print("Time: " .. math.ceil(tenSecondTimer), love.graphics.getWidth()/2)
  end
  
  love.graphics.printf(player1.score .. "", player1.location.x, player1.location.y - 20, player1.size.x, 'center')
  love.graphics.printf(player2.score .. "", player2.location.x, player2.location.y - 20, player1.size.x, 'center')
  
  if(isEnd) then
    if(player1.score>player2.score) then 
      love.graphics.printf("Player 1 Wins",0, love.graphics.getHeight()/2, love.graphics.getWidth(), 'center')
    elseif(player2.score>player1.score) then 
      love.graphics.printf("Player 2 Wins",0, love.graphics.getHeight()/2, love.graphics.getWidth(), 'center')
    else 
      love.graphics.printf("Its a Tie",0, love.graphics.getHeight()/2, love.graphics.getWidth(), 'center')
    end
    love.graphics.printf("GAME OVER",0, love.graphics.getHeight()/2 - 20, love.graphics.getWidth(), 'center')
    love.graphics.printf("Press 'r' to restart game",0, love.graphics.getHeight()/2 + 20, love.graphics.getWidth(), 'center')
  end
end

------------------------------------- Spawning Stuff ------------------------------------------------------------
function fruitSpawnApple()
  local fruit = {
    location = vector(),
    size = vector(24, 24),
    
    speed = 160,
    
    img = fruit_frames[1],
    
    fruitType = "apple",
  }
  
  fruit.location.x = math.random(0, love.graphics.getWidth() - fruit.size.x)
  fruit.location.y = 0
  
  table.insert(fruits, fruit)
end

function fruitSpawnBanana()
  local fruit = {
    location = vector(),
    size = vector(24, 24),
    
    speed = 160,
    
    img = fruit_frames[2],
    
    fruitType = "banana",
  }
  
  fruit.location.x = math.random(0, love.graphics.getWidth() - fruit.size.x)
  fruit.location.y = 0
  
  table.insert(fruits, fruit)
end

------------------------------------- Timers ------------------------------------------------------------
function handleTimers(delta)
  tenSecondTimer = tenSecondTimer -  delta
  if tenSecondTimer < 0 then
    endGame()
  end
  
  fruitTimer = fruitTimer - delta
  if fruitTimer < 0 and tenSecondTimer > 0 then
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

------------------------------------- Player Controlls ------------------------------------------------------------
function handlePlayerMovement(delta)
  --Implements Jump for Player 1
  if love.keyboard.isDown("w") and player1.speed.y <= 0 and player1.location.y >= love.graphics.getHeight() - player1.size.y then
    player1.speed.y = 45
  end
  player1.location.y = player1.location.y - (player1.speed.y * delta * 10)
  if player1.location.y >= love.graphics.getHeight() - player1.size.y then
    player1.speed.y = 0
    player1.location.y = love.graphics.getHeight() - player1.size.y
  else
    player1.speed.y = player1.speed.y + (-75 * delta)
  end
  
  if player1.location.y > love.graphics.getHeight() - player1.size.y then
    player1.speed.y = player1.speed.y - (10 * delta)
  end
  
  if love.keyboard.isDown("a") then
    if love.keyboard.isDown("s") then
      slap1()
    end
    player1.speed.x = player1.speed.x - (player1.accel * delta)
    if player1.speed.x < player1.max_speed * -1 then
      player1.speed.x = -player1.max_speed
    end
  elseif love.keyboard.isDown("d") then
    if love.keyboard.isDown("s") then
      slap1()
    end
    player1.speed.x = player1.speed.x + (player1.accel * delta)
    if player1.speed.x > player1.max_speed then
      player1.speed.x = player1.max_speed
    end
  elseif love.keyboard.isDown("s") then
    slap1()
  else
    if player1.speed.x > 0 then player1.speed.x = player1.speed.x - (player1.accel * delta) end
    if player1.speed.x < 0 then player1.speed.x = player1.speed.x + (player1.accel * delta) end
  end
  
  player1.location.x = player1.location.x + (player1.speed.x * delta)
  if player1.location.x < 0 then 
    player1.location.x = 0 
  elseif player1.location.x + player1.size.x > love.graphics.getWidth() then
    player1.location.x = love.graphics.getWidth() - player1.size.x
  end
  
  --Implements Jump for Player 2
  if love.keyboard.isDown("up") and player2.speed.y <= 0 and player2.location.y >= love.graphics.getHeight() - player2.size.y then
    player2.speed.y = 45
  end
  
  player2.location.y = player2.location.y - (player2.speed.y * delta * 10)
  if player2.location.y >= love.graphics.getHeight() - player2.size.y then
    player2.speed.y = 0
    player2.location.y = love.graphics.getHeight() - player2.size.y
  else
    player2.speed.y = player2.speed.y + (-75 * delta)
  end
  
  if player2.location.y > love.graphics.getHeight() - player2.size.y then
    player2.speed.y = player2.speed.y - (10 * delta)
  end
  
  if love.keyboard.isDown("left") then
    if love.keyboard.isDown("down") then
      slap2()
    end
    player2.speed.x = player2.speed.x - (player2.accel * delta)
    if player2.speed.x < player2.max_speed * -1 then
      player2.speed.x = -player2.max_speed
    end
  elseif love.keyboard.isDown("right") then
    if love.keyboard.isDown("down") then
      slap2()
    end
    player2.speed.x = player2.speed.x + (player2.accel * delta)
    if player2.speed.x > player2.max_speed then
      player2.speed.x = player2.max_speed
    end
  elseif love.keyboard.isDown("down") then
    slap2()
  else
    if player2.speed.x > 0 then player2.speed.x = player2.speed.x - (player2.accel * delta) end
    if player2.speed.x < 0 then player2.speed.x = player2.speed.x + (player2.accel * delta) end
  end
  
  player2.location.x = player2.location.x + (player2.speed.x * delta)
  if player2.location.x < 0 then 
    player2.location.x = 0 
  elseif player2.location.x + player2.size.x > love.graphics.getWidth() then
    player2.location.x = love.graphics.getWidth() - player2.size.x
  end
end

------------------------------------- Player Bashing ------------------------------------------------------------
function handlePlayerCollision(delta)
  if CheckCollisionVec(player1.location, player1.size, player2.location, player2.size) then
    player1.location.x = player1.location.x - ((player1.speed.x-10) * delta)
    player2.location.x = player2.location.x - ((player2.speed.x+10) * delta)
    
    local temp = player1.speed
    player1.speed = player2.speed
    player2.speed = temp
  end
end

------------------------------------- Player Slapping ------------------------------------------------------------
local slap_range = 60
local slap_hit = 1199

function slap1(delta)
  if (player1.location + player1.size/2):dist(player2.location + player2.size/2) < slap_range then
    if player2.speed.x < 0 then
      player2.speed.x = -slap_hit
    else
      player2.speed.x = slap_hit
    end
  end
end

function slap2(delta)
  if (player2.location + player2.size/2):dist(player1.location + player1.size/2) < slap_range then
    if player1.speed.x < 0 then
      player1.speed.x = -slap_hit
    else
      player1.speed.x = slap_hit
    end
  end
end
------------------------------------- Fruits ------------------------------------------------------------
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
------------------------------------- Collision Function ------------------------------------------------------------
function CheckCollisionVec(loc1, size1, loc2, size2)
  return CheckCollision(loc1.x, loc1.y, size1.x, size1.y, loc2.x, loc2.y, size2.x, size2.y)
end

function CheckCollision(ax1,ay1,aw,ah,bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end
------------------------------------- End Game ------------------------------------------------------------
function endGame() 
  removeFruit()
  offerRestart()
end

function removeFruit()
  fruits = {}
end

function offerRestart()
  isEnd = true
end
------------------------------------- The End ------------------------------------------------------------