GS = require 'hump.gamestate'
Menu = require 'menu'

class Gameover
  init: =>
    @menu = Menu({
      {tag: "Return to Main Menu", action: -> GS.pop!}
      {tag: "Quit", action: -> love.event.quit!}
    })
    @font = love.graphics.newFont(16)

  enter: (prev) =>
    @menu.curr_option = 1
    @menu.key_dt = 0

  update: (dt) =>
    @menu\update dt

  draw: =>
    love.graphics.setFont(@font)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('Game over!', 10, 10)
    @menu\draw 10, 30
