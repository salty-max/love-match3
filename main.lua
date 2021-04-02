--[[
    MAIN PROGRAM
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

require 'src/Dependencies'

function love.load()
  currentSecond = 0
  secondTimer = 0

  love.graphics.setDefaultFilter('nearest', 'nearest')

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    vsync = true,
    resizable = true
  })

  love.keyboard.keysPressed = {}
end

function love.resize(x, y)
  push:resize(x, y)
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

function love.update(dt)
  
end

function love.draw()
  push:start()

  push: finish()
end