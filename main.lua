function love.load()
  sprites = {}
  sprites.player = love.graphics.newImage("sprites/player.png")
  sprites.bullet = love.graphics.newImage("sprites/bullet.png")
  sprites.zombie = love.graphics.newImage("sprites/zombie.png")
  sprites.background = love.graphics.newImage("sprites/background.png")

  player = require "player"
  zombies = {}
  bullets = {}

  fnt = love.graphics.newFont(40)
  gameState = 1
  wave = 1
  score = 0
  zombieSpeed = 50
end

function love.update(dt)
  if gameState == 2 then
    if love.keyboard.isDown("w") then
      player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") then
      player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown("a") then
      player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("d") then
      player.x = player.x + player.speed * dt
    end

    for i, z in ipairs(zombies) do
      z.x = z.x + math.cos(getPlayerZombieAngle(z)) * z.speed * dt
      z.y = z.y + math.sin(getPlayerZombieAngle(z)) * z.speed * dt

      if disctance(z.x, z.y, player.x, player.y) < 30 then
        for i, z in ipairs(zombies) do
          zombies[i] = nil
        end
      end
    end

    for i, b in ipairs(bullets) do
      b.x = b.x + math.cos(b.direction) * b.speed * dt
      b.y = b.y + math.sin(b.direction) * b.speed * dt
    end

    for i=#bullets, 1, -1 do
      local b = bullets[i]
      if b.x < 0
      or b.x > love.graphics.getWidth()
      or b.y < 0
      or b.y > love.graphics.getHeight() then
        table.remove(bullets, i)
      end
    end

    for i,z in ipairs(zombies) do
      for j,b in ipairs(bullets) do
        if disctance(z.x, z.y, b.x, b.y) < 20 then
          z.dead = true
          b.dead = true
          score = score + 1
        end
      end
    end

    for i=#zombies, 1, -1 do
      local z = zombies[i]
      if z.dead then
        table.remove(zombies, i)
      end
    end

    for i=#bullets, 1, -1 do
      local b = bullets[i]
      if b.dead then
        table.remove(bullets, i)
      end
    end
    -- No more zombies left. increase wave.
    if #zombies == 0 then
      wave = wave + 1
      gameState = 1
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)
  if gameState == 1 then
    love.graphics.setFont(fnt)
    love.graphics.print("are you ready? press r key", 100, 100)
  elseif gameState == 2 then
    love.graphics.draw(sprites.player, player.x, player.y, getPlayerMouseAngle(),
    nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

    for i, z in ipairs(zombies) do
      love.graphics.draw(sprites.zombie, z.x, z.y, getPlayerZombieAngle(z),
      nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    for i, b in ipairs(bullets) do
      love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.3, 0.3,
      sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end
  end
  love.graphics.setFont(fnt)
  love.graphics.print("zombies: " .. score .. " wave: " .. wave, 10, 10)
end

function getPlayerMouseAngle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function getPlayerZombieAngle(enemy)
  return math.atan2(enemy.y - player.y, enemy.x - player.x) + math.pi
end

function spawnZombie()
  zombie = {}

  local side = math.random(1, 4)

  if side == 1 then
    zombie.x = -30
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = -30
  elseif side == 3 then
    zombie.x = love.graphics.getWidth() + 30
    zombie.y = math.random(0, love.graphics.getHeight())
  else
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + 30
  end

  if wave % 3 == 0 then
    if wave < 9 then
      zombieSpeed = zombieSpeed * 1.05
    end
  end

  zombie.speed = zombieSpeed
  table.insert(zombies, zombie)
end

function spawnZombieWave(number)
  for i=1,number do
    spawnZombie()
  end
end

function spawnBullet()
  bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 500
  bullet.direction = getPlayerMouseAngle()
  bullet.dead = false

  table.insert(bullets, bullet)
end

function love.keypressed(key)
  if key == "r" then
    gameState = 2
    spawnZombieWave(wave)
  end
  if key == "space" then
    spawnBullet()
  end
end

function love.mousepressed(x, y, b, isTouch)
  if b == 1 then
    spawnBullet()
  end
end

function disctance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
