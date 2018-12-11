-- tetrominoes.moon
-- A basic Tetris clone in Moonscript with Love2D
-- created: June 29, 2016
-- author: Adam Vandolder (adam.vandolder@gmail.com)

GS = require 'hump.gamestate'
Gameover = require 'gameover'
Pause = require 'pause'

-- SHAPES is a table of all of the possible shapes in all of their
-- possible rotations.
SHAPES = {
  {{{1}, -- L shape
    {1},
    {1, 1}},
   {{0, 0, 1},
    {1, 1, 1}},
   {{1, 1},
    {0, 1},
    {0, 1,}},
   {{1, 1, 1},
    {1}}},
  {{{0, 1}, -- J shape
    {0, 1},
    {1, 1}},
   {{1, 1, 1},
    {0, 0, 1}},
   {{1, 1},
    {1},
    {1}},
   {{1},
    {1, 1, 1}}},
  {{{1, 1, 1}, -- T shape
    {0, 1}},
   {{1},
    {1, 1},
    {1}},
   {{0, 1},
    {1, 1, 1}},
   {{0, 1},
    {1, 1},
    {0, 1}}},
  {{{1}, -- I shape
    {1},
    {1},
    {1}},
   {{1, 1, 1, 1}}},
  {{{1, 1}, -- Z shape
    {0, 1, 1}},
   {{0, 1},
    {1, 1},
    {1}}},
  {{{0, 1, 1}, -- S shape
    {1, 1}},
   {{1},
    {1, 1},
    {0, 1}}},
  {{{1, 1}, -- O shape
    {1, 1}}},
}

-- COLORS is a table of all of the colors that correspond to each shape.
COLORS = {
  {1, 0.5, 0}, -- Orange (L)
  {0, 0, 1}, -- Blue (J)
  {1, 0, 1}, -- Purple (T)
  {0, 1, 1}, -- Aqua (I)
  {1, 0, 0}, -- Red (Z)
  {0, 1, 0}, -- Green (S)
  {1, 1, 0}, -- Yellow (O)
}

BLOCK_SIZE = 16
CELL_EMPTY = 0
CELL_FULL = 1


class Shape
  new: (@type, @orient, @row, @col, @color, @boardw, @boardh) =>

  draw: (boardx, boardy, drow=@row, dcol=@col) =>
    prevcolor = { love.graphics.getColor! }
    love.graphics.setColor @color

    for row = 0,#SHAPES[@type][@orient]-1
      for col = 0,#SHAPES[@type][@orient][row+1]-1
        if @has_block(row+1, col+1)
          love.graphics.rectangle 'fill',
            boardx+1 + (dcol+col-1)*BLOCK_SIZE,
            boardy+1 + (drow+row-1)*BLOCK_SIZE,
            BLOCK_SIZE-2, BLOCK_SIZE-2

    love.graphics.setColor prevcolor

  has_block: (row, col) =>
    SHAPES[@type][@orient][row][col] == 1

  get_blocks: =>
    SHAPES[@type][@orient]

  rotate: (direction = 1) =>
    @orient = (@orient + direction - 1) % #SHAPES[@type] + 1

  movehorz: (amount) =>
    @col += amount

  movevert: (amount) =>
    @row += amount


class Board
  new: (@width, @height, @x, @y) =>
    @data = {}
    for row = 1,@height
      @data[row] = {}
      for col = 1,@width
        @data[row][col] = {CELL_EMPTY}

    -- Generate a new shape.
    @shape = @generate_shape!
    @next_shape = @generate_shape!

    @move_wait = 0.75
    @move_timer = 0

    @key_wait = 0.2
    @key_timer = @key_wait

    @score = 0

  update: (dt) =>
    @move_timer += dt
    if @move_timer >= @move_wait
      @move_timer = 0
      @shape\movevert 1
      if @collision(@shape)
        if @shape.row <= 1
          -- If the shape is above the board and colliding, then game over.
          GS.switch Gameover
          return

        @shape\movevert -1
        @set_shape(@shape)
        @shape = @next_shape
        @next_shape = @generate_shape!

    if not love.keyboard.isDown('down')
      @move_wait = 1

    @key_timer += dt
    if @key_timer >= @key_wait
      if love.keyboard.isDown('up')
        @rotate!
        @key_timer = 0
      if love.keyboard.isDown('down')
        @move_wait = 0.05
        @key_timer = 0
      if love.keyboard.isDown('left')
        @move_shape(-1)
        @key_timer = 0
      if love.keyboard.isDown('right')
        @move_shape(1)
        @key_timer = 0

  draw: =>
    -- Draw the box around the game board.
    love.graphics.rectangle(
      'line', @x, @y, @width*BLOCK_SIZE, @height*BLOCK_SIZE)
    -- Draw the current shape.
    @shape\draw @x, @y
    -- Draw all of the full cells.
    prevcolor = { love.graphics.getColor! }
    for row = 1,@height
      if debug
        love.graphics.setColor(255, 255, 255)
        love.graphics.print row, @x+1 - BLOCK_SIZE, @y+1 + (row-1)*BLOCK_SIZE

      for col = 1,@width
        if @data[row][col][1] == CELL_FULL
          love.graphics.setColor @data[row][col][2]
          love.graphics.rectangle 'fill',
            @x+1 + (col-1)*BLOCK_SIZE,
            @y+1 + (row-1)*BLOCK_SIZE,
            BLOCK_SIZE-2, BLOCK_SIZE-2

        if debug
          love.graphics.setColor(255, 255, 255)
          love.graphics.print col,
            @x+1 + (col-1)*BLOCK_SIZE,
            @y+1 + (row-1)*BLOCK_SIZE
    love.graphics.setColor prevcolor

  generate_shape: =>
    shape_type = love.math.random(1, #SHAPES)
    color = COLORS[shape_type]
    col = math.floor((@width - #SHAPES[shape_type][1][1]) / 2) + 1
    row = 1 - #SHAPES[shape_type][1]
    Shape(shape_type, 1, row, col, color, @width, @height)

  rotate: =>
    @shape\rotate!

    can_rotate = false
    i = 0
    for i = 0,3
      if not @collision(@shape)
        can_rotate = true
        break

      @shape\movehorz -1

    if not can_rotate
      @shape\rotate(-1)
      @shape\movehorz i

  move_shape: (direction) =>
    @shape\movehorz(direction)
    if @collision(@shape)
      @shape\movehorz(-direction)

  collision: (shape) =>
    s = shape\get_blocks!
    for row = 0,#s-1
      for col = 0,#s[row+1]-1
        if shape\has_block(row+1, col+1)
          -- If the block if left/right of the board, there is a collision.
          if shape.col+col < 1 or shape.col+col > @width then return true
          if shape.row+row < 1 then continue
          if shape.row+row > @height or
              @data[shape.row + row][shape.col + col][1] == CELL_FULL
            return true
    false

  set_shape: (shape) =>
    s = shape\get_blocks!
    for row = 0,#s-1
      for col = 0,#s[row+1]-1
        if shape\has_block(row+1, col+1)
          @data[shape.row + row][shape.col + col][1] = CELL_FULL
          @data[shape.row + row][shape.col + col][2] = shape.color
    @check_rows!

  check_rows: =>
    lines_cleared = 0

    for row = 1,@height
      row_full = true
      for col = 1,@width
        if @data[row][col][1] == CELL_EMPTY
          row_full = false

      if row_full
        @clear_row row
        lines_cleared += 1

    @score += lines_cleared * lines_cleared

  clear_row: (row) =>
    if row == 1
      for col = 1,@width
        @data[1][col] = {CELL_EMPTY}

    for row = row,2,-1
      @data[row] = @data[row-1]
      @data[row-1] = {}
      for col = 1,@width
        @data[row-1][col] = {CELL_EMPTY}


class Tetrominoes
  init: =>
    @font = love.graphics.newFont(10)

  enter: (prev) =>
    @board = Board(10, 20, 128, 128)

  update: (dt) =>
    if love.keyboard.isDown('escape')
      GS.push Pause
    @board\update dt

  draw: =>
    love.graphics.setFont(@font)
    @board\draw!
    love.graphics.print "Up next:", 10, 10
    @board.next_shape\draw 10, 30, 1, 1
    love.graphics.print "Lines cleared: " .. @board.score, 128, 10
