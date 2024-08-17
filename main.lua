love.graphics.setDefaultFilter("nearest", "nearest")
local Constants = require("constants")
local Player = require("player")
local Coin = require("coin")
local Camera = require("lib/camera")
local Spike = require("spikes")
local Wall = require("wall")
local BFL = require("bfl")
local GUI = require("gui")

local player
local gui
local bfl
local walls = {}

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
    launch = { "key:j", "button:rightshoulder" },
  },
  pairs = {
    move = { "left", "right", "up", "down" },
  },
  joystick = love.joystick.getJoysticks()[1],
})

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
    table.insert(walls, Wall:new(object.x, object.y, object.width, object.height))
  end

  for _, object in ipairs(Map.layers.spikes.objects) do
    Spike:new(object.x, object.y, World)
  end

  local mapWidth = Map.width * Map.tilewidth
  local cameraStartX = mapWidth / 2
  local cameraStartY = Constants.MAP_BOTTOM - Constants.GAME_HEIGHT / 2

  camera = Camera(cameraStartX, cameraStartY, Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
  camera.scale = 1

  player = Player:new(World)
  gui = GUI:new(player)
  bfl = BFL:new(World)
  gui:load()
  Coin:new(200, 300, World)
  Coin:new(400, 300, World)
  Coin:new(500, 300, World)
  Coin:new(550, 300, World)
end

function love.update(dt)
  input:update()
  World:update(dt)
  Map:update(dt)
  player:update(dt)
  Coin.updateAll(dt)
  Spike.updateAll(dt)
  -- bfl:update(dt)
  gui:update(dt)

  for _, wall in ipairs(walls) do
    wall:update(dt)
  end

  local moveX, moveY = input:get("move")
  player:move(dt, moveX, moveY)

  if input:pressed("jump") then
    player:jump()
  end

  if input:pressed("action") then
    player:dash()
  end

  if input:pressed("launch") then
    player:launch(camera)
  end

  -- Update camera to follow player
  camera:update(dt)
  camera:follow(player.x, player.y)
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
    return Spike.beginContact(a, b, collision)
  end
  if Wall.beginContact(a, b, collision) then
    return
  end
  if bfl.beginContact(a, b, collision) then
    return
  end
  player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
  Wall.endContact(a, b, collision)
  player:endContact(a, b, collision)
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

  for _, wall in ipairs(walls) do
    wall:draw()
  end
  player:draw()
  Coin.drawAll()
  Spike.drawAll()
  bfl:draw()

  camera:detach()

  camera:draw()
  love.graphics.print(tostring(player.coins), 10, 10)
  gui:draw()

  push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end
