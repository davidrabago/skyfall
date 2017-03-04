local vector = require("lib.hump.vector")

local player = {
  location = vector(250, 250),
  max_speed = 300,
  
  img = nil,
}
  
function love.load()
  player.img = love.graphics.newImage("assets/player.jpg")
end

function love.update(delta)
  movePlayer(delta)
end

function love.draw()
  love.graphics.draw(player.img, player.location.x, player.location.y)
  love.graphics.print("Hello, world!", 240, 240)
end

function movePlayer(delta)  
  local direction = vector(love.mouse.getX() - player.location.x, love.mouse.getY() - player.location.y)
  local distance = direction:len()
  local unit = direction:normalized()
  
  local speed = math.min(distance * 2, player.max_speed)
  local movement = unit * (speed * delta)
  
  player.location = player.location + movement
end
