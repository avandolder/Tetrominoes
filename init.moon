GS = require 'hump.gamestate'
Intro = require 'intro'

love.load = (arg) ->
  GS.registerEvents!
  GS.switch Intro
