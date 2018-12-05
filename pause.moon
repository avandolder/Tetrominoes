GS = require 'hump.gamestate'
Menu = require 'menu'

class Pause
  init: =>
    @menu = Menu({
      {tag: "Resume", action: -> GS.pop!}
      {tag: "Quit", action: -> love.event.quit!}
    })
    @font = love.graphics.newFont(16)

  enter: (@prev) =>
    @menu.curr_option = 1
    @menu.key_dt = 0

  update: (dt) =>
    @menu\update dt

  draw: =>
    @prev\draw!

    -- Draw a transparent rectangle over the game board.
    love.graphics.setColor(0, 0, 0, 255/2)
    love.graphics.rectangle("fill", 0, 0, 640, 480)

    love.graphics.setFont(@font)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('Paused' .. (debug and ' (DEBUG)' or ''), 300, 200)
    @menu\draw 300, 220
