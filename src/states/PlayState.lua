--[[
    PLAY STATE CLASS
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    self.rectHighlighted = false

    self.highlightedTile = nil

    self.timer = 60
    self.canInput = true
    self.waitForReset = false

    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    self.countdownTimer = Timer.every(1, function()
        self.timer = self.timer - 1

        if self.timer <= 10 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    self.level = params.level
    self.board = params.board or Board(self.level, VIRTUAL_WIDTH / 2 - 32, 16)
    self.score = params.score or 0
    self.music = params.music

    -- score to reach to get to the next level
    self.scoreGoal = self.level * 2 * 1000
end

function PlayState:update(dt)

    if self.canInput then
        -- cursor movement
        if love.keyboard.wasPressed('up') then
            self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') then
            self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') then
            self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') then
            self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
            gSounds['select']:play()
        end

        if love.mouse.wasClicked(1) then
            local mousePos = self:getMouseGridPos()
            if mousePos then
                self.boardHighlightX = mousePos['x']
                self.boardHighlightY = mousePos['y']
            end
        end

        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.mouse.wasClicked(1) then
            -- shift highlight position to match table index
            local x = self.boardHighlightX + 1
            local y = self.boardHighlightY + 1

            -- select tile
            if not self.highlightedTile then
                self.highlightedTile = self.board.tiles[y][x]
            -- if on the same tile, deselect
            elseif self.highlightedTile == self.board.tiles[y][x] then
                self.highlightedTile = nil
            -- if tiles are not adjacent, cancel move
            elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
                gSounds['error']:play()
                self.highlightedTile = nil
            -- swap the selected tile and the tile at the cursor position
            else
                local newTile = self.board.tiles[y][x]

                self.board:swapTiles(self.highlightedTile, newTile, true, function()
                    if not self.board:calculateMatches() then
                        gSounds['error']:play()
                        self.board:swapTiles(newTile, self.board.tiles[y][x], true)
                        self.highlightedTile = nil
                    else
                        self:calculateMatches()
                    end
                end)
            end
        end
    end

    if self.timer <= 0 then
        gSounds['game-over']:play()
        gStateMachine:change('game-over', {
            score = self.score
        })
    end

    Timer.update(dt)
end

function PlayState:calculateMatches()
    
    -- compute matches
    local matches = self.board:calculateMatches()
    
    if matches then
        -- reset selection
        self.highlightedTile = nil
        gSounds['match']:stop()
        gSounds['match']:play()

        -- add score for each match with varying bonus for each variety
        for k, match in pairs(matches) do
            for l, tile in pairs(match) do
                self.score = self.score + tile.score
            end
        end

        -- add time for each match
        for k, match in pairs(matches) do
            self.timer = self.timer + #match
        end

        -- remove matched tiles
        self.board:removeMatches()

        -- get replacement tiles
        local tilesToCollapse = self.board:getFallingTiles()

        -- animate the fall of tiles
        Timer.tween(0.25, tilesToCollapse):finish(function()
            self:calculateMatches()
        end)

    else
        if self.score >= self.scoreGoal then
            gSounds['next-level']:play()
            Timer.after(1, function()
                gStateMachine:change('begin-game', {
                    level = self.level + 1,
                    score = 0,
                    music = self.music
                })
            end)
        else
             if not self.board:checkPossibleMatches() then
                self.waitForReset = true
                Timer.after(2, function()
                    self.board:initializeBoard()
                    self.waitForReset = false
                end)
            end
            self.canInput = true
        end
    end
end

function PlayState:getMouseGridPos()
    local mouseX, mouseY = Push:toGame(love.mouse.getPosition())
    mouseX = mouseX - self.board.x
    mouseY = mouseY - self.board.y
    mouseX = math.floor(mouseX / 32)
    mouseY = math.floor(mouseY / 32)
    if mouseX >= 0 and mouseY >= 0 and mouseX <= 7 and mouseY <= 7 then
        return {
            ['x'] = mouseX,
            ['y'] = mouseY
        }
    end
end

function PlayState:render()
    self.board:render()

    -- Highlight alpha rectangle
    if self.highlightedTile then
        love.graphics.setBlendMode('add')
        love.graphics.setColor(1, 1, 1, 96/255)
        love.graphics.rectangle('fill', self.highlightedTile.x + BOARD_OFFSET_X, self.highlightedTile.y + BOARD_OFFSET_Y, 32, 32, 4)
        love.graphics.setBlendMode('alpha')
    end

    -- Selection rectangle
    love.graphics.setLineWidth(4)
    if self.rectHighlighted then
        love.graphics.setColor(217/255, 87/255, 99/255, 1)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 1)
    end
    love.graphics.rectangle('line', self.boardHighlightX * 32 + BOARD_OFFSET_X, self.boardHighlightY * 32 + BOARD_OFFSET_Y, 32, 32, 4)

    -- GUI
    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 24, 24, 178, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 24, 48, 178, 'center')
    love.graphics.printf('Goal: ' .. tostring(self.scoreGoal), 24, 72, 178, 'center')
    love.graphics.printf('Time left: ' .. tostring(self.timer), 24, 96, 178, 'center')

    if self.waitForReset then
        love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
        love.graphics.rectangle('fill', BOARD_OFFSET_X + 32, VIRTUAL_HEIGHT / 2 - 32, 192, 48, 4)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf('No possible match!', BOARD_OFFSET_X + 40, VIRTUAL_HEIGHT / 2 - 16, 176, 'center')
    end

    love.graphics.print(self.boardHighlightX, 5, 5)
    love.graphics.print(self.boardHighlightY, 5, 20)
end

-- remove timer to avoid wierd behavior with alarm sound
function PlayState:exit()
    self.countdownTimer:remove()
end