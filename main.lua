love.graphics.setDefaultFilter("nearest", "nearest")
require("dependencies")
local Constants = require("constants")
local GameManager = require("gamemanager")
local push = require("lib/push")
local baton = require("lib/baton")

local windowWidth, windowHeight = love.window.getDesktopDimensions()

-- Input configuration
local input = baton.new({
  controls = {
    left = { "key:left", "key:a", "axis:leftx-", "button:dpleft" },
    right = { "key:right", "key:d", "axis:leftx+", "button:dpright" },
    up = { "key:up", "key:w", "axis:lefty-", "button:dpup" },
    down = { "key:down", "key:s", "axis:lefty+", "button:dpdown" },
    action = { "key:x", "button:x" },
    jump = { "key:space", "button:a" },
    launch = { "key:c", "button:rightshoulder" },
    gameStart = { "key:return", "button:a" },
    gameExit = { "key:escape", "button:back" },
    select = { "key:return", "button:a" },
  },
  pairs = {
    move = { "left", "right", "up", "down" },
  },
  joystick = love.joystick.getJoysticks()[1],
})

-- Game states
local states = {
  main_menu = function()
    return require("states/mainmenustate"):new(input)
  end,
  game = function()
    return require("states/gamestate"):new(input)
  end,
  death = function()
    return require("states/deathstate"):new(input)
  end,
}

function love.load()
  push:setupScreen(Constants.GAME_WIDTH, Constants.GAME_HEIGHT, windowWidth, windowHeight, {
    vsync = true,
    fullscreen = false,
    resizable = true,
  })

  gameManager = GameManager:new(states)
  gameManager:change("main_menu")
end

function love.update(dt)
  input:update()
  gameManager:update(dt)
end

function love.draw()
  push:start()
  love.graphics.clear(0.4, 0.7, 1, 1) -- Light blue
  gameManager:render()
  push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)
  if gameManager.current.keypressed then
    gameManager.current:keypressed(key)
  end
end

function love.mousepressed(x, y, button)
  if gameManager.current.mousepressed then
    gameManager.current:mousepressed(x, y, button)
  end
end
