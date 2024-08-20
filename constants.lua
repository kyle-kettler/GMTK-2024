local Constants = {}

-- Game dimensions
Constants.GAME_WIDTH = 500
Constants.GAME_HEIGHT = 375

-- Initialize map-related constants
Constants.MAP_WIDTH = 0
Constants.MAP_HEIGHT = 0
Constants.TILE_WIDTH = 0
Constants.TILE_HEIGHT = 0
Constants.MAP_PIXEL_WIDTH = 0
Constants.MAP_PIXEL_HEIGHT = 0
Constants.MAP_BOTTOM = 0  -- New constant for map bottom

-- Function to initialize map-related constants
function Constants.initializeMapConstants(map)
    Constants.MAP_WIDTH = map.width
    Constants.MAP_HEIGHT = map.height
    Constants.TILE_WIDTH = map.tilewidth
    Constants.TILE_HEIGHT = map.tileheight
    Constants.MAP_PIXEL_WIDTH = Constants.MAP_WIDTH * Constants.TILE_WIDTH
    Constants.MAP_PIXEL_HEIGHT = Constants.MAP_HEIGHT * Constants.TILE_HEIGHT
    Constants.MAP_BOTTOM = Constants.MAP_PIXEL_HEIGHT  -- Set MAP_BOTTOM
end

return Constants
