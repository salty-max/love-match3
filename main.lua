--[[
    MAIN PROGRAM
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

love.graphics.setDefaultFilter('nearest', 'nearest')

require 'src/Dependencies'

function love.load()

    -- window bar title
    love.window.setTitle('Match 3')

    -- seed the RNG
    math.randomseed(os.time())

    love.audio.setVolume(0.1)

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end,
    }

    gStateMachine:change('start')

    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- keep track of scrolling background on the X axis
    backgroundX = 0

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    -- scroll background, used across all states
    backgroundX = backgroundX - BACKGROUND_SCROLL_SPEED * dt
    
    -- if the entire image is scrolled, reset it to 0
    if backgroundX <= -1024 + BACKGROUND_LOOPING_POINT then
        backgroundX = 0
    end
    
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    Push:start()
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    gStateMachine:render()
    Push:finish()
end