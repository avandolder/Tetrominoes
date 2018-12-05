GS = require 'hump.gamestate'
Tetrominoes = require 'Tetrominoes'
Menu = require 'menu'

class Intro
  init: =>
    @menu = Menu({
      {tag: "Play", action: -> GS.push Tetrominoes}
      {tag: "Quit", action: -> love.event.quit!}
    })
    @font = love.graphics.newFont(16)

  resume: =>
    @menu.curr_option = 1
    @menu.key_dt = 0

  update: (dt) =>
    @menu\update dt

  draw: =>
    love.graphics.setFont(@font)
    love.graphics.setColor 255, 255, 255, 255
    love.graphics.print 'Tetrominoes' .. (debug and ' (DEBUG)' or ''), 10, 10
    @menu\draw 10, 30
