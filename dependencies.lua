Fonts = {
  ["xsmall"] = love.graphics.newFont("assets/fonts/font-small.ttf", 8, "mono"),
  ["small"] = love.graphics.newFont("assets/fonts/font-small.ttf", 10, "mono"),
  ["medium"] = love.graphics.newFont("assets/fonts/font-small.ttf", 16, "mono"),
  ["large"] = love.graphics.newFont("assets/fonts/font-small.ttf", 32, "mono"),
  ["text"] = love.graphics.newFont("assets/fonts/font-text.ttf", 14, "mono"),
}

Sounds = {
    ['music'] = love.audio.newSource('assets/audio/music.mp3', 'static'),
    ['launch'] = love.audio.newSource('assets/audio/launch.ogg', 'static'),
    ['damage'] = love.audio.newSource('assets/audio/hit.ogg', 'static'),
    ['gem'] = love.audio.newSource('assets/audio/coin.ogg', 'static'),
    ['fuel'] = love.audio.newSource('assets/audio/fuel.ogg', 'static'),
    ['health'] = love.audio.newSource('assets/audio/health.ogg', 'static'),
    ['jump'] = love.audio.newSource('assets/audio/jump.ogg', 'static'),
}
