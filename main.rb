$font = Font.new(18)

#---
class Panel
  OFFSET = 2

  attr_accessor :number

  def initialize(x, y)
    @x = x
    @y = y
    @is_mine = false
  end

  def set_mine
    @is_mine = true
  end

  def mine?
    @is_mine
  end

  def update
  end

  def draw
    x = @x+OFFSET
    y = @y+OFFSET
    width = 30-OFFSET*2
    height = 30-OFFSET*2
    round = 4

    if @is_mine
      RoundRect.new(x, y, width, height, round).draw([255, 0, 255])
    else
      RoundRect.new(x, y, width, height, round).draw([240, 240, 240])
      if @number > 0
        $font[@number.to_s].draw_at(@x+15, @y+15, [0, 0, 0])
      end
    end
  end

  def open
  end

  def set_flag
  end

  def flag?
  end
end

class Ground
  def initialize(width, height, x_offset = 0, y_offset = 0)
    @width = width
    @height = height
    @panels = []
    @table = Array.new(width) { Array.new(height) }

    # init
    0.upto(@height-1) do |y|
      0.upto(@width-1) do |x|
        panel = Panel.new(
          x_offset + x * 30,
          y_offset + y * 30
        )

        @panels << panel
        @table[x][y] = panel
      end
    end

    # set mine
    bomb = 0
    while bomb < 10
      x = Math.random(@width)
      y = Math.random(@height)

      unless @table[x][y].mine?
        @table[x][y].set_mine
        bomb += 1
      end
    end

    # calc number
    0.upto(@height-1) do |y|
      0.upto(@width-1) do |x|
        calc_number(x, y)
      end
    end
  end

  def calc_number(x, y)
    panel = panel(x, y)
    return if panel.mine?

    num = 0

    pnl = panel(x - 1, y - 1)
    num += 1 if pnl && pnl.mine?

    pnl = panel(x, y - 1)
    num += 1 if pnl && pnl.mine?

    pnl = panel(x + 1, y - 1)
    num += 1 if pnl && pnl.mine?

    pnl = panel(x - 1, y)
    num += 1 if pnl && pnl.mine?

    pnl = panel(x + 1, y)
    num += 1 if pnl && pnl.mine?

    pnl = panel(x - 1, y + 1)
    num += 1 if pnl && pnl.mine?

    pnl = panel(x, y + 1)
    num += 1 if pnl && pnl.mine?

    pnl = panel(x + 1, y + 1)
    num += 1 if pnl && pnl.mine?

    panel.number = num
  end

  def panel(x, y)
    return nil if x < 0 || x >= @width || y < 0 || y >= @height
    @table[x][y]
  end

  def update
    @panels.each { |e| e.update }
  end

  def draw
    @panels.each { |e| e.draw }
  end
end

#---
Window.resize(270, 320, false)
Graphics.set_background([125, 183, 72])

ground = Ground.new(9, 9, 0, 50)

while System.update do
  ground.update
  ground.draw

  # test
  ground = Ground.new(9, 9, 0, 50) if MouseL.down
end
