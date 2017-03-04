local vector = require("lib.hump.vector")

local player1 = {
  location = vector(250, 250),
  max_speed = 400,
  decel = 5,
  
  img = nil,
}
  
function love.load()
  player1.img = love.graphics.newImage("assets/player1.png")
end

function love.update(delta)
  
end

function love.draw()
  love.graphics.draw(player1.img, player1.location.x, player1.location.y)
end

function moveToPointer(delta)  
  local direction = vector(love.mouse.getX() - player1.location.x, love.mouse.getY() - player1.location.y)
  local distance = direction:len()
  local unit = direction:normalized()
  
  local speed = math.min(distance * player1.decel, player1.max_speed)
  local movement = unit * (speed * delta)
  
  player1.location = player1.location + movement
end
