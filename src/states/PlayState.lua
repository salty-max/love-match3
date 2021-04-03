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

    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    Timer.every(1, function()
        self.timer = self.timer - 1
    end)
end

function PlayState:enter(params)
    self.level = params.level
    self.board = params.board or Board(VIRTUAL_WIDTH / 2 - 32, 16)
    self.score = params.score or 0
end

function PlayState:update(dt)

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
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
            local tmpX = self.highlightedTile.gridX
            local tmpY = self.highlightedTile.gridY

            local newTile = self.board.tiles[y][x]

            self.highlightedTile.gridX = newTile.gridX
            self.highlightedTile.gridY = newTile.gridY
            newTile.gridX = tmpX
            newTile.gridY = tmpY

            self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile
            self.board.tiles[newTile.gridY][newTile.gridX] = newTile

            -- animate swap
            Timer.tween(0.3, {
                [self.highlightedTile] = { x = newTile.x, y = newTile.y },
                [newTile] = { x = self.highlightedTile.x, y = self.highlightedTile.y },
            }):finish(function()
                -- reset selection
                self.highlightedTile = nil
            end)
        end
    end

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

    Timer.update(dt)
end

function PlayState:render()
    self.board:render()

    -- Highlight alpha rectangle
    if self.highlightedTile then
        love.graphics.setBlendMode('add')
        love.graphics.setColor(1, 1, 1, 96/255)
        love.graphics.rectangle('fill', self.highlightedTile.x + (VIRTUAL_WIDTH - 288), self.highlightedTile.y + 16, 32, 32, 4)
        love.graphics.setBlendMode('alpha')
    end

    -- Selection rectangle
    love.graphics.setLineWidth(4)
    if self.rectHighlighted then
        love.graphics.setColor(217/255, 87/255, 99/255, 1)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 1)
    end
    love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 288), self.boardHighlightY * 32 + 16, 32, 32, 4)

    -- GUI
    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 24, 24, 178, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 24, 48, 178, 'center')
    love.graphics.printf('Time left: ' .. tostring(self.timer), 24, 72, 178, 'center')

end