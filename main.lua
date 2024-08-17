love.graphics.setDefaultFilter("nearest", "nearest")
local Constants = require("constants")
Player = require("player")
Coin = require("coin")
Camera = require("lib/camera")
Spike = require("spikes")
Wall = require("wall")
BFL = require("bfl")

local push = require("lib/push")
local sti = require("lib/sti")
local baton = require("lib/baton")
local windowWidth, windowHeight = love.window.getDesktopDimensions()
local camera
local input = baton.new({
  controls = {
    left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
    right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
    up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
    down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
    action = { "key:x", "button:x" },
    jump = { "key:space", "button:a" },
  },
  pairs = {
    move = { "left", "right", "up", "down" },
  },
  joystick = love.joystick.getJoysticks()[1],
})

local initialPhysicsDelay = 0.1
local currentPhysicsDelay = initialPhysicsDelay

function love.load()
  push:setupScreen(Constants.GAME_WIDTH, Constants.GAME_HEIGHT, windowWidth, windowHeight, {
    vsync = true,
    fullscreen = false,
    resizable = true,
  })
  Map = sti("assets/maps/scene1.lua", { "box2d" })

  -- Initialize map constants
  Constants.initializeMapConstants(Map)

  World = love.physics.newWorld(0, 0)
  World:setCallbacks(beginContact, endContact)
  Map:box2d_init(World)
  Map.layers.ground.visible = false
  Map.layers.walls.visible = false
  for _, object in ipairs(Map.layers.walls.objects) do
    Wall.new(object.x, object.y, object.width, object.height)
  end

  local cameraStartX = Constants.GAME_WIDTH / 2
  local cameraStartY = Constants.MAP_BOTTOM - Constants.GAME_HEIGHT / 2
  camera = Camera(cameraStartX, cameraStartY, Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
  camera.scale = 1

  Player:load()
  BFL:load()
  Coin.new(200, 300)
  Coin.new(400, 300)
  Coin.new(500, 300)
  Coin.new(550, 300)

  -- You can now use Constants.MAP_PIXEL_HEIGHT here or in other functions
  print("Map bottom:", Constants.MAP_PIXEL_HEIGHT)
end

function love.update(dt)
  if currentPhysicsDelay > 0 then
    currentPhysicsDelay = currentPhysicsDelay - dt
    return -- Skip the rest of the update for the delay period
  end
  input:update()
  World:update(dt)
  Map:update(dt)
  Player:update(dt)
  Coin.updateAll(dt)
  Spike.updateAll(dt)
  Wall.updateAll(dt)
  BFL:update(dt)

  local moveX, moveY = input:get("move")
  Player:move(dt, moveX, moveY)

  if input:pressed("jump") then
    Player:jump()
  end

  if input:pressed("action") then
    Player:dash()
  end

  -- Update camera to follow player
  camera:update(dt)
  camera:follow(Player.x, Player.y)
  camera:setFollowStyle("PLATFORMER")

  -- Set camera bounds to map size
  local mapWidth = Map.width * Map.tilewidth
  local mapHeight = Map.height * Map.tileheight
  camera:setBounds(0, 0, mapWidth, mapHeight)
end

function beginContact(a, b, collision)
  if Coin.beginContact(a, b, collision) then
    return
  end
  if Spike.beginContact(a, b, collision) then
    return
  end
  if Wall.beginContact(a, b, collision) then
    return
  end
  Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
  Wall.endContact(a, b, collision)
  Player:endContact(a, b, collision)
end

function love.draw()
  push:start()

  camera:attach()

  love.graphics.setColor(1, 1, 1)
  Map:draw(-camera.x, -camera.y, camera.scale, camera.scale)

  love.graphics.setColor(1, 1, 1)
  Map:draw(
    -camera.x + Constants.GAME_WIDTH / (2 * camera.scale),
    -camera.y + Constants.GAME_HEIGHT / (2 * camera.scale),
    camera.scale,
    camera.scale
  )

  Player:draw()
  Coin.drawAll()
  Spike.drawAll()
  BFL:draw()

  camera:detach()

  camera:draw()
  love.graphics.print(tostring(Player.coins), 10, 10)

  push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end
