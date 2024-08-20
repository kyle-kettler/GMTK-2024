local middleclass = require("lib/middleclass")

local Constants = require("constants")
local WinState = middleclass("WinState")

local joystick
local usingGamepad
local background

function WinState:initialize(input)
  self.input = input
  self.sounds = {}

  self.score = 0
  self.displayedScore = 0
  self.targetScore = 0
  self.scoreIncreaseSpeed = 30
  self.gem = {}
  self.gem.img = love.graphics.newImage("assets/sprites/gem.png")
  self.gem.width = self.gem.img:getWidth()
  self.gem.height = self.gem.img:getHeight()
  self.gem.scale = 2
  self.gem.x = Constants.GAME_WIDTH / 2 + 5
  self.gem.y = Constants.GAME_HEIGHT / 2 - 32
end

function WinState:enter(params)
  joystick = love.joystick.getJoysticks()[1]
  if joystick then
    usingGamepad = joystick:isGamepad()
  end
  self.displayedScore = params.coins

  background = love.graphics.newImage("assets/sprites/win-bg.jpg")
end

function WinState:update(dt)
  if self.input:pressed("gameExit") then
    love.event.quit()
  end
  if self.input:pressed("gameStart") then
    gameManager:change("main_menu")
  end
end

function WinState:render()
  for i = 0, love.graphics.getWidth() / background:getWidth() do
    for j = 0, love.graphics.getHeight() / background:getHeight() do
      love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
    end
  end
  love.graphics.setFont(Fonts["large"])
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.printf("YOU WIN", 2, 50 + 2, Constants.GAME_WIDTH -1 + 2, "center")
  love.graphics.setColor(55/255, 148/255, 110/255, 1)
  love.graphics.printf("YOU WIN", 2, 50, Constants.GAME_WIDTH -1, "center")
  self:displayScore()
  love.graphics.setFont(Fonts["text"])
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Thank you for playing!", 0, Constants.GAME_HEIGHT / 2 - 80, Constants.GAME_WIDTH, "center")
  love.graphics.printf("You got:", 0, Constants.GAME_HEIGHT / 2 - 64, Constants.GAME_WIDTH, "center")
  love.graphics.printf("Press A or Enter to start over", 0, Constants.GAME_HEIGHT - 50, Constants.GAME_WIDTH, "center")
end

function WinState:exit()
  -- Add any cleanup logic when exiting this state
end


function WinState:displayScore()
  -- Calculate new x position for the score
  local scoreX = self.gem.x  -- Adjust this value to fine-tune the position

  -- Draw the gem
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.draw(self.gem.img, self.gem.x + 2, self.gem.y + 3, 0, self.gem.scale, self.gem.scale)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.gem.img, self.gem.x, self.gem.y + 1, 0, self.gem.scale, self.gem.scale)

  -- Draw the score
  love.graphics.setFont(Fonts["large"])
  local scoreText = tostring(math.floor(self.displayedScore))
  local textWidth = Fonts["large"]:getWidth(scoreText)

  -- Align the score to the right of the calculated x position
  local textX = scoreX - textWidth

  -- Draw the score with shadow
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.print(scoreText, textX + 2, self.gem.y + 16 + 2)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(scoreText, textX, self.gem.y + 16)

  love.graphics.setColor(1, 1, 1, 1)
end

return WinState
