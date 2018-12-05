GS = require 'hump.gamestate'
Intro = require 'intro'

export debug = false

love.load = (arg) ->
  for i = 0,#arg
    if arg[i] == '--debug'
      debug = true

  GS.registerEvents!
  GS.switch Intro
