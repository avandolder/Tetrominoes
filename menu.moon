class Menu
  new: (@options={}, @x=0, @y=0) =>
    @curr_option = 1
    @key_wait = 0.2
    @key_dt = @key_wait

  update: (dt) =>
    @key_dt += dt
    if @key_dt >= @key_wait
      if love.keyboard.isDown('down')
        if @curr_option >= #@options
          @curr_option = 1
        else
          @curr_option += 1
        @key_dt = 0
      elseif love.keyboard.isDown('up')
        if @curr_option <= 1
          @curr_option = #@options
        else
          @curr_option -= 1
        @key_dt = 0

      if love.keyboard.isDown('return')
        @options[@curr_option].action!

  draw: (x=@x, y=@y) =>
    for i = 1,#@options
      if i == @curr_option
        love.graphics.print '>', x - 12, y + 20*(i-1)

      love.graphics.print @options[i].tag, x, y + 20*(i-1)
