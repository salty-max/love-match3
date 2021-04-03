--[[
    DEPENDENCIES
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- libs
Push = require 'lib/push'
Class = require 'lib/class'
Timer = require 'lib/knife.timer'

-- constants
require 'src/constants'

-- utils
require 'src/Util'

-- state machine
require 'src/StateMachine'

-- entities
require 'src/Board'
require 'src/Tile'

-- states
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/BeginGameState'
require 'src/states/PlayState'

gSounds = {
    ['music'] = love.audio.newSource('sounds/music3.mp3', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['error'] = love.audio.newSource('sounds/error.wav', 'static'),
    ['match'] = love.audio.newSource('sounds/match.wav', 'static'),
    ['clock'] = love.audio.newSource('sounds/clock.wav', 'static'),
    ['game-over'] = love.audio.newSource('sounds/game-over.wav', 'static'),
    ['next-level'] = love.audio.newSource('sounds/next-level.wav', 'static')
}

gTextures = {
    ['tiles'] = love.graphics.newImage('graphics/match3.png'),
    ['background'] = love.graphics.newImage('graphics/background.png')
}

gFrames = {
    
    ['tiles'] = GenerateTileQuads(gTextures['tiles'])
}

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}
